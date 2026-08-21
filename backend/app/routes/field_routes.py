"""
field_routes.py
API routes for field intelligence.
Now passes soil_type and planting_date through the intelligence pipeline.
"""

from fastapi import APIRouter, HTTPException
from models.field_model import FieldIntelligenceRequest, FieldIntelligenceResponse, FieldCondition
from services.weather_service import fetch_full_weather_package
from engines.rainfall_engine import analyze_rainfall
from engines.forecast_engine import analyze_forecast
from engines.moisture_engine import analyze_moisture
from engines.recommendation_engine import generate_recommendation
from engines.growth_engine import get_growth_stage
import httpx

router = APIRouter(
    prefix="/api/v1/fields",
    tags=["Fields"]
)


@router.post("/intelligence", response_model=FieldIntelligenceResponse)
async def get_field_intelligence(request: FieldIntelligenceRequest):
    try:
        weather_package = await fetch_full_weather_package(
            lat=request.latitude,
            lon=request.longitude
        )
    except httpx.HTTPError as e:
        raise HTTPException(
            status_code=503,
            detail=f"Weather data unavailable. Please try again shortly. ({str(e)})"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to retrieve weather data: {str(e)}"
        )

    rainfall = analyze_rainfall(weather_package["history"])
    forecast = analyze_forecast(weather_package["forecast"])
    moisture = analyze_moisture(rainfall, forecast, request.crop_type)
    recommendation = generate_recommendation(
        rainfall_analysis=rainfall,
        forecast_analysis=forecast,
        moisture_analysis=moisture,
        crop_type=request.crop_type,
        planting_date=request.planting_date,
        soil_type=request.soil_type,
    )

    growth_stage = get_growth_stage(request.crop_type, request.planting_date)

    return FieldIntelligenceResponse(
        field_name=request.field_name,
        crop_type=request.crop_type,
        acreage=request.acreage,
        soil_type=request.soil_type,
        planting_date=request.planting_date,
        growth_stage=growth_stage,
        latitude=request.latitude,
        longitude=request.longitude,
        rainfall=rainfall,
        forecast=forecast,
        moisture=moisture,
        recommendation=recommendation,
    )


@router.get("/sample", response_model=FieldCondition)
def get_sample_field_condition():
    return FieldCondition(
        field_name="North Field",
        crop_type="Corn",
        acreage=120.5,
        rainfall_7_day_inches=1.85,
        saturation_risk="Moderate",
        moisture_trend="Increasing",
        operational_recommendation=(
            "Monitor field saturation before planting. "
            "Conditions may improve if rainfall decreases over the next 48 hours."
        )
    )
"""
field_model.py
Pydantic models for field intelligence requests and responses.
"""

from pydantic import BaseModel, Field
from typing import Optional, List


class FieldIntelligenceRequest(BaseModel):
    field_name: str = Field(..., example="North Field")
    latitude: float = Field(..., example=41.8781)
    longitude: float = Field(..., example=-93.0977)
    crop_type: Optional[str] = Field(None, example="Corn")
    acreage: Optional[float] = Field(None, example=120.5)


class DailyRainfallEntry(BaseModel):
    date: str
    inches: float


class DailyForecastEntry(BaseModel):
    date: str
    precip_inches: float
    precip_probability_pct: int


class HeavyRainDay(BaseModel):
    date: str
    inches: float
    probability: int


class DryWindow(BaseModel):
    available: bool
    start_date: Optional[str]
    end_date: Optional[str]
    duration_days: int


class OperationalAlert(BaseModel):
    level: str   # Warning, Watch, Info, Opportunity
    message: str


class RainfallAnalysis(BaseModel):
    rainfall_last_1_day_inches: float
    rainfall_last_3_day_inches: float
    rainfall_last_7_day_inches: float
    rainfall_last_14_day_inches: float
    rainfall_trend: str
    days_since_meaningful_rain: int
    saturation_risk: str
    daily_history: List[DailyRainfallEntry]


class ForecastAnalysis(BaseModel):
    forecast_rainfall_3_day_inches: float
    forecast_rainfall_7_day_inches: float
    heavy_rain_risk_days: List[HeavyRainDay]
    dry_window: DryWindow
    rain_risk_level: str
    daily_forecast: List[DailyForecastEntry]


class MoistureAnalysis(BaseModel):
    moisture_state: str
    moisture_trend: str
    drought_risk: str
    irrigation_signal: str
    field_dry_days: int


class RecommendationSummary(BaseModel):
    primary_recommendation: str
    planting_readiness: str
    harvest_window_risk: str
    operational_alerts: List[OperationalAlert]


class FieldIntelligenceResponse(BaseModel):
    field_name: str
    crop_type: Optional[str]
    acreage: Optional[float]
    latitude: float
    longitude: float
    rainfall: RainfallAnalysis
    forecast: ForecastAnalysis
    moisture: MoistureAnalysis
    recommendation: RecommendationSummary


# Legacy simple model kept for backward compatibility
class FieldCondition(BaseModel):
    field_name: str
    crop_type: str
    acreage: float
    rainfall_7_day_inches: float
    saturation_risk: str
    moisture_trend: str
    operational_recommendation: str

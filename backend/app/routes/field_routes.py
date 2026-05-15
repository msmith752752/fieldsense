from fastapi import APIRouter
from models.field_model import FieldCondition

router = APIRouter(
    prefix="/api/v1/fields",
    tags=["Fields"]
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
        operational_recommendation="Monitor field saturation before planting. Conditions may improve if rainfall decreases over the next 48 hours."
    )
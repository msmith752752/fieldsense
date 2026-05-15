from pydantic import BaseModel


class FieldCondition(BaseModel):
    field_name: str
    crop_type: str
    acreage: float
    rainfall_7_day_inches: float
    saturation_risk: str
    moisture_trend: str
    operational_recommendation: str
"""
growth_engine.py
Calculates crop growth stage from planting date and crop type.
Also provides soil drainage profiles that adjust moisture thresholds.
"""

from datetime import date, datetime
from typing import Optional


# --- Growth Stage Definitions ---
# Each crop maps days-after-planting to a stage name.
GROWTH_STAGES = {
    "corn": [
        (0, 7, "Germination"),
        (7, 21, "Emergence"),
        (21, 45, "Vegetative (V1–V6)"),
        (45, 65, "Vegetative (V7–V12)"),
        (65, 80, "Tasseling / Silking"),
        (80, 100, "Grain Fill"),
        (100, 130, "Dough / Dent"),
        (130, 999, "Maturity / Harvest"),
    ],
    "soybeans": [
        (0, 10, "Germination"),
        (10, 25, "Emergence (VE)"),
        (25, 50, "Vegetative (V1–V4)"),
        (50, 75, "Flowering (R1–R2)"),
        (75, 95, "Pod Set (R3–R4)"),
        (95, 115, "Seed Fill (R5–R6)"),
        (115, 999, "Maturity / Harvest (R7–R8)"),
    ],
    "wheat": [
        (0, 14, "Germination"),
        (14, 40, "Tillering"),
        (40, 70, "Jointing / Stem Extension"),
        (70, 90, "Heading / Flowering"),
        (90, 115, "Grain Fill"),
        (115, 999, "Maturity / Harvest"),
    ],
    "cotton": [
        (0, 14, "Germination"),
        (14, 35, "Emergence / Seedling"),
        (35, 60, "Squaring"),
        (60, 90, "Flowering / Boll Set"),
        (90, 130, "Boll Development"),
        (130, 999, "Boll Opening / Harvest"),
    ],
    "sorghum": [
        (0, 10, "Germination"),
        (10, 30, "Emergence / Seedling"),
        (30, 60, "Vegetative"),
        (60, 80, "Boot / Heading"),
        (80, 100, "Flowering / Grain Fill"),
        (100, 999, "Maturity / Harvest"),
    ],
}

DEFAULT_STAGES = [
    (0, 30, "Early Growth"),
    (30, 90, "Mid Season"),
    (90, 999, "Late Season / Harvest"),
]

# --- Soil Drainage Profiles ---
# drainage_speed: how quickly soil dries after rain.
# > 1.0 = faster drainage (sandier), < 1.0 = slower drainage (clayier)
SOIL_PROFILES = {
    "sandy": {"drainage_speed": 1.8, "water_holding": 0.5},
    "sandy loam": {"drainage_speed": 1.4, "water_holding": 0.7},
    "loam": {"drainage_speed": 1.0, "water_holding": 1.0},
    "silt loam": {"drainage_speed": 0.85, "water_holding": 1.1},
    "clay loam": {"drainage_speed": 0.65, "water_holding": 1.3},
    "clay": {"drainage_speed": 0.45, "water_holding": 1.5},
    "other": {"drainage_speed": 1.0, "water_holding": 1.0},
}

DEFAULT_SOIL_PROFILE = {"drainage_speed": 1.0, "water_holding": 1.0}


def get_growth_stage(crop_type: Optional[str], planting_date: Optional[str]) -> Optional[str]:
    """
    Returns the current growth stage based on crop type and planting date.
    Returns None if not enough info provided.
    """
    if not crop_type or not planting_date:
        return None

    try:
        planted = datetime.strptime(planting_date, "%Y-%m-%d").date()
    except ValueError:
        return None

    days_since_planting = (date.today() - planted).days
    if days_since_planting < 0:
        return "Pre-Planting"

    stages = GROWTH_STAGES.get(crop_type.strip().lower(), DEFAULT_STAGES)
    for start, end, stage in stages:
        if start <= days_since_planting < end:
            return f"{stage} (Day {days_since_planting})"

    return f"Late Season (Day {days_since_planting})"


def get_soil_profile(soil_type: Optional[str]) -> dict:
    """
    Returns drainage and water holding characteristics for a soil type.
    """
    if not soil_type:
        return DEFAULT_SOIL_PROFILE
    return SOIL_PROFILES.get(soil_type.strip().lower(), DEFAULT_SOIL_PROFILE)


def get_growth_stage_water_need(crop_type: Optional[str], planting_date: Optional[str]) -> str:
    """
    Returns a simple water need descriptor for the current growth stage.
    Used to add context to recommendations.
    """
    if not crop_type or not planting_date:
        return "Normal"

    try:
        planted = datetime.strptime(planting_date, "%Y-%m-%d").date()
    except ValueError:
        return "Normal"

    days = (date.today() - planted).days
    crop = crop_type.strip().lower()

    if crop == "corn":
        if 65 <= days <= 100:
            return "Critical"  # Tasseling through grain fill
        elif 45 <= days < 65 or 100 <= days < 115:
            return "High"
        elif days < 21:
            return "Moderate"
        else:
            return "Normal"

    if crop == "soybeans":
        if 50 <= days <= 115:
            return "High"  # Flowering through seed fill
        else:
            return "Normal"

    if crop == "wheat":
        if 70 <= days <= 115:
            return "High"  # Heading through grain fill
        else:
            return "Normal"

    return "Normal"
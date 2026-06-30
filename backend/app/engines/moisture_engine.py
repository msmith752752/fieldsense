"""
moisture_engine.py
Estimates field moisture conditions using rainfall history,
days since rain, and basic evapotranspiration reasoning.
Now adjusts drought and irrigation thresholds based on crop type.
"""

from engines.crop_profiles import get_crop_profile


def analyze_moisture(rainfall_analysis: dict, forecast_analysis: dict, crop_type: str | None = None) -> dict:
    """
    Combines rainfall history and forecast data to estimate current
    field moisture state and trend direction, adjusted for crop sensitivity.
    """
    profile = get_crop_profile(crop_type)
    drought_sens = profile["drought_sensitivity"]
    saturation_sens = profile["saturation_sensitivity"]

    last_7 = rainfall_analysis.get("rainfall_last_7_day_inches", 0.0)
    last_3 = rainfall_analysis.get("rainfall_last_3_day_inches", 0.0)
    last_1 = rainfall_analysis.get("rainfall_last_1_day_inches", 0.0)
    days_dry = rainfall_analysis.get("days_since_meaningful_rain", 0)
    rainfall_trend = rainfall_analysis.get("rainfall_trend", "Unknown")

    forecast_3 = forecast_analysis.get("forecast_rainfall_3_day_inches", 0.0)

    moisture_state = _estimate_moisture_state(last_7, last_3, days_dry, saturation_sens, drought_sens)
    moisture_trend = _estimate_moisture_trend(rainfall_trend, forecast_3, days_dry)
    drought_risk = _assess_drought_risk(
        days_dry, rainfall_analysis.get("rainfall_last_14_day_inches", 0.0), drought_sens
    )
    irrigation_signal = _assess_irrigation_need(moisture_state, forecast_3, days_dry, drought_sens)

    return {
        "moisture_state": moisture_state,
        "moisture_trend": moisture_trend,
        "drought_risk": drought_risk,
        "irrigation_signal": irrigation_signal,
        "field_dry_days": days_dry,
        "crop_profile_notes": profile["notes"],
    }


def _estimate_moisture_state(last_7, last_3, days_dry, saturation_sens, drought_sens) -> str:
    # Saturation thresholds scale with saturation sensitivity:
    # more sensitive crops (alfalfa, cotton) flag saturated/wet sooner.
    sat_high_7 = 4.0 / saturation_sens
    sat_high_3 = 2.5 / saturation_sens
    sat_mod_7 = 1.5 / saturation_sens
    sat_mod_3 = 0.75 / saturation_sens

    # Dry day threshold scales with drought sensitivity:
    # more drought-tolerant crops (sorghum, cotton) take longer to read as "Dry".
    dry_days_threshold = 14 * (1 / drought_sens) if drought_sens > 0 else 14
    drying_days_threshold = 7 * (1 / drought_sens) if drought_sens > 0 else 7

    if last_7 >= sat_high_7 or last_3 >= sat_high_3:
        return "Saturated"
    elif last_7 >= sat_mod_7 or last_3 >= sat_mod_3:
        return "Wet"
    elif last_7 >= 0.75 and days_dry <= 4:
        return "Adequate"
    elif days_dry >= dry_days_threshold or last_7 < 0.25:
        return "Dry"
    elif days_dry >= drying_days_threshold:
        return "Drying"
    else:
        return "Adequate"


def _estimate_moisture_trend(rainfall_trend: str, forecast_3: float, days_dry: int) -> str:
    if rainfall_trend == "Increasing" or forecast_3 >= 0.5:
        return "Increasing"
    elif rainfall_trend == "Decreasing" and days_dry >= 3:
        return "Decreasing"
    elif days_dry >= 7:
        return "Decreasing"
    else:
        return "Stable"


def _assess_drought_risk(days_dry: int, last_14: float, drought_sens: float) -> str:
    # Higher drought_sens = flags risk sooner (less tolerant crop)
    high_threshold = 21 / drought_sens if drought_sens > 0 else 21
    moderate_threshold = 14 / drought_sens if drought_sens > 0 else 14
    low_threshold = 7 / drought_sens if drought_sens > 0 else 7

    if days_dry >= high_threshold or last_14 < (0.1 * drought_sens):
        return "High"
    elif days_dry >= moderate_threshold or last_14 < (0.5 * drought_sens):
        return "Moderate"
    elif days_dry >= low_threshold:
        return "Low"
    else:
        return "Minimal"


def _assess_irrigation_need(moisture_state: str, forecast_3: float, days_dry: int, drought_sens: float) -> str:
    """
    Suggests whether irrigation may be needed based on moisture state,
    forecast, and crop drought sensitivity.
    """
    dry_days_trigger = 7 / drought_sens if drought_sens > 0 else 7

    if moisture_state in ("Saturated", "Wet"):
        return "Not Recommended"
    elif moisture_state == "Dry" and forecast_3 < 0.25:
        return "Likely Needed"
    elif moisture_state == "Drying" and forecast_3 < 0.5 and days_dry >= dry_days_trigger:
        return "Consider Irrigating"
    elif moisture_state == "Adequate":
        return "Monitor"
    else:
        return "Monitor"
"""
moisture_engine.py
Estimates field moisture conditions using rainfall history,
days since rain, and basic evapotranspiration reasoning.
Produces a moisture state and trend for use in recommendations.
"""


def analyze_moisture(rainfall_analysis: dict, forecast_analysis: dict) -> dict:
    """
    Combines rainfall history and forecast data to estimate current
    field moisture state and trend direction.
    """
    last_7 = rainfall_analysis.get("rainfall_last_7_day_inches", 0.0)
    last_3 = rainfall_analysis.get("rainfall_last_3_day_inches", 0.0)
    last_1 = rainfall_analysis.get("rainfall_last_1_day_inches", 0.0)
    days_dry = rainfall_analysis.get("days_since_meaningful_rain", 0)
    saturation_risk = rainfall_analysis.get("saturation_risk", "Unknown")
    rainfall_trend = rainfall_analysis.get("rainfall_trend", "Unknown")

    forecast_3 = forecast_analysis.get("forecast_rainfall_3_day_inches", 0.0)
    rain_risk = forecast_analysis.get("rain_risk_level", "Unknown")

    moisture_state = _estimate_moisture_state(last_7, last_3, days_dry)
    moisture_trend = _estimate_moisture_trend(rainfall_trend, forecast_3, days_dry)
    drought_risk = _assess_drought_risk(days_dry, last_14=rainfall_analysis.get("rainfall_last_14_day_inches", 0.0))
    irrigation_signal = _assess_irrigation_need(moisture_state, forecast_3, days_dry)

    return {
        "moisture_state": moisture_state,
        "moisture_trend": moisture_trend,
        "drought_risk": drought_risk,
        "irrigation_signal": irrigation_signal,
        "field_dry_days": days_dry,
    }


def _estimate_moisture_state(last_7: float, last_3: float, days_dry: int) -> str:
    """
    Estimates current soil moisture state.
    """
    if last_7 >= 4.0 or last_3 >= 2.5:
        return "Saturated"
    elif last_7 >= 2.0 or last_3 >= 1.0:
        return "Wet"
    elif last_7 >= 0.75 and days_dry <= 4:
        return "Adequate"
    elif days_dry >= 14 or last_7 < 0.25:
        return "Dry"
    elif days_dry >= 7:
        return "Drying"
    else:
        return "Adequate"


def _estimate_moisture_trend(rainfall_trend: str, forecast_3: float, days_dry: int) -> str:
    """
    Estimates whether moisture conditions are improving, worsening, or stable.
    """
    if rainfall_trend == "Increasing" or forecast_3 >= 0.5:
        return "Increasing"
    elif rainfall_trend == "Decreasing" and days_dry >= 3:
        return "Decreasing"
    elif days_dry >= 7:
        return "Decreasing"
    else:
        return "Stable"


def _assess_drought_risk(days_dry: int, last_14: float) -> str:
    if days_dry >= 21 or last_14 < 0.1:
        return "High"
    elif days_dry >= 14 or last_14 < 0.5:
        return "Moderate"
    elif days_dry >= 7:
        return "Low"
    else:
        return "Minimal"


def _assess_irrigation_need(moisture_state: str, forecast_3: float, days_dry: int) -> str:
    """
    Suggests whether irrigation may be needed based on moisture state
    and upcoming forecast. Does not override farmer judgment.
    """
    if moisture_state in ("Saturated", "Wet"):
        return "Not Recommended"
    elif moisture_state == "Dry" and forecast_3 < 0.25:
        return "Likely Needed"
    elif moisture_state == "Drying" and forecast_3 < 0.5 and days_dry >= 7:
        return "Consider Irrigating"
    elif moisture_state == "Adequate":
        return "Monitor"
    else:
        return "Monitor"

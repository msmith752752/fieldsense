"""
recommendation_engine.py
The core intelligence layer of FieldSense.
Takes analyzed rainfall, forecast, and moisture data and produces
clear, actionable operational recommendations for farmers.
"""

from typing import Optional


def generate_recommendation(
    rainfall_analysis: dict,
    forecast_analysis: dict,
    moisture_analysis: dict,
    crop_type: Optional[str] = None,
) -> dict:
    """
    Synthesizes all analysis layers into a primary recommendation,
    operational alerts, and a field readiness score.
    """
    saturation_risk = rainfall_analysis.get("saturation_risk", "Unknown")
    moisture_state = moisture_analysis.get("moisture_state", "Unknown")
    moisture_trend = moisture_analysis.get("moisture_trend", "Unknown")
    drought_risk = moisture_analysis.get("drought_risk", "Minimal")
    irrigation_signal = moisture_analysis.get("irrigation_signal", "Monitor")
    rain_risk = forecast_analysis.get("rain_risk_level", "Unknown")
    dry_window = forecast_analysis.get("dry_window", {})
    heavy_rain_days = forecast_analysis.get("heavy_rain_risk_days", [])
    days_dry = moisture_analysis.get("field_dry_days", 0)
    last_7 = rainfall_analysis.get("rainfall_last_7_day_inches", 0.0)
    forecast_3 = forecast_analysis.get("forecast_rainfall_3_day_inches", 0.0)

    alerts = _build_alerts(
        saturation_risk, rain_risk, drought_risk,
        heavy_rain_days, dry_window, irrigation_signal, days_dry
    )

    primary_recommendation = _build_primary_recommendation(
        moisture_state, moisture_trend, saturation_risk,
        rain_risk, dry_window, drought_risk, irrigation_signal, crop_type
    )

    planting_readiness = _score_planting_readiness(
        saturation_risk, moisture_state, rain_risk, forecast_3
    )

    harvest_window_risk = _score_harvest_window_risk(
        rain_risk, saturation_risk, heavy_rain_days
    )

    return {
        "primary_recommendation": primary_recommendation,
        "planting_readiness": planting_readiness,
        "harvest_window_risk": harvest_window_risk,
        "operational_alerts": alerts,
    }


def _build_primary_recommendation(
    moisture_state, moisture_trend, saturation_risk,
    rain_risk, dry_window, drought_risk, irrigation_signal, crop_type
) -> str:

    crop_note = f" for {crop_type}" if crop_type else ""

    # Saturated / high risk conditions
    if saturation_risk == "High":
        if rain_risk in ("High", "Moderate"):
            return (
                f"Field conditions{crop_note} are saturated with additional rainfall expected. "
                "Avoid field operations. Monitor drainage and delay planting until conditions improve."
            )
        else:
            return (
                f"Field is currently saturated{crop_note}. Rainfall appears to be easing. "
                "Allow 2-4 days of drying before resuming field operations."
            )

    # Moderate saturation
    if saturation_risk == "Moderate":
        if dry_window.get("available") and dry_window.get("duration_days", 0) >= 2:
            return (
                f"Moderate saturation present{crop_note}. A dry window appears likely starting "
                f"{dry_window['start_date']}. Plan field operations around this window."
            )
        return (
            f"Field moisture is elevated{crop_note}. Monitor conditions closely. "
            "Avoid heavy equipment on wet ground to prevent compaction."
        )

    # Dry / drought conditions
    if drought_risk in ("High", "Moderate") or moisture_state == "Dry":
        if irrigation_signal == "Likely Needed":
            return (
                f"Field is dry with limited rainfall expected{crop_note}. "
                "Irrigation is likely needed. Monitor crop stress indicators."
            )
        return (
            f"Dry conditions developing{crop_note}. Rainfall has been below normal. "
            "Monitor soil moisture and consider irrigation planning."
        )

    # Favorable conditions
    if moisture_state in ("Adequate",) and rain_risk in ("Low", "Minimal"):
        return (
            f"Field conditions appear favorable{crop_note}. "
            "Moisture levels are adequate and no significant rainfall disruptions are expected."
        )

    # Trending toward good
    if moisture_trend == "Decreasing" and saturation_risk in ("Low", "Minimal"):
        if dry_window.get("available"):
            return (
                f"Conditions improving{crop_note}. Field is drying and a favorable operational "
                f"window appears to be developing starting {dry_window.get('start_date', 'soon')}."
            )

    return (
        f"Field conditions are variable{crop_note}. "
        "Continue monitoring rainfall and moisture trends before making operational decisions."
    )


def _build_alerts(
    saturation_risk, rain_risk, drought_risk,
    heavy_rain_days, dry_window, irrigation_signal, days_dry
) -> list:
    alerts = []

    if saturation_risk == "High":
        alerts.append({
            "level": "Warning",
            "message": "High saturation risk — field operations not recommended."
        })

    if rain_risk == "High":
        alerts.append({
            "level": "Warning",
            "message": "Heavy rainfall expected in the coming days. Delay sensitive operations."
        })

    if heavy_rain_days:
        dates = ", ".join([d["date"] for d in heavy_rain_days[:3]])
        alerts.append({
            "level": "Watch",
            "message": f"Significant rainfall possible on: {dates}."
        })

    if drought_risk == "High":
        alerts.append({
            "level": "Watch",
            "message": "Drought conditions developing. Consider irrigation planning."
        })

    if irrigation_signal == "Likely Needed":
        alerts.append({
            "level": "Info",
            "message": "Irrigation may be needed. Rainfall has been insufficient."
        })

    if dry_window.get("available") and dry_window.get("duration_days", 0) >= 3:
        alerts.append({
            "level": "Opportunity",
            "message": f"Favorable dry window: {dry_window['start_date']} to {dry_window['end_date']} ({dry_window['duration_days']} days)."
        })

    if days_dry >= 10:
        alerts.append({
            "level": "Info",
            "message": f"No meaningful rainfall in {days_dry} days. Monitor crop and soil conditions."
        })

    return alerts


def _score_planting_readiness(
    saturation_risk: str, moisture_state: str, rain_risk: str, forecast_3: float
) -> str:
    if saturation_risk in ("High",) or moisture_state == "Saturated":
        return "Not Ready"
    elif saturation_risk == "Moderate" or rain_risk == "High":
        return "Marginal"
    elif moisture_state in ("Adequate",) and rain_risk in ("Low", "Minimal"):
        return "Favorable"
    elif moisture_state == "Wet" and forecast_3 < 0.5:
        return "Monitor"
    elif moisture_state == "Dry":
        return "Dry — Check Irrigation"
    else:
        return "Monitor"


def _score_harvest_window_risk(
    rain_risk: str, saturation_risk: str, heavy_rain_days: list
) -> str:
    if rain_risk == "High" or len(heavy_rain_days) >= 2:
        return "High Risk"
    elif rain_risk == "Moderate" or saturation_risk in ("High", "Moderate"):
        return "Moderate Risk"
    elif rain_risk == "Low":
        return "Low Risk"
    else:
        return "Favorable"

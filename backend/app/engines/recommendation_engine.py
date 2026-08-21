"""
recommendation_engine.py
The core intelligence layer of FieldSense.
Now incorporates soil type, growth stage, and water need
to produce a sharp daily verdict alongside full recommendations.
"""

from typing import Optional
from engines.growth_engine import get_growth_stage, get_growth_stage_water_need, get_soil_profile


def generate_recommendation(
    rainfall_analysis: dict,
    forecast_analysis: dict,
    moisture_analysis: dict,
    crop_type: Optional[str] = None,
    planting_date: Optional[str] = None,
    soil_type: Optional[str] = None,
) -> dict:
    saturation_risk = rainfall_analysis.get("saturation_risk", "Unknown")
    moisture_state = moisture_analysis.get("moisture_state", "Unknown")
    moisture_trend = moisture_analysis.get("moisture_trend", "Unknown")
    drought_risk = moisture_analysis.get("drought_risk", "Minimal")
    irrigation_signal = moisture_analysis.get("irrigation_signal", "Monitor")
    rain_risk = forecast_analysis.get("rain_risk_level", "Unknown")
    dry_window = forecast_analysis.get("dry_window", {})
    heavy_rain_days = forecast_analysis.get("heavy_rain_risk_days", [])
    days_dry = moisture_analysis.get("field_dry_days", 0)
    forecast_3 = forecast_analysis.get("forecast_rainfall_3_day_inches", 0.0)

    growth_stage = get_growth_stage(crop_type, planting_date)
    water_need = get_growth_stage_water_need(crop_type, planting_date)
    soil_profile = get_soil_profile(soil_type)

    daily_verdict = _build_daily_verdict(
        moisture_state, saturation_risk, rain_risk, drought_risk,
        irrigation_signal, dry_window, heavy_rain_days, crop_type,
        growth_stage, water_need, soil_type, days_dry
    )

    primary_recommendation = _build_primary_recommendation(
        moisture_state, moisture_trend, saturation_risk,
        rain_risk, dry_window, drought_risk, irrigation_signal,
        crop_type, growth_stage, water_need, soil_type
    )

    alerts = _build_alerts(
        saturation_risk, rain_risk, drought_risk,
        heavy_rain_days, dry_window, irrigation_signal,
        days_dry, water_need, growth_stage
    )

    planting_readiness = _score_planting_readiness(
        saturation_risk, moisture_state, rain_risk, forecast_3
    )

    harvest_window_risk = _score_harvest_window_risk(
        rain_risk, saturation_risk, heavy_rain_days
    )

    return {
        "primary_recommendation": primary_recommendation,
        "daily_verdict": daily_verdict,
        "planting_readiness": planting_readiness,
        "harvest_window_risk": harvest_window_risk,
        "growth_stage": growth_stage,
        "operational_alerts": alerts,
    }


def _build_daily_verdict(
    moisture_state, saturation_risk, rain_risk, drought_risk,
    irrigation_signal, dry_window, heavy_rain_days, crop_type,
    growth_stage, water_need, soil_type, days_dry
) -> str:
    """
    The single most important output — one clear sentence telling
    the farmer what to do or watch for today.
    """
    crop = crop_type or "your crop"
    soil = f" on {soil_type.lower()} soil" if soil_type else ""
    stage = f" ({growth_stage})" if growth_stage else ""

    # Critical growth stage + dry
    if water_need == "Critical" and drought_risk in ("High", "Moderate"):
        return f"Irrigate now — {crop}{stage} is in a critical water demand period{soil} and moisture is insufficient."

    # High water need + dry
    if water_need == "High" and irrigation_signal == "Likely Needed":
        return f"{crop.capitalize()}{stage} has high water needs right now — irrigation is recommended{soil}."

    # Saturated + more rain coming
    if saturation_risk == "High" and rain_risk in ("High", "Moderate"):
        return f"Stay out of the field — saturated conditions{soil} with more rain expected."

    # Saturated but clearing
    if saturation_risk == "High":
        return f"Field is saturated{soil} — wait for conditions to dry before any operations."

    # Heavy rain incoming
    if len(heavy_rain_days) >= 2:
        return f"Significant rainfall expected — hold off on field operations and monitor conditions."

    # Dry window opportunity
    if dry_window.get("available") and dry_window.get("duration_days", 0) >= 3:
        start = dry_window.get("start_date", "soon")
        days = dry_window.get("duration_days", 0)
        return f"Good operational window opening {start} ({days} days) — plan field work accordingly."

    # Favorable
    if moisture_state == "Adequate" and rain_risk in ("Low", "Minimal"):
        return f"Field conditions are favorable{soil}{stage} — good day for operations."

    # Dry
    if moisture_state == "Dry" and days_dry >= 7:
        return f"Dry conditions — {days_dry} days without meaningful rain{soil}. Monitor {crop} closely."

    # Default
    return f"Monitor conditions — no immediate action required for {crop}{stage}."


def _build_primary_recommendation(
    moisture_state, moisture_trend, saturation_risk,
    rain_risk, dry_window, drought_risk, irrigation_signal,
    crop_type, growth_stage, water_need, soil_type
) -> str:
    crop_note = f" for {crop_type}" if crop_type else ""
    stage_note = f" ({growth_stage})" if growth_stage else ""
    soil_note = f" {soil_type.lower()} soil drains" if soil_type else ""

    if saturation_risk == "High":
        if rain_risk in ("High", "Moderate"):
            return (
                f"Field conditions{crop_note}{stage_note} are saturated with additional rainfall expected. "
                "Avoid field operations. Monitor drainage and delay planting until conditions improve."
            )
        else:
            return (
                f"Field is currently saturated{crop_note}{stage_note}. Rainfall appears to be easing. "
                "Allow 2-4 days of drying before resuming field operations."
            )

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

    if water_need == "Critical" and drought_risk in ("High", "Moderate"):
        return (
            f"{crop_type or 'Crop'}{stage_note} is in a critical water demand stage and field moisture is low. "
            "Irrigation is strongly recommended. Yield loss risk increases with each day of delay."
        )

    if drought_risk in ("High", "Moderate") or moisture_state == "Dry":
        if irrigation_signal == "Likely Needed":
            return (
                f"Field is dry with limited rainfall expected{crop_note}{stage_note}. "
                "Irrigation is likely needed. Monitor crop stress indicators."
            )
        return (
            f"Dry conditions developing{crop_note}. Rainfall has been below normal. "
            "Monitor soil moisture and consider irrigation planning."
        )

    if moisture_state == "Adequate" and rain_risk in ("Low", "Minimal"):
        return (
            f"Field conditions appear favorable{crop_note}{stage_note}. "
            "Moisture levels are adequate and no significant rainfall disruptions are expected."
        )

    if moisture_trend == "Decreasing" and saturation_risk in ("Low", "Minimal"):
        if dry_window.get("available"):
            return (
                f"Conditions improving{crop_note}. Field is drying and a favorable operational "
                f"window appears to be developing starting {dry_window.get('start_date', 'soon')}."
            )

    return (
        f"Field conditions are variable{crop_note}{stage_note}. "
        "Continue monitoring rainfall and moisture trends before making operational decisions."
    )


def _build_alerts(
    saturation_risk, rain_risk, drought_risk,
    heavy_rain_days, dry_window, irrigation_signal,
    days_dry, water_need, growth_stage
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

    if water_need == "Critical" and drought_risk in ("High", "Moderate"):
        alerts.append({
            "level": "Warning",
            "message": f"Critical growth stage water stress detected — {growth_stage}. Irrigate promptly."
        })
    elif water_need == "High" and irrigation_signal in ("Likely Needed", "Consider Irrigating"):
        alerts.append({
            "level": "Watch",
            "message": f"High water demand at {growth_stage} — monitor moisture closely."
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
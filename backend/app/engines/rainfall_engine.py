"""
rainfall_engine.py
Analyzes rainfall history data to produce accumulation totals,
trend direction, and saturation risk scoring.
"""

from typing import Optional


def analyze_rainfall(history_data: dict) -> dict:
    """
    Takes raw Open-Meteo history response and returns structured rainfall analysis.
    """
    daily = history_data.get("daily", {})
    dates = daily.get("time", [])
    amounts = daily.get("precipitation_sum", [])

    if not dates or not amounts:
        return _empty_rainfall_analysis()

    # Clean None values to 0.0
    amounts = [a if a is not None else 0.0 for a in amounts]

    total_days = len(amounts)
    last_7 = sum(amounts[-7:]) if total_days >= 7 else sum(amounts)
    last_14 = sum(amounts[-14:]) if total_days >= 14 else sum(amounts)
    last_3 = sum(amounts[-3:]) if total_days >= 3 else sum(amounts)
    last_1 = amounts[-1] if amounts else 0.0

    # Trend: compare last 7 days to prior 7 days
    if total_days >= 14:
        prior_7 = sum(amounts[-14:-7])
        trend = _calculate_trend(last_7, prior_7)
    else:
        trend = "Insufficient data"

    # Days since meaningful rain (>= 0.1 inch)
    days_since_rain = 0
    for amount in reversed(amounts):
        if amount >= 0.1:
            break
        days_since_rain += 1

    saturation_risk = _score_saturation_risk(last_7, last_3)

    return {
        "rainfall_last_1_day_inches": round(last_1, 2),
        "rainfall_last_3_day_inches": round(last_3, 2),
        "rainfall_last_7_day_inches": round(last_7, 2),
        "rainfall_last_14_day_inches": round(last_14, 2),
        "rainfall_trend": trend,
        "days_since_meaningful_rain": days_since_rain,
        "saturation_risk": saturation_risk,
        "daily_history": [
            {"date": d, "inches": round(a, 2)}
            for d, a in zip(dates, amounts)
        ],
    }


def _calculate_trend(recent: float, prior: float) -> str:
    if prior == 0:
        return "Increasing" if recent > 0 else "Dry"
    change_pct = ((recent - prior) / prior) * 100
    if change_pct > 25:
        return "Increasing"
    elif change_pct < -25:
        return "Decreasing"
    else:
        return "Stable"


def _score_saturation_risk(last_7: float, last_3: float) -> str:
    """
    Estimates field saturation risk based on recent rainfall accumulation.
    Thresholds based on general agronomic guidelines.
    """
    if last_7 >= 4.0 or last_3 >= 2.5:
        return "High"
    elif last_7 >= 2.0 or last_3 >= 1.25:
        return "Moderate"
    elif last_7 >= 0.5:
        return "Low"
    else:
        return "Minimal"


def _empty_rainfall_analysis() -> dict:
    return {
        "rainfall_last_1_day_inches": 0.0,
        "rainfall_last_3_day_inches": 0.0,
        "rainfall_last_7_day_inches": 0.0,
        "rainfall_last_14_day_inches": 0.0,
        "rainfall_trend": "Unknown",
        "days_since_meaningful_rain": 0,
        "saturation_risk": "Unknown",
        "daily_history": [],
    }

"""
forecast_engine.py
Interprets upcoming forecast data to identify rainfall probability,
heavy rain risk, and dry operational windows for farmers.
"""


def analyze_forecast(forecast_data: dict) -> dict:
    """
    Takes raw Open-Meteo forecast response and returns structured forecast intelligence.
    """
    daily = forecast_data.get("daily", {})
    dates = daily.get("time", [])
    precip_totals = daily.get("precipitation_sum", [])
    precip_prob = daily.get("precipitation_probability_max", [])
    et0 = daily.get("et0_fao_evapotranspiration", [])

    if not dates:
        return _empty_forecast_analysis()

    # Clean Nones
    precip_totals = [v if v is not None else 0.0 for v in precip_totals]
    precip_prob = [v if v is not None else 0 for v in precip_prob]
    et0 = [v if v is not None else 0.0 for v in et0]

    forecast_7 = sum(precip_totals[:7])
    forecast_3 = sum(precip_totals[:3])

    heavy_rain_days = [
        {"date": d, "inches": round(p, 2), "probability": prob}
        for d, p, prob in zip(dates, precip_totals, precip_prob)
        if p >= 0.75
    ]

    dry_window = _find_dry_window(dates, precip_totals, precip_prob)
    rain_risk_level = _score_rain_risk(forecast_7, forecast_3, heavy_rain_days)

    daily_forecast = [
        {
            "date": d,
            "precip_inches": round(p, 2),
            "precip_probability_pct": prob,
        }
        for d, p, prob in zip(dates, precip_totals, precip_prob)
    ]

    return {
        "forecast_rainfall_3_day_inches": round(forecast_3, 2),
        "forecast_rainfall_7_day_inches": round(forecast_7, 2),
        "heavy_rain_risk_days": heavy_rain_days,
        "dry_window": dry_window,
        "rain_risk_level": rain_risk_level,
        "daily_forecast": daily_forecast,
    }


def _find_dry_window(dates: list, totals: list, probs: list) -> dict:
    """
    Finds the next consecutive dry window (low rain probability, low accumulation).
    Useful for identifying planting or harvest operation windows.
    """
    dry_days = []
    for d, total, prob in zip(dates, totals, probs):
        if total <= 0.1 and prob <= 30:
            dry_days.append(d)
        else:
            if len(dry_days) >= 2:
                break
            dry_days = []

    if len(dry_days) >= 2:
        return {
            "available": True,
            "start_date": dry_days[0],
            "end_date": dry_days[-1],
            "duration_days": len(dry_days),
        }
    elif len(dry_days) == 1:
        return {
            "available": True,
            "start_date": dry_days[0],
            "end_date": dry_days[0],
            "duration_days": 1,
        }
    else:
        return {
            "available": False,
            "start_date": None,
            "end_date": None,
            "duration_days": 0,
        }


def _score_rain_risk(forecast_7: float, forecast_3: float, heavy_days: list) -> str:
    if len(heavy_days) >= 2 or forecast_3 >= 2.0 or forecast_7 >= 4.0:
        return "High"
    elif len(heavy_days) == 1 or forecast_3 >= 1.0 or forecast_7 >= 2.0:
        return "Moderate"
    elif forecast_7 >= 0.25:
        return "Low"
    else:
        return "Minimal"


def _empty_forecast_analysis() -> dict:
    return {
        "forecast_rainfall_3_day_inches": 0.0,
        "forecast_rainfall_7_day_inches": 0.0,
        "heavy_rain_risk_days": [],
        "dry_window": {"available": False, "start_date": None, "end_date": None, "duration_days": 0},
        "rain_risk_level": "Unknown",
        "daily_forecast": [],
    }

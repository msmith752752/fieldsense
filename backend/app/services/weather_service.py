"""
weather_service.py
Fetches real rainfall history and forecast data from Open-Meteo API.
No API key required. Free and open.
"""

import httpx
from datetime import date, timedelta
from typing import Optional


OPEN_METEO_BASE = "https://api.open-meteo.com/v1"


async def fetch_rainfall_history(lat: float, lon: float, days_back: int = 14) -> dict:
    """
    Fetches daily rainfall totals for the past N days.
    Returns raw Open-Meteo response data.
    """
    end_date = date.today()
    start_date = end_date - timedelta(days=days_back)

    params = {
        "latitude": lat,
        "longitude": lon,
        "daily": "precipitation_sum",
        "start_date": start_date.isoformat(),
        "end_date": end_date.isoformat(),
        "timezone": "auto",
        "precipitation_unit": "inch",
    }

    async with httpx.AsyncClient(timeout=10.0) as client:
        response = await client.get(f"{OPEN_METEO_BASE}/forecast", params=params)
        response.raise_for_status()
        return response.json()


async def fetch_forecast(lat: float, lon: float, days_ahead: int = 10) -> dict:
    """
    Fetches daily precipitation probability and totals for the next N days.
    Returns raw Open-Meteo response data.
    """
    params = {
        "latitude": lat,
        "longitude": lon,
        "daily": [
            "precipitation_sum",
            "precipitation_probability_max",
            "temperature_2m_max",
            "temperature_2m_min",
            "et0_fao_evapotranspiration",
        ],
        "forecast_days": days_ahead,
        "timezone": "auto",
        "precipitation_unit": "inch",
    }

    async with httpx.AsyncClient(timeout=10.0) as client:
        response = await client.get(f"{OPEN_METEO_BASE}/forecast", params=params)
        response.raise_for_status()
        return response.json()


async def fetch_full_weather_package(lat: float, lon: float) -> dict:
    """
    Fetches both history and forecast in parallel.
    Returns a combined package used by the intelligence engines.
    """
    import asyncio

    history_task = fetch_rainfall_history(lat, lon, days_back=14)
    forecast_task = fetch_forecast(lat, lon, days_ahead=10)

    history, forecast = await asyncio.gather(history_task, forecast_task)

    return {
        "history": history,
        "forecast": forecast,
        "location": {"lat": lat, "lon": lon},
    }

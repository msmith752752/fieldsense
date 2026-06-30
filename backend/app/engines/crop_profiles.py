"""
crop_profiles.py
Defines crop-specific sensitivity profiles used to adjust moisture
and drought thresholds. Different crops tolerate dry and wet
conditions differently, so the same rainfall data should produce
different intelligence depending on what's planted.

Profile fields:
- drought_sensitivity: multiplier applied to "days since rain" thresholds.
  Lower than 1.0 = more drought tolerant (takes longer to flag dry risk).
  Higher than 1.0 = less drought tolerant (flags dry risk sooner).
- saturation_sensitivity: multiplier applied to saturation thresholds.
  Lower than 1.0 = more flood tolerant.
  Higher than 1.0 = less flood tolerant (flags saturation risk sooner).
- notes: short reasoning, used nowhere functionally, just for clarity.
"""

CROP_PROFILES = {
    "corn": {
        "drought_sensitivity": 1.15,
        "saturation_sensitivity": 0.9,
        "notes": "Needs consistent moisture, especially at tasseling/silking. Moderate flood tolerance.",
    },
    "soybeans": {
        "drought_sensitivity": 1.0,
        "saturation_sensitivity": 1.1,
        "notes": "Moderate water needs, but sensitive to waterlogging in early growth stages.",
    },
    "wheat": {
        "drought_sensitivity": 0.8,
        "saturation_sensitivity": 1.2,
        "notes": "Drought tolerant relative to corn/soy, but sensitive to standing water and saturation.",
    },
    "cotton": {
        "drought_sensitivity": 0.75,
        "saturation_sensitivity": 1.15,
        "notes": "Deep rooted, drought tolerant. Poor tolerance for saturated/waterlogged soil.",
    },
    "sorghum": {
        "drought_sensitivity": 0.65,
        "saturation_sensitivity": 1.0,
        "notes": "Highly drought tolerant crop, bred for dry conditions.",
    },
    "hay": {
        "drought_sensitivity": 1.05,
        "saturation_sensitivity": 0.95,
        "notes": "Generally resilient, slightly favors consistent moisture for cutting cycles.",
    },
    "alfalfa": {
        "drought_sensitivity": 0.85,
        "saturation_sensitivity": 1.25,
        "notes": "Deep rooted and drought tolerant, but very poor tolerance for wet/saturated soil.",
    },
    "pasture": {
        "drought_sensitivity": 1.0,
        "saturation_sensitivity": 1.0,
        "notes": "Mixed grasses, treated as a neutral baseline.",
    },
    "vegetables": {
        "drought_sensitivity": 1.3,
        "saturation_sensitivity": 1.1,
        "notes": "Shallow rooted, generally need more consistent moisture than row crops.",
    },
}

DEFAULT_PROFILE = {
    "drought_sensitivity": 1.0,
    "saturation_sensitivity": 1.0,
    "notes": "No specific crop profile available, using neutral baseline.",
}


def get_crop_profile(crop_type: str | None) -> dict:
    """
    Returns the sensitivity profile for a given crop type.
    Falls back to a neutral default if crop_type is None or unrecognized.
    """
    if not crop_type:
        return DEFAULT_PROFILE
    key = crop_type.strip().lower()
    return CROP_PROFILES.get(key, DEFAULT_PROFILE)
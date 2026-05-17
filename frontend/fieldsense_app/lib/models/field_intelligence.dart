// field_intelligence.dart
// Data models that match the FieldSense backend API response exactly.

class FieldIntelligenceRequest {
  final String fieldName;
  final double latitude;
  final double longitude;
  final String? cropType;
  final double? acreage;

  FieldIntelligenceRequest({
    required this.fieldName,
    required this.latitude,
    required this.longitude,
    this.cropType,
    this.acreage,
  });

  Map<String, dynamic> toJson() => {
        'field_name': fieldName,
        'latitude': latitude,
        'longitude': longitude,
        if (cropType != null) 'crop_type': cropType,
        if (acreage != null) 'acreage': acreage,
      };
}

class FieldIntelligenceResponse {
  final String fieldName;
  final String? cropType;
  final double? acreage;
  final double latitude;
  final double longitude;
  final RainfallAnalysis rainfall;
  final ForecastAnalysis forecast;
  final MoistureAnalysis moisture;
  final RecommendationSummary recommendation;

  FieldIntelligenceResponse({
    required this.fieldName,
    this.cropType,
    this.acreage,
    required this.latitude,
    required this.longitude,
    required this.rainfall,
    required this.forecast,
    required this.moisture,
    required this.recommendation,
  });

  factory FieldIntelligenceResponse.fromJson(Map<String, dynamic> json) {
    return FieldIntelligenceResponse(
      fieldName: json['field_name'],
      cropType: json['crop_type'],
      acreage: json['acreage']?.toDouble(),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      rainfall: RainfallAnalysis.fromJson(json['rainfall']),
      forecast: ForecastAnalysis.fromJson(json['forecast']),
      moisture: MoistureAnalysis.fromJson(json['moisture']),
      recommendation: RecommendationSummary.fromJson(json['recommendation']),
    );
  }
}

class RainfallAnalysis {
  final double last1Day;
  final double last3Day;
  final double last7Day;
  final double last14Day;
  final String trend;
  final int daysSinceRain;
  final String saturationRisk;
  final List<DailyRainfall> dailyHistory;

  RainfallAnalysis({
    required this.last1Day,
    required this.last3Day,
    required this.last7Day,
    required this.last14Day,
    required this.trend,
    required this.daysSinceRain,
    required this.saturationRisk,
    required this.dailyHistory,
  });

  factory RainfallAnalysis.fromJson(Map<String, dynamic> json) {
    return RainfallAnalysis(
      last1Day: (json['rainfall_last_1_day_inches'] ?? 0).toDouble(),
      last3Day: (json['rainfall_last_3_day_inches'] ?? 0).toDouble(),
      last7Day: (json['rainfall_last_7_day_inches'] ?? 0).toDouble(),
      last14Day: (json['rainfall_last_14_day_inches'] ?? 0).toDouble(),
      trend: json['rainfall_trend'] ?? 'Unknown',
      daysSinceRain: json['days_since_meaningful_rain'] ?? 0,
      saturationRisk: json['saturation_risk'] ?? 'Unknown',
      dailyHistory: (json['daily_history'] as List? ?? [])
          .map((e) => DailyRainfall.fromJson(e))
          .toList(),
    );
  }
}

class DailyRainfall {
  final String date;
  final double inches;

  DailyRainfall({required this.date, required this.inches});

  factory DailyRainfall.fromJson(Map<String, dynamic> json) {
    return DailyRainfall(
      date: json['date'],
      inches: (json['inches'] ?? 0).toDouble(),
    );
  }
}

class ForecastAnalysis {
  final double forecast3Day;
  final double forecast7Day;
  final List<HeavyRainDay> heavyRainDays;
  final DryWindow dryWindow;
  final String rainRiskLevel;
  final List<DailyForecast> dailyForecast;

  ForecastAnalysis({
    required this.forecast3Day,
    required this.forecast7Day,
    required this.heavyRainDays,
    required this.dryWindow,
    required this.rainRiskLevel,
    required this.dailyForecast,
  });

  factory ForecastAnalysis.fromJson(Map<String, dynamic> json) {
    return ForecastAnalysis(
      forecast3Day: (json['forecast_rainfall_3_day_inches'] ?? 0).toDouble(),
      forecast7Day: (json['forecast_rainfall_7_day_inches'] ?? 0).toDouble(),
      heavyRainDays: (json['heavy_rain_risk_days'] as List? ?? [])
          .map((e) => HeavyRainDay.fromJson(e))
          .toList(),
      dryWindow: DryWindow.fromJson(json['dry_window'] ?? {}),
      rainRiskLevel: json['rain_risk_level'] ?? 'Unknown',
      dailyForecast: (json['daily_forecast'] as List? ?? [])
          .map((e) => DailyForecast.fromJson(e))
          .toList(),
    );
  }
}

class HeavyRainDay {
  final String date;
  final double inches;
  final int probability;

  HeavyRainDay(
      {required this.date, required this.inches, required this.probability});

  factory HeavyRainDay.fromJson(Map<String, dynamic> json) {
    return HeavyRainDay(
      date: json['date'],
      inches: (json['inches'] ?? 0).toDouble(),
      probability: json['probability'] ?? 0,
    );
  }
}

class DryWindow {
  final bool available;
  final String? startDate;
  final String? endDate;
  final int durationDays;

  DryWindow({
    required this.available,
    this.startDate,
    this.endDate,
    required this.durationDays,
  });

  factory DryWindow.fromJson(Map<String, dynamic> json) {
    return DryWindow(
      available: json['available'] ?? false,
      startDate: json['start_date'],
      endDate: json['end_date'],
      durationDays: json['duration_days'] ?? 0,
    );
  }
}

class DailyForecast {
  final String date;
  final double precipInches;
  final int precipProbability;

  DailyForecast({
    required this.date,
    required this.precipInches,
    required this.precipProbability,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'],
      precipInches: (json['precip_inches'] ?? 0).toDouble(),
      precipProbability: json['precip_probability_pct'] ?? 0,
    );
  }
}

class MoistureAnalysis {
  final String moistureState;
  final String moistureTrend;
  final String droughtRisk;
  final String irrigationSignal;
  final int fieldDryDays;

  MoistureAnalysis({
    required this.moistureState,
    required this.moistureTrend,
    required this.droughtRisk,
    required this.irrigationSignal,
    required this.fieldDryDays,
  });

  factory MoistureAnalysis.fromJson(Map<String, dynamic> json) {
    return MoistureAnalysis(
      moistureState: json['moisture_state'] ?? 'Unknown',
      moistureTrend: json['moisture_trend'] ?? 'Unknown',
      droughtRisk: json['drought_risk'] ?? 'Unknown',
      irrigationSignal: json['irrigation_signal'] ?? 'Monitor',
      fieldDryDays: json['field_dry_days'] ?? 0,
    );
  }
}

class RecommendationSummary {
  final String primaryRecommendation;
  final String plantingReadiness;
  final String harvestWindowRisk;
  final List<OperationalAlert> alerts;

  RecommendationSummary({
    required this.primaryRecommendation,
    required this.plantingReadiness,
    required this.harvestWindowRisk,
    required this.alerts,
  });

  factory RecommendationSummary.fromJson(Map<String, dynamic> json) {
    return RecommendationSummary(
      primaryRecommendation: json['primary_recommendation'] ?? '',
      plantingReadiness: json['planting_readiness'] ?? 'Unknown',
      harvestWindowRisk: json['harvest_window_risk'] ?? 'Unknown',
      alerts: (json['operational_alerts'] as List? ?? [])
          .map((e) => OperationalAlert.fromJson(e))
          .toList(),
    );
  }
}

class OperationalAlert {
  final String level;
  final String message;

  OperationalAlert({required this.level, required this.message});

  factory OperationalAlert.fromJson(Map<String, dynamic> json) {
    return OperationalAlert(
      level: json['level'] ?? 'Info',
      message: json['message'] ?? '',
    );
  }
}

// Saved field model for local storage
class SavedField {
  final String fieldName;
  final double latitude;
  final double longitude;
  final String? cropType;
  final double? acreage;

  SavedField({
    required this.fieldName,
    required this.latitude,
    required this.longitude,
    this.cropType,
    this.acreage,
  });

  Map<String, dynamic> toJson() => {
        'field_name': fieldName,
        'latitude': latitude,
        'longitude': longitude,
        'crop_type': cropType,
        'acreage': acreage,
      };

  factory SavedField.fromJson(Map<String, dynamic> json) {
    return SavedField(
      fieldName: json['field_name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      cropType: json['crop_type'],
      acreage: json['acreage']?.toDouble(),
    );
  }

  FieldIntelligenceRequest toRequest() {
    return FieldIntelligenceRequest(
      fieldName: fieldName,
      latitude: latitude,
      longitude: longitude,
      cropType: cropType,
      acreage: acreage,
    );
  }
}

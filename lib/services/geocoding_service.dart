// geocoding_service.dart
// Looks up a place name (address, town, county) and returns candidate
// lat/lon matches, so a field's location isn't limited to GPS auto-detect.
// Uses Open-Meteo's free geocoding API — same provider as the weather data,
// no API key required.

import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodeResult {
  final String name;
  final String? admin1; // state/province
  final String? admin2; // county
  final String? country;
  final double latitude;
  final double longitude;

  GeocodeResult({
    required this.name,
    this.admin1,
    this.admin2,
    this.country,
    required this.latitude,
    required this.longitude,
  });

  /// Human-friendly label, e.g. "Yadkin County, North Carolina, United States"
  String get displayLabel {
    final parts = <String>[name];
    if (admin2 != null && admin2!.isNotEmpty && admin2 != name) parts.add(admin2!);
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) parts.add(admin1!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    return GeocodeResult(
      name: json['name'] ?? '',
      admin1: json['admin1'],
      admin2: json['admin2'],
      country: json['country'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class GeocodingService {
  static const String _baseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  /// Search for places matching [query] (a town, county, or address-like name).
  /// Returns an empty list on no matches or any failure — callers should
  /// show a friendly "no results" message rather than surfacing errors.
  static Future<List<GeocodeResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'name': trimmed,
      'count': '8',
      'language': 'en',
      'format': 'json',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = json['results'] as List?;
      if (results == null) return [];

      return results.map((e) => GeocodeResult.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}

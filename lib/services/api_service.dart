// api_service.dart
// Handles all communication with the FieldSense backend API.
// Provides specific, actionable error messages for common failure modes.

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/field_intelligence.dart';

class ApiService {
  static const String baseUrl = 'http://54.147.143.148:8002';

  static Future<FieldIntelligenceResponse> getFieldIntelligence(
      FieldIntelligenceRequest request) async {
    final uri = Uri.parse('$baseUrl/api/v1/fields/intelligence');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return FieldIntelligenceResponse.fromJson(json);
      } else if (response.statusCode == 503) {
        throw ApiException(
          'Weather data is temporarily unavailable. Please try again in a moment.',
          response.statusCode,
        );
      } else if (response.statusCode == 500) {
        throw ApiException(
          'Server error. Please try again shortly.',
          response.statusCode,
        );
      } else {
        throw ApiException(
          'Unexpected response from server (${response.statusCode}). Please try again.',
          response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(
        'No internet connection. Check your network and try again.',
      );
    } on HttpException {
      throw ApiException(
        'Could not reach FieldSense servers. Try again in a moment.',
      );
    } on FormatException {
      throw ApiException(
        'Received an unexpected response. Please try again.',
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('timeout') || msg.contains('timed out')) {
        throw ApiException(
          'Request timed out. Your connection may be slow — please try again.',
        );
      }
      throw ApiException(
        'Unable to load field data. Check your connection and try again.',
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

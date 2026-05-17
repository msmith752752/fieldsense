// api_service.dart
// Handles all communication with the FieldSense backend API.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/field_intelligence.dart';

class ApiService {
  // For local development, use your machine's IP so the phone can reach it.
  // Change this to your EC2 URL when you deploy.
  static const String baseUrl = 'http://127.0.0.1:8000';

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
      } else {
        throw ApiException(
          'Server returned ${response.statusCode}',
          response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Could not connect to FieldSense server. '
          'Make sure your backend is running.');
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

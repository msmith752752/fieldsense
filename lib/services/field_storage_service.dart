// field_storage_service.dart
// Handles saving and loading fields to local device storage.
// Fields persist between app sessions using shared_preferences.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/field_intelligence.dart';

class FieldStorageService {
  static const String _fieldsKey = 'saved_fields';

  /// Load all saved fields from device storage.
  static Future<List<SavedField>> loadFields() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_fieldsKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => SavedField.fromJson(e)).toList();
    } catch (e) {
      // If anything goes wrong reading storage, start fresh
      return [];
    }
  }

  /// Save the full list of fields to device storage.
  static Future<void> saveFields(List<SavedField> fields) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(fields.map((f) => f.toJson()).toList());
    await prefs.setString(_fieldsKey, jsonString);
  }

  /// Add a single field and persist.
  static Future<void> addField(
      List<SavedField> currentFields, SavedField newField) async {
    currentFields.add(newField);
    await saveFields(currentFields);
  }

  /// Remove a field by index and persist.
  static Future<void> removeField(
      List<SavedField> currentFields, int index) async {
    currentFields.removeAt(index);
    await saveFields(currentFields);
  }
}

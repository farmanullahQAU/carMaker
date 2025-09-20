// storage_service.dart
import 'dart:convert';

import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static const String _templatesKey = 'templates';
  static const String _draftsKey = 'drafts';
  static const String _favoritesKey = 'favorites';
  static final GetStorage _storage = GetStorage();

  static Future<void> init() async {
    await GetStorage.init();
  }

  // Save templates to local storage
  static Future<void> saveTemplates(
    List<CardTemplate> templates, {
    String type = 'templates',
  }) async {
    final jsonList = templates.map((template) => template.toJson()).toList();
    await _storage.write(_getKey(type), jsonEncode(jsonList));
  }

  // Load templates from local storage
  static List<CardTemplate> loadTemplates({String type = 'templates'}) {
    final jsonString = _storage.read(_getKey(type));
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => CardTemplate.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error parsing templates from storage: $e');
      return [];
    }
  }

  // Add a single template to local storage
  static Future<void> addTemplate(
    CardTemplate template, {
    String type = 'templates',
  }) async {
    final currentTemplates = loadTemplates(type: type);
    // Remove existing template with same ID if it exists
    currentTemplates.removeWhere((t) => t.id == template.id);
    currentTemplates.add(template);
    await saveTemplates(currentTemplates, type: type);
  }

  // Update an existing template in local storage
  static Future<void> updateTemplate(
    CardTemplate template, {
    String type = 'templates',
  }) async {
    final currentTemplates = loadTemplates(type: type);
    final index = currentTemplates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      currentTemplates[index] = template;
      await saveTemplates(currentTemplates, type: type);
    }
  }

  // Delete a template from local storage
  static Future<void> deleteTemplate(
    String templateId, {
    String type = 'templates',
  }) async {
    final currentTemplates = loadTemplates(type: type);
    currentTemplates.removeWhere((t) => t.id == templateId);
    await saveTemplates(currentTemplates, type: type);
  }

  // Clear all templates from local storage
  static Future<void> clearTemplates({String type = 'templates'}) async {
    await _storage.remove(_getKey(type));
  }

  // Get count of local templates
  static int getTemplateCount({String type = 'templates'}) {
    return loadTemplates(type: type).length;
  }

  // Check if template exists in local storage
  static bool templateExists(String templateId, {String type = 'templates'}) {
    final templates = loadTemplates(type: type);
    return templates.any((t) => t.id == templateId);
  }

  // Get templates that are only in local storage (not synced to Firebase)
  static List<CardTemplate> getLocalOnlyTemplates(
    List<CardTemplate> firebaseTemplates, {
    String type = 'templates',
  }) {
    final localTemplates = loadTemplates(type: type);
    final firebaseIds = firebaseTemplates.map((t) => t.id).toSet();
    return localTemplates
        .where((local) => !firebaseIds.contains(local.id))
        .toList();
  }

  // Helper method to get storage key based on type
  static String _getKey(String type) {
    switch (type) {
      case 'drafts':
        return _draftsKey;
      case 'favorites':
        return _favoritesKey;
      default:
        return _templatesKey;
    }
  }
}

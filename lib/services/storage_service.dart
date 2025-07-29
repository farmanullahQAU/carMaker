import 'dart:convert';

import 'package:cardmaker/models/card_template.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static const String _templatesKey = 'templates';
  static final GetStorage _storage = GetStorage();

  // Initialize storage (call this in main.dart before running the app)
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Save a list of CardTemplates to storage
  static Future<void> saveTemplates(List<CardTemplate> templates) async {
    final jsonList = templates.map((template) => template.toJson()).toList();
    await _storage.write(_templatesKey, jsonEncode(jsonList));
  }

  // Load templates from storage
  static List<CardTemplate> loadTemplates() {
    final jsonString = _storage.read(_templatesKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => CardTemplate.fromJson(json)).toList();
  }

  // Add a single template to storage
  static Future<void> addTemplate(CardTemplate template) async {
    final currentTemplates = loadTemplates();
    currentTemplates.add(template);
    await saveTemplates(currentTemplates);
  }

  // Update an existing template in storage
  static Future<void> updateTemplate(CardTemplate template) async {
    final currentTemplates = loadTemplates();
    final index = currentTemplates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      currentTemplates[index] = template;
      await saveTemplates(currentTemplates);
    }
  }

  // Delete a template from storage
  static Future<void> deleteTemplate(String templateId) async {
    final currentTemplates = loadTemplates();
    currentTemplates.removeWhere((t) => t.id == templateId);
    await saveTemplates(currentTemplates);
  }

  // Clear all templates from storage
  static Future<void> clearTemplates() async {
    await _storage.remove(_templatesKey);
  }
}

// import 'dart:convert';

// import 'package:cardmaker/models/card_template.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get_storage/get_storage.dart';

// class StorageService {
//   static const String _templatesKey = 'templates';
//   static const String _draftsKey = 'drafts';
//   static const String _favoritesKey = 'favorites';
//   static final GetStorage _storage = GetStorage();

//   /// Initialize GetStorage
//   static Future<void> init() async {
//     await GetStorage.init();
//   }

//   /// Save templates to local storage (automatically handles duplicates by ID)
//   static Future<void> saveTemplates(
//     List<CardTemplate> templates, {
//     String type = 'templates',
//   }) async {
//     try {
//       // Convert to map with ID as key for automatic duplicate handling
//       final templatesMap = {
//         for (var template in templates) template.id: template.toJson(),
//       };
//       await _storage.write(_getKey(type), jsonEncode(templatesMap));
//     } catch (e) {
//       debugPrint('Error saving templates to storage: $e');
//       rethrow;
//     }
//   }

//   /// Load templates from local storage
//   static List<CardTemplate> loadTemplates({String type = 'templates'}) {
//     final jsonString = _storage.read(_getKey(type));
//     if (jsonString == null || jsonString.isEmpty) return [];

//     try {
//       final Map<String, dynamic> templatesMap = Map<String, dynamic>.from(
//         jsonDecode(jsonString) as Map,
//       );

//       return templatesMap.values
//           .map((json) => CardTemplate.fromJson(json as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       debugPrint('Error parsing templates from storage: $e');
//       return [];
//     }
//   }

//   /// Add or update a single template (direct map operation - no loading entire list)
//   static Future<void> addTemplate(
//     CardTemplate template, {
//     String type = 'templates',
//   }) async {
//     try {
//       final jsonString = _storage.read(_getKey(type));
//       Map<String, dynamic> templatesMap = {};

//       if (jsonString != null && jsonString.isNotEmpty) {
//         templatesMap = Map<String, dynamic>.from(jsonDecode(jsonString) as Map);
//       }

//       // Directly add/update the template in the map
//       templatesMap[template.id] = template.toJson();

//       await _storage.write(_getKey(type), jsonEncode(templatesMap));
//     } catch (e) {
//       debugPrint('Error adding template to storage: $e');
//       rethrow;
//     }
//   }

//   /// Delete a template (direct map operation - no loading entire list)
//   static Future<void> deleteTemplate(
//     String templateId, {
//     String type = 'templates',
//   }) async {
//     try {
//       final jsonString = _storage.read(_getKey(type));
//       if (jsonString == null || jsonString.isEmpty) return;

//       final templatesMap = Map<String, dynamic>.from(
//         jsonDecode(jsonString) as Map,
//       );
//       templatesMap.remove(templateId);

//       await _storage.write(_getKey(type), jsonEncode(templatesMap));
//     } catch (e) {
//       debugPrint('Error deleting template from storage: $e');
//       rethrow;
//     }
//   }

//   /// Get template by ID (direct map lookup - O(1))
//   static CardTemplate? getTemplate(
//     String templateId, {
//     String type = 'templates',
//   }) {
//     final jsonString = _storage.read(_getKey(type));
//     if (jsonString == null || jsonString.isEmpty) return null;

//     try {
//       final templatesMap = Map<String, dynamic>.from(
//         jsonDecode(jsonString) as Map,
//       );
//       final templateJson = templatesMap[templateId];
//       return templateJson != null
//           ? CardTemplate.fromJson(templateJson as Map<String, dynamic>)
//           : null;
//     } catch (e) {
//       debugPrint('Error getting template from storage: $e');
//       return null;
//     }
//   }

//   /// Get templates that are only in local storage
//   static List<CardTemplate> getLocalOnlyTemplates(
//     List<CardTemplate> firebaseTemplates, {
//     String type = 'templates',
//   }) {
//     final localTemplates = loadTemplates(type: type);
//     final firebaseIds = firebaseTemplates.map((t) => t.id).toSet();
//     return localTemplates.where((t) => !firebaseIds.contains(t.id)).toList();
//   }

//   /// Helper method to get storage key based on type
//   static String _getKey(String type) {
//     switch (type) {
//       case 'drafts':
//         return _draftsKey;
//       case 'favorites':
//         return _favoritesKey;
//       default:
//         return _templatesKey;
//     }
//   }
// }
import 'dart:convert';

import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static const String _draftsKey = 'drafts';
  static final GetStorage _storage = GetStorage();

  /// Initialize GetStorage
  static Future<void> init() async {
    await GetStorage.init();
  }

  /// Save drafts to local storage (automatically handles duplicates by ID)
  static Future<void> saveDrafts(List<CardTemplate> drafts) async {
    try {
      // Convert to map with ID as key for automatic duplicate handling
      final draftsMap = {for (var draft in drafts) draft.id: draft.toJson()};
      await _storage.write(_draftsKey, jsonEncode(draftsMap));
    } catch (e) {
      debugPrint('Error saving drafts to storage: $e');
      rethrow;
    }
  }

  /// Load drafts from local storage
  static List<CardTemplate> loadDrafts() {
    final jsonString = _storage.read(_draftsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final Map<String, dynamic> draftsMap = Map<String, dynamic>.from(
        jsonDecode(jsonString) as Map,
      );

      return draftsMap.values
          .map((json) => CardTemplate.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error parsing drafts from storage: $e');
      return [];
    }
  }

  /// Add or update a single draft (direct map operation)
  static Future<void> addDraft(CardTemplate draft) async {
    try {
      final jsonString = _storage.read(_draftsKey);
      Map<String, dynamic> draftsMap = {};

      if (jsonString != null && jsonString.isNotEmpty) {
        draftsMap = Map<String, dynamic>.from(jsonDecode(jsonString) as Map);
      }

      // Directly add/update the draft in the map
      draftsMap[draft.id] = draft.toJson();

      await _storage.write(_draftsKey, jsonEncode(draftsMap));
    } catch (e) {
      debugPrint('Error adding draft to storage: $e');
      rethrow;
    }
  }

  /// Delete a draft (direct map operation)
  static Future<void> deleteDraft(String draftId) async {
    try {
      final jsonString = _storage.read(_draftsKey);
      if (jsonString == null || jsonString.isEmpty) return;

      final draftsMap = Map<String, dynamic>.from(
        jsonDecode(jsonString) as Map,
      );
      draftsMap.remove(draftId);

      await _storage.write(_draftsKey, jsonEncode(draftsMap));
    } catch (e) {
      debugPrint('Error deleting draft from storage: $e');
      rethrow;
    }
  }

  /// Get draft by ID (direct map lookup - O(1))
  static CardTemplate? getDraft(String draftId) {
    final jsonString = _storage.read(_draftsKey);
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final draftsMap = Map<String, dynamic>.from(
        jsonDecode(jsonString) as Map,
      );
      final draftJson = draftsMap[draftId];
      return draftJson != null
          ? CardTemplate.fromJson(draftJson as Map<String, dynamic>)
          : null;
    } catch (e) {
      debugPrint('Error getting draft from storage: $e');
      return null;
    }
  }

  /// Get drafts that are only in local storage (not synced to Firebase)
  static List<CardTemplate> getLocalOnlyDrafts(
    List<CardTemplate> firebaseDrafts,
  ) {
    final localDrafts = loadDrafts();
    final firebaseIds = firebaseDrafts.map((draft) => draft.id).toSet();
    return localDrafts
        .where((draft) => !firebaseIds.contains(draft.id))
        .toList();
  }
}

import 'dart:convert';

import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  // Singleton instance
  static final StorageService _instance = StorageService._internal();

  // Factory constructor to return the singleton instance
  factory StorageService() {
    return _instance;
  }

  // Private constructor
  StorageService._internal();

  // Static storage keys
  static const String _draftsKey = 'drafts';
  static const String _favoriteIdsKey = 'favorite_template_ids';

  // GetStorage instance
  static final GetStorage _storage = GetStorage();

  // Initialize GetStorage (called once during app startup)
  Future<void> init() async {
    await GetStorage.init();
  }

  /// Save drafts to local storage (automatically handles duplicates by ID)
  Future<void> saveDrafts(List<CardTemplate> drafts) async {
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
  List<CardTemplate> getLocalOnlyDrafts(List<CardTemplate> firebaseDrafts) {
    final localDrafts = loadDrafts();
    final firebaseIds = firebaseDrafts.map((draft) => draft.id).toSet();
    return localDrafts
        .where((draft) => !firebaseIds.contains(draft.id))
        .toList();
  }

  /// Save favorite template IDs to local storage
  static Future<void> saveFavoriteIds(List<String> favoriteIds) async {
    try {
      await _storage.write(_favoriteIdsKey, jsonEncode(favoriteIds));
    } catch (e) {
      debugPrint('Error saving favorite IDs to storage: $e');
      rethrow;
    }
  }

  /// Load favorite template IDs from local storage
  static List<String> loadFavoriteIds() {
    final jsonString = _storage.read(_favoriteIdsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      return List<String>.from(jsonDecode(jsonString));
    } catch (e) {
      debugPrint('Error parsing favorite IDs from storage: $e');
      return [];
    }
  }

  /// Add a single favorite template ID
  static Future<void> addFavoriteId(String favoriteId) async {
    try {
      final favoriteIds = loadFavoriteIds();
      if (!favoriteIds.contains(favoriteId)) {
        favoriteIds.add(favoriteId);
        await saveFavoriteIds(favoriteIds);
      }
    } catch (e) {
      debugPrint('Error adding favorite ID to storage: $e');
      rethrow;
    }
  }

  /// Remove a single favorite template ID
  static Future<void> removeFavoriteId(String favoriteId) async {
    try {
      final favoriteIds = loadFavoriteIds();
      favoriteIds.remove(favoriteId);
      await saveFavoriteIds(favoriteIds);
    } catch (e) {
      debugPrint('Error removing favorite ID to storage: $e');
      rethrow;
    }
  }

  /// Check if a template ID is in favorites
  static bool isFavorite(String favoriteId) {
    final favoriteIds = loadFavoriteIds();
    return favoriteIds.contains(favoriteId);
  }

  /// Write generic data to storage
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key, value);
    } catch (e) {
      debugPrint('Error writing to storage: $e');
      rethrow;
    }
  }

  /// Read generic data from storage
  dynamic read(String key) {
    try {
      return _storage.read(key);
    } catch (e) {
      debugPrint('Error reading from storage: $e');
      return null;
    }
  }
}

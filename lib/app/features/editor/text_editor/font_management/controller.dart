import 'dart:async';

import 'package:cardmaker/services/firebase_font_service.dart';
import 'package:cardmaker/services/urdu_font_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FontManagementController extends GetxController {
  // Observable lists
  final RxList<UrduFont> localFonts = <UrduFont>[].obs;
  final RxList<UrduFont> remoteFonts = <UrduFont>[].obs;
  final RxList<UrduFont> allFonts = <UrduFont>[].obs;

  // Loading states
  final RxBool isLoadingRemoteFonts = false.obs;
  final RxBool isDownloadingFont = false.obs;
  final RxBool isDeletingFont = false.obs;

  // Download progress
  final RxMap<String, double> downloadProgress = <String, double>{}.obs;

  // Storage info
  final RxInt totalDownloadedSize = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFonts();
  }

  Future<void> _initializeFonts() async {
    // Load local fonts immediately (no loading needed)
    localFonts.value = UrduFontService.localFonts;
    allFonts.value = UrduFontService.allFonts;

    // Try to hydrate from cache for instant UI
    final bool cacheLoaded = await UrduFontService.loadFontsFromCache();
    if (cacheLoaded) {
      remoteFonts.value = UrduFontService.remoteFonts;
      allFonts.value = UrduFontService.allFonts;
    }

    // Always fetch latest fonts in background
    Future.microtask(() => loadRemoteFonts(forceRefresh: true));

    // Calculate storage size
    _calculateStorageSize();
  }

  /// Load remote fonts from Firebase
  Future<void> loadRemoteFonts({bool forceRefresh = false}) async {
    // Don't show loading if fonts are already loaded and no refresh requested
    if (!forceRefresh &&
        UrduFontService.remoteFonts.isNotEmpty &&
        !isLoadingRemoteFonts.value) {
      remoteFonts.value = UrduFontService.remoteFonts;
      allFonts.value = UrduFontService.allFonts;
      return;
    }

    isLoadingRemoteFonts.value = true;
    try {
      await UrduFontService.loadRemoteFonts(forceRefresh: forceRefresh);
      remoteFonts.value = UrduFontService.remoteFonts;
      allFonts.value = UrduFontService.allFonts;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load remote fonts: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingRemoteFonts.value = false;
    }
  }

  /// Refresh fonts from Firebase Storage
  Future<void> refreshFonts() async {
    isLoadingRemoteFonts.value = true;
    try {
      await UrduFontService.refreshFonts();
      remoteFonts.value = UrduFontService.remoteFonts;
      allFonts.value = UrduFontService.allFonts;

      Get.snackbar(
        'Success',
        'Fonts refreshed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh fonts: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingRemoteFonts.value = false;
    }
  }

  /// Download a font
  Future<bool> downloadFont(UrduFont font) async {
    if (font.remoteFont == null) return false;

    isDownloadingFont.value = true;
    downloadProgress[font.family] = 0.0;
    bool wasSuccessful = false;

    try {
      // Simulate progress (Firebase doesn't provide real-time progress)
      _simulateDownloadProgress(font.family);

      final bool success = await UrduFontService.downloadFont(font);

      if (success) {
        // Update the font status locally (quick)
        final int index = remoteFonts.indexWhere(
          (f) => f.family == font.family,
        );
        if (index != -1) {
          remoteFonts[index] = remoteFonts[index].copyWith(isLocal: true);
        }
        allFonts.value = [...localFonts, ...remoteFonts];

        Get.snackbar(
          'Success',
          '${font.displayName} downloaded successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        wasSuccessful = true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to download ${font.displayName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download font: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDownloadingFont.value = false;
      downloadProgress.remove(font.family);
    }

    return wasSuccessful;
  }

  /// Delete a downloaded font
  Future<void> deleteFont(UrduFont font) async {
    if (font.remoteFont == null || !font.isLocal) return;

    isDeletingFont.value = true;

    try {
      final bool success = await UrduFontService.deleteFont(font);

      if (success) {
        // Update font status
        final int index = remoteFonts.indexWhere(
          (f) => f.family == font.family,
        );
        if (index != -1) {
          remoteFonts[index] = font.copyWith(isLocal: false);
          allFonts.value = UrduFontService.allFonts;
        }

        // Calculate new storage size
        await _calculateStorageSize();

        Get.snackbar(
          'Success',
          '${font.displayName} deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete ${font.displayName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete font: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeletingFont.value = false;
    }
  }

  /// Get fonts by category
  List<UrduFont> getFontsByCategory(UrduFontCategory category) {
    return allFonts.where((font) => font.category == category).toList();
  }

  /// Search fonts
  List<UrduFont> searchFonts(String query) {
    if (query.isEmpty) return allFonts;

    return allFonts.where((font) {
      return font.displayName.toLowerCase().contains(query.toLowerCase()) ||
          font.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Get downloaded fonts count
  int get downloadedFontsCount {
    return remoteFonts.where((font) => font.isLocal).length;
  }

  /// Get available fonts count
  int get availableFontsCount {
    return remoteFonts.length;
  }

  /// Get formatted storage size
  String get formattedStorageSize {
    return FirebaseFontService.formatFileSize(totalDownloadedSize.value);
  }

  /// Calculate total storage size
  Future<void> _calculateStorageSize() async {
    try {
      totalDownloadedSize.value =
          await FirebaseFontService.getDownloadedFontsSize();
    } catch (e) {
      print('Error calculating storage size: $e');
    }
  }

  /// Simulate download progress
  void _simulateDownloadProgress(String fontFamily) {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (downloadProgress[fontFamily] == null) {
        timer.cancel();
        return;
      }

      downloadProgress[fontFamily] = (downloadProgress[fontFamily]! + 0.1)
          .clamp(0.0, 1.0);

      if (downloadProgress[fontFamily]! >= 1.0) {
        timer.cancel();
      }
    });
  }

  /// Clear all downloaded fonts
  Future<void> clearAllDownloadedFonts() async {
    final List<UrduFont> downloadedFonts = remoteFonts
        .where((font) => font.isLocal)
        .toList();

    for (final font in downloadedFonts) {
      await deleteFont(font);
    }
  }
}

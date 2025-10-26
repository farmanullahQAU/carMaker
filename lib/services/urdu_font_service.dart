import 'package:flutter/material.dart';

import 'firebase_font_service.dart';

class UrduFontService {
  // Local compressed fonts (always available)
  static const List<UrduFont> localFonts = [
    UrduFont(
      family: 'AadilAadil',
      displayName: 'Aadil Aadil',
      category: UrduFontCategory.traditional,
      previewText: 'اردو فونٹس کا بہترین مجموعہ',
      description: 'Beautiful traditional Urdu font',
      isRTL: true,
      isLocal: true,
    ),
    UrduFont(
      family: 'GandharaSulsRegular',
      displayName: 'Gandhara Suls Regular',
      category: UrduFontCategory.traditional,
      previewText: 'خوشخط اردو تحریر کے لیے',
      description: 'Traditional Nastaleeq style with elegant curves',
      isRTL: true,
      isLocal: true,
    ),
  ];

  // Remote fonts from Firebase Storage
  static final List<UrduFont> remoteFonts = [];

  // Cache to track downloaded fonts
  static final Map<String, String> _downloadedFontsCache = {};

  // All fonts (local + remote)
  static List<UrduFont> get allFonts => [...localFonts, ...remoteFonts];

  /// Load remote fonts from Firebase Storage (efficient, lazy loading)
  static Future<void> loadRemoteFonts({
    bool autoDownload = false,
    int limit = 100, // Load 100 fonts at a time
  }) async {
    try {
      final List<RemoteFont> firebaseFonts =
          await FirebaseFontService.getAvailableFonts();

      remoteFonts.clear();

      // Process only first 'limit' fonts to avoid performance issues
      final int fontsToProcess = firebaseFonts.length > limit
          ? limit
          : firebaseFonts.length;

      for (int i = 0; i < fontsToProcess; i++) {
        final RemoteFont firebaseFont = firebaseFonts[i];

        // Skip fonts that are already local
        if (localFonts.any((local) => local.family == firebaseFont.family)) {
          continue;
        }

        final bool isDownloaded = await _isFontDownloaded(firebaseFont.family);

        remoteFonts.add(
          UrduFont(
            family: firebaseFont.family,
            displayName: firebaseFont.name,
            category: _getCategoryFromPath(firebaseFont.fileName),
            previewText: _getPreviewTextForFont(firebaseFont.name),
            description: _getDescriptionForFont(firebaseFont.name),
            isRTL: true,
            isLocal: isDownloaded,
            remoteFont: firebaseFont,
          ),
        );

        // Auto-download if enabled and not already downloaded
        if (autoDownload && !isDownloaded) {
          _downloadFontInBackground(firebaseFont);
        }
      }

      // Load remaining fonts in background (async, non-blocking)
      if (firebaseFonts.length > limit) {
        _loadRemainingFontsInBackground(firebaseFonts.sublist(limit));
      }
    } catch (e) {
      print('Error loading remote fonts: $e');
    }
  }

  /// Load remaining fonts in background (non-blocking)
  static Future<void> _loadRemainingFontsInBackground(
    List<RemoteFont> remainingFonts,
  ) async {
    for (final RemoteFont firebaseFont in remainingFonts) {
      try {
        // Skip fonts that are already local
        if (localFonts.any((local) => local.family == firebaseFont.family)) {
          continue;
        }

        final bool isDownloaded = await _isFontDownloaded(firebaseFont.family);

        if (!isDownloaded) {
          // Download in background
          _downloadFontInBackground(firebaseFont);
        }
      } catch (e) {
        print('Error processing font in background: $e');
      }
    }
  }

  /// Refresh fonts from Firebase Storage
  static Future<void> refreshFonts({bool autoDownload = false}) async {
    await FirebaseFontService.refreshFonts();
    await loadRemoteFonts(autoDownload: autoDownload);
  }

  /// Check if a font is already downloaded locally
  static Future<bool> _isFontDownloaded(String fontFamily) async {
    if (_downloadedFontsCache.containsKey(fontFamily)) {
      return true;
    }

    final String? localPath = FirebaseFontService.getLocalFontPath(fontFamily);
    if (localPath != null) {
      _downloadedFontsCache[fontFamily] = localPath;
      return true;
    }
    return false;
  }

  /// Download a font in the background (non-blocking UI)
  static Future<void> _downloadFontInBackground(RemoteFont font) async {
    try {
      // Download in isolate to avoid freezing UI
      final bool success = await FirebaseFontService.downloadFont(font);

      if (success) {
        _downloadedFontsCache[font.family] =
            FirebaseFontService.getLocalFontPath(font.family) ?? '';

        // Update the font status in remoteFonts list
        final int index = remoteFonts.indexWhere(
          (f) => f.family == font.family,
        );
        if (index != -1) {
          remoteFonts[index] = remoteFonts[index].copyWith(isLocal: true);
        }
      }
    } catch (e) {
      print('Error downloading font in background: $e');
    }
  }

  /// Download a single font (blocking, with progress indication)
  static Future<bool> downloadFont(UrduFont font) async {
    if (font.remoteFont == null || font.isLocal) return true;

    try {
      final bool success = await FirebaseFontService.downloadFont(
        font.remoteFont!,
      );

      if (success) {
        _downloadedFontsCache[font.family] =
            FirebaseFontService.getLocalFontPath(font.family) ?? '';

        // Update the font status
        final int index = remoteFonts.indexWhere(
          (f) => f.family == font.family,
        );
        if (index != -1) {
          remoteFonts[index] = remoteFonts[index].copyWith(isLocal: true);
        }
      }

      return success;
    } catch (e) {
      print('Error downloading font: $e');
      return false;
    }
  }

  /// Delete a downloaded font
  static Future<bool> deleteFont(UrduFont font) async {
    if (font.remoteFont == null || !font.isLocal) return false;

    try {
      final bool success = await FirebaseFontService.deleteFont(
        font.remoteFont!,
      );
      if (success) {
        _downloadedFontsCache.remove(font.family);

        // Update the font status
        final int index = remoteFonts.indexWhere(
          (f) => f.family == font.family,
        );
        if (index != -1) {
          remoteFonts[index] = remoteFonts[index].copyWith(isLocal: false);
        }
      }
      return success;
    } catch (e) {
      print('Error deleting font: $e');
      return false;
    }
  }

  static List<UrduFont> getFontsByCategory(UrduFontCategory category) {
    return allFonts.where((font) => font.category == category).toList();
  }

  static UrduFont? getFontByFamily(String family) {
    try {
      return allFonts.firstWhere((font) => font.family == family);
    } catch (e) {
      return null;
    }
  }

  static List<UrduFont> searchFonts(String query) {
    if (query.isEmpty) return allFonts;

    return allFonts.where((font) {
      return font.displayName.toLowerCase().contains(query.toLowerCase()) ||
          font.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  static TextStyle getTextStyle({
    required String fontFamily,
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    double letterSpacing = 0.0,
    double height = 1.2,
  }) {
    // Font family name works directly - Flutter resolves it properly
    // For local fonts: registered via pubspec.yaml
    // For downloaded fonts: registered via FontLoader in download process

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Get category based on font path
  static UrduFontCategory _getCategoryFromPath(String fileName) {
    final String lowerName = fileName.toLowerCase();
    if (lowerName.contains('traditional')) {
      return UrduFontCategory.traditional;
    } else if (lowerName.contains('modern')) {
      return UrduFontCategory.modern;
    } else if (lowerName.contains('contemporary')) {
      return UrduFontCategory.contemporary;
    } else if (lowerName.contains('decorative')) {
      return UrduFontCategory.decorative;
    } else {
      // Default category based on font name
      return _getCategoryFromName(fileName);
    }
  }

  /// Get category based on font name
  static UrduFontCategory _getCategoryFromName(String name) {
    final String lowerName = name.toLowerCase();
    if (lowerName.contains('nastaleeq') || lowerName.contains('traditional')) {
      return UrduFontCategory.traditional;
    } else if (lowerName.contains('modern') || lowerName.contains('unicode')) {
      return UrduFontCategory.modern;
    } else {
      return UrduFontCategory.contemporary;
    }
  }

  /// Get preview text based on font name
  static String _getPreviewTextForFont(String name) {
    final String lowerName = name.toLowerCase();
    if (lowerName.contains('nastaleeq')) {
      return 'اردو فونٹس کا بہترین مجموعہ';
    } else if (lowerName.contains('unicode')) {
      return 'جدید اردو ٹائپوگرافی';
    } else if (lowerName.contains('suls')) {
      return 'صاف اور واضح اردو متن';
    } else {
      return 'خوشخط اردو تحریر کے لیے';
    }
  }

  /// Get description based on font name
  static String _getDescriptionForFont(String name) {
    final String lowerName = name.toLowerCase();
    if (lowerName.contains('jameel')) {
      return 'Classic Nastaleeq calligraphy style';
    } else if (lowerName.contains('akram')) {
      return 'Modern Unicode Urdu font';
    } else if (lowerName.contains('gandhara')) {
      return 'Contemporary Urdu font design';
    } else if (lowerName.contains('bbc')) {
      return 'Media-style Urdu typography';
    } else if (lowerName.contains('alvi')) {
      return 'Beautiful traditional Nastaleeq';
    } else if (lowerName.contains('mehr')) {
      return 'Web-optimized Nastaliq font';
    } else if (lowerName.contains('nafees')) {
      return 'Clean and clear Urdu typography';
    } else {
      return 'Professional Urdu font';
    }
  }
}

class UrduFont {
  final String family;
  final String displayName;
  final UrduFontCategory category;
  final String previewText;
  final String description;
  final bool isRTL;
  final bool isLocal;
  final RemoteFont? remoteFont;

  const UrduFont({
    required this.family,
    required this.displayName,
    required this.category,
    required this.previewText,
    required this.description,
    required this.isRTL,
    required this.isLocal,
    this.remoteFont,
  });

  UrduFont copyWith({
    String? family,
    String? displayName,
    UrduFontCategory? category,
    String? previewText,
    String? description,
    bool? isRTL,
    bool? isLocal,
    RemoteFont? remoteFont,
  }) {
    return UrduFont(
      family: family ?? this.family,
      displayName: displayName ?? this.displayName,
      category: category ?? this.category,
      previewText: previewText ?? this.previewText,
      description: description ?? this.description,
      isRTL: isRTL ?? this.isRTL,
      isLocal: isLocal ?? this.isLocal,
      remoteFont: remoteFont ?? this.remoteFont,
    );
  }
}

enum UrduFontCategory { traditional, modern, contemporary, decorative }

extension UrduFontCategoryExtension on UrduFontCategory {
  String get displayName {
    switch (this) {
      case UrduFontCategory.traditional:
        return 'Traditional';
      case UrduFontCategory.modern:
        return 'Modern';
      case UrduFontCategory.contemporary:
        return 'Contemporary';
      case UrduFontCategory.decorative:
        return 'Decorative';
    }
  }

  String get description {
    switch (this) {
      case UrduFontCategory.traditional:
        return 'Classic Nastaleeq calligraphy';
      case UrduFontCategory.modern:
        return 'Modern Urdu typography';
      case UrduFontCategory.contemporary:
        return 'Contemporary Urdu design';
      case UrduFontCategory.decorative:
        return 'Ornamental Urdu styles';
    }
  }
}

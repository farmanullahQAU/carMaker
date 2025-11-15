import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FirebaseFontService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _fontsPath = 'fonts/urdu/';

  // Cache for downloaded fonts
  static final Map<String, String> _downloadedFonts = {};

  // Font registry - tracks all available fonts
  static final Map<String, RemoteFont> _fontRegistry = {};

  // Flag to track if cache has been initialized
  static bool _cacheInitialized = false;

  /// Initialize the cache by scanning the fonts directory
  static Future<void> _initializeCache() async {
    if (_cacheInitialized) return;

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fontsDir = path.join(appDir.path, 'fonts', 'urdu');
      final Directory dir = Directory(fontsDir);

      if (await dir.exists()) {
        final List<FileSystemEntity> files = await dir.list().toList();
        for (final file in files) {
          if (file is File && file.path.endsWith('.ttf')) {
            // Extract font family from filename
            final String fileName = path.basename(file.path);
            final String fontFamily = _getFontFamily(fileName);
            _downloadedFonts[fontFamily] = file.path;

            // Re-register the font with Flutter's font system
            await _registerDownloadedFont(fontFamily, file);
          }
        }
      }
      _cacheInitialized = true;
      print('✅ Font cache initialized with ${_downloadedFonts.length} fonts');
    } catch (e) {
      print('❌ Error initializing font cache: $e');
    }
  }

  /// Public method to initialize font cache (called on app startup)
  static Future<void> initializeFontCache() async {
    await _initializeCache();
  }

  /// Get list of available fonts from Firebase Storage
  static Future<List<RemoteFont>> getAvailableFonts() async {
    try {
      // Initialize cache on first call
      await _initializeCache();

      // If already loaded, return cached fonts
      if (_fontRegistry.isNotEmpty) {
        return _fontRegistry.values.toList();
      }

      final ListResult result = await _storage.ref(_fontsPath).listAll();
      final List<RemoteFont> fonts = [];

      // Batch check all fonts at once for better performance
      final List<Reference> refs = result.items.toList();

      // Initialize cache and check all fonts in one go
      await _initializeCache();
      final Set<String> downloadedFamilies = _downloadedFonts.keys.toSet();

      for (final Reference ref in refs) {
        final String fileName = ref.name;
        final String fontName = _getFontDisplayName(fileName);
        final String fontFamily = _getFontFamily(fileName);

        // Get metadata
        final FullMetadata metadata = await ref.getMetadata();
        final int sizeInBytes = metadata.size ?? 0;

        // Use cached downloaded status (much faster)
        final bool isDownloaded = downloadedFamilies.contains(fontFamily);

        final RemoteFont font = RemoteFont(
          id: fileName,
          name: fontName,
          family: fontFamily,
          fileName: fileName,
          sizeInBytes: sizeInBytes,
          downloadUrl: await ref.getDownloadURL(),
          isDownloaded: isDownloaded,
        );

        fonts.add(font);
        _fontRegistry[fontFamily] = font; // Cache the font
      }

      return fonts;
    } catch (e) {
      print('Error fetching fonts from Firebase: $e');
      return [];
    }
  }

  /// Download a font from Firebase Storage
  static Future<bool> downloadFont(RemoteFont font) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fontsDir = path.join(appDir.path, 'fonts', 'urdu');

      // Create fonts directory if it doesn't exist
      await Directory(fontsDir).create(recursive: true);

      final String localPath = path.join(fontsDir, font.fileName);
      final File localFile = File(localPath);

      // Download the font file
      final Reference ref = _storage.ref('$_fontsPath${font.fileName}');
      await ref.writeToFile(localFile);

      // Register the font with Flutter's font system using FontLoader
      if (!_downloadedFonts.containsKey(font.family)) {
        await _registerDownloadedFont(font.family, localFile);
      }

      // Cache the downloaded font
      _downloadedFonts[font.family] = localPath;

      // Update the font registry to mark as downloaded
      if (_fontRegistry.containsKey(font.family)) {
        _fontRegistry[font.family] = font.copyWith(isDownloaded: true);
      }

      return true;
    } catch (e) {
      print('Error downloading font ${font.name}: $e');
      return false;
    }
  }

  /// Register a downloaded font with Flutter's font system
  static Future<void> _registerDownloadedFont(
    String fontFamily,
    File fontFile,
  ) async {
    try {
      // Read font file as bytes
      final List<int> fontData = await fontFile.readAsBytes();

      // Create ByteData from the bytes
      final ByteData byteData = ByteData.view(
        Uint8List.fromList(fontData).buffer,
      );

      // Register font using FontLoader
      final FontLoader fontLoader = FontLoader(fontFamily);
      fontLoader.addFont(Future.value(byteData));
      await fontLoader.load();

      print('✅ Font registered: $fontFamily');
    } catch (e) {
      print('❌ Error registering font $fontFamily: $e');
    }
  }

  /// Refresh fonts from Firebase Storage
  static Future<void> refreshFonts() async {
    _fontRegistry.clear();
    await getAvailableFonts();
  }

  /// Check if a font is already downloaded
  static Future<bool> _isFontDownloaded(String fontFamily) async {
    // Initialize cache if not already done
    await _initializeCache();

    // Check if already in cache
    if (_downloadedFonts.containsKey(fontFamily)) {
      return true;
    }

    return false;
  }

  /// Get local path of downloaded font
  static String? getLocalFontPath(String fontFamily) {
    return _downloadedFonts[fontFamily];
  }

  /// Public method to check if font is downloaded
  static Future<bool> isFontDownloaded(String fontFamily) async {
    return await _isFontDownloaded(fontFamily);
  }

  /// Download font in background (non-blocking)
  static Future<void> downloadFontInBackground(RemoteFont font) async {
    try {
      await downloadFont(font);
    } catch (e) {
      print('Error downloading font in background: $e');
    }
  }

  /// Delete a downloaded font
  static Future<bool> deleteFont(RemoteFont font) async {
    try {
      final String? localPath = _downloadedFonts[font.family];
      if (localPath != null) {
        final File file = File(localPath);
        if (await file.exists()) {
          await file.delete();
          _downloadedFonts.remove(font.family);
          return true;
        }
      }
    } catch (e) {
      print('Error deleting font ${font.name}: $e');
    }
    return false;
  }

  /// Get total size of downloaded fonts
  static Future<int> getDownloadedFontsSize() async {
    int totalSize = 0;
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fontsDir = path.join(appDir.path, 'fonts', 'urdu');
      final Directory dir = Directory(fontsDir);

      if (await dir.exists()) {
        final List<FileSystemEntity> files = await dir.list().toList();
        for (final file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
    } catch (e) {
      print('Error calculating fonts size: $e');
    }
    return totalSize;
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Extract font display name from filename
  static String _getFontDisplayName(String fileName) {
    // Remove .ttf extension and format nicely
    String name = fileName.replaceAll('.ttf', '');
    // Replace underscores and hyphens with spaces
    name = name.replaceAll(RegExp(r'[_\-]'), ' ');
    // Capitalize words
    return name
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join(' ');
  }

  /// Extract font family from filename
  static String _getFontFamily(String fileName) {
    // Remove .ttf extension and replace spaces with nothing
    return fileName.replaceAll('.ttf', '').replaceAll(' ', '');
  }
}

class RemoteFont {
  final String id;
  final String name;
  final String family;
  final String fileName;
  final int sizeInBytes;
  final String downloadUrl;
  final bool isDownloaded;

  const RemoteFont({
    required this.id,
    required this.name,
    required this.family,
    required this.fileName,
    required this.sizeInBytes,
    required this.downloadUrl,
    required this.isDownloaded,
  });

  String get formattedSize => FirebaseFontService.formatFileSize(sizeInBytes);

  RemoteFont copyWith({
    String? id,
    String? name,
    String? family,
    String? fileName,
    int? sizeInBytes,
    String? downloadUrl,
    bool? isDownloaded,
  }) {
    return RemoteFont(
      id: id ?? this.id,
      name: name ?? this.name,
      family: family ?? this.family,
      fileName: fileName ?? this.fileName,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cardmaker/core/utils/toast_helper.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class DesignExportService {
  // Magic header to identify .artnie files
  static const String _magicHeader = 'ARTNIE';
  static const int _version = 1;

  /// Export design as .artnie file (encoded and optionally compressed)
  /// Returns the file path if successful, null otherwise
  /// [compress] - If false, saves uncompressed JSON (larger file but faster)
  Future<String?> exportDesignAsArtnie(
    CardTemplate template, {
    String? customFileName,
    bool compress = true,
  }) async {
    try {
      // Convert template to JSON
      final jsonData = jsonEncode(template.toJson());

      List<int> artnieData;
      if (compress) {
        // Compress the JSON using gzip
        final compressed = GZipEncoder().encode(utf8.encode(jsonData));
        // Create the .artnie file format:
        // [Magic Header (6 bytes)] [Version (1 byte)] [Compressed Data]
        final header = utf8.encode(_magicHeader);
        final versionByte = [_version];
        artnieData = [...header, ...versionByte, ...compressed];
      } else {
        // Save uncompressed (just JSON with header)
        final header = utf8.encode(_magicHeader);
        final versionByte = [_version];
        final jsonBytes = utf8.encode(jsonData);
        artnieData = [...header, ...versionByte, ...jsonBytes];
      }

      // Generate filename
      final fileName =
          customFileName ??
          '${template.name.replaceAll(RegExp(r'[^\w\s-]'), '_')}.artnie';
      final safeFileName = fileName.replaceAll(' ', '_');

      if (kIsWeb) {
        // Web: Use share_plus to download
        final blob = html.Blob([artnieData]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', safeFileName);
        anchor.click();
        html.Url.revokeObjectUrl(url);
        ToastHelper.success('Design downloaded as .artnie file');
        return safeFileName;
      } else {
        // Mobile: Try direct save to Downloads first, then fallback to share dialog
        if (Platform.isAndroid) {
          try {
            // Try to save directly to Downloads folder
            final downloadsPath = await _getDownloadsPath();
            if (downloadsPath != null) {
              final downloadsFilePath = path.join(downloadsPath, safeFileName);
              final downloadsFile = File(downloadsFilePath);
              await downloadsFile.writeAsBytes(artnieData);

              ToastHelper.success('Design saved to Downloads: $safeFileName');
              return downloadsFilePath;
            }
          } catch (e) {
            debugPrint('Direct save to Downloads failed: $e');
            // Continue to fallback
          }
        }

        // Fallback: Use share dialog (works on all platforms and Android versions)
        // This is the professional standard that works reliably
        final tempDir = await getTemporaryDirectory();
        final tempPath = path.join(tempDir.path, safeFileName);
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(artnieData);

        // Share the file - user can save to Downloads, Drive, or any location
        await Share.shareXFiles([XFile(tempPath)], subject: safeFileName);

        ToastHelper.success('Design exported as .artnie file');
        return tempPath;
      }
    } catch (e) {
      debugPrint('Export design error: $e');
      ToastHelper.error('Failed to export design: ${e.toString()}');
      return null;
    }
  }

  /// Import design from .artnie file
  /// Returns the CardTemplate if successful, null otherwise
  Future<CardTemplate?> importDesignFromArtnie(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final artnieData = await file.readAsBytes();

      // Validate magic header
      if (artnieData.length < 7) {
        throw Exception('Invalid .artnie file: too short');
      }

      final header = utf8.decode(artnieData.sublist(0, 6));
      if (header != _magicHeader) {
        throw Exception('Invalid .artnie file: wrong header');
      }

      // Read version
      final version = artnieData[6];
      if (version != _version) {
        throw Exception('Unsupported .artnie file version: $version');
      }

      // Extract data (compressed or uncompressed)
      final fileData = artnieData.sublist(7);

      // Try to decompress first (if compressed)
      String jsonString;
      try {
        final decompressed = GZipDecoder().decodeBytes(fileData);
        jsonString = utf8.decode(decompressed);
      } catch (e) {
        // If decompression fails, assume it's uncompressed JSON
        jsonString = utf8.decode(fileData);
      }

      // Parse JSON to CardTemplate
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final template = CardTemplate.fromJson(json);

      ToastHelper.success('Design imported successfully');
      return template;
    } catch (e) {
      debugPrint('Import design error: $e');
      ToastHelper.error('Failed to import design: ${e.toString()}');
      return null;
    }
  }

  /// Get Downloads directory path for Android
  /// Returns null if not available or on other platforms
  Future<String?> _getDownloadsPath() async {
    if (!Platform.isAndroid) return null;

    try {
      // Method 1: Try to get from external storage directory
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Navigate to Downloads: /storage/emulated/0/Download
        final rootPath = externalDir.path.split('Android')[0];
        final downloadsPath = path.join(rootPath, 'Download');
        final downloadsDir = Directory(downloadsPath);

        // Check if directory exists or can be created
        if (await downloadsDir.exists()) {
          return downloadsPath;
        }

        // Try to create it
        try {
          await downloadsDir.create(recursive: true);
          if (await downloadsDir.exists()) {
            return downloadsPath;
          }
        } catch (e) {
          debugPrint('Could not create Downloads directory: $e');
        }
      }

      // Method 2: Try standard paths
      final standardPaths = [
        '/storage/emulated/0/Download',
        '/sdcard/Download',
        '/storage/emulated/0/Downloads',
        '/sdcard/Downloads',
      ];

      for (final standardPath in standardPaths) {
        try {
          final dir = Directory(standardPath);
          if (await dir.exists()) {
            return standardPath;
          }
        } catch (e) {
          continue;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error getting Downloads path: $e');
      return null;
    }
  }

  /// Import design from .artnie file bytes (for file picker)
  Future<CardTemplate?> importDesignFromBytes(List<int> artnieData) async {
    try {
      // Validate magic header
      if (artnieData.length < 7) {
        throw Exception('Invalid .artnie file: too short');
      }

      final header = utf8.decode(artnieData.sublist(0, 6));
      if (header != _magicHeader) {
        throw Exception('Invalid .artnie file: wrong header');
      }

      // Read version
      final version = artnieData[6];
      if (version != _version) {
        throw Exception('Unsupported .artnie file version: $version');
      }

      // Extract data (compressed or uncompressed)
      final fileData = artnieData.sublist(7);

      // Try to decompress first (if compressed)
      String jsonString;
      try {
        final decompressed = GZipDecoder().decodeBytes(fileData);
        jsonString = utf8.decode(decompressed);
      } catch (e) {
        // If decompression fails, assume it's uncompressed JSON
        jsonString = utf8.decode(fileData);
      }

      // Parse JSON to CardTemplate
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final template = CardTemplate.fromJson(json);

      ToastHelper.success('Design imported successfully');
      return template;
    } catch (e) {
      debugPrint('Import design error: $e');
      ToastHelper.error('Failed to import design: ${e.toString()}');
      return null;
    }
  }
}

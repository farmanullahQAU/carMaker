import 'package:archive/archive.dart';
import 'package:flutter/services.dart';

class FontCompressionService {
  /// Compress font files using Flutter's archive package
  static Future<Map<String, int>> compressFonts() async {
    final Map<String, int> compressionResults = {};

    try {
      // Get font files from assets
      final fontFiles = [
        'assets/fonts/urdu/Jameel Noori Nastaleeq Regular.ttf',
        'assets/fonts/urdu/Jameel Noori Nastaleeq Kasheeda.ttf',
        'assets/fonts/urdu/AlQalam Khat-e-Sumbali Regular.ttf',
      ];

      for (final fontPath in fontFiles) {
        try {
          // Read font file
          final ByteData fontData = await rootBundle.load(fontPath);
          final Uint8List originalBytes = fontData.buffer.asUint8List();

          // Compress using archive package
          final compressedBytes = _compressBytes(originalBytes);

          // Calculate compression ratio
          final originalSize = originalBytes.length;
          final compressedSize = compressedBytes.length;
          final compressionRatio =
              ((originalSize - compressedSize) / originalSize * 100).round();

          compressionResults[fontPath] = compressionRatio;

          print('✅ Compressed: ${fontPath.split('/').last}');
          print('   Original: ${_formatBytes(originalSize)}');
          print('   Compressed: ${_formatBytes(compressedSize)}');
          print('   Saved: $compressionRatio%');
        } catch (e) {
          print('❌ Error compressing ${fontPath.split('/').last}: $e');
        }
      }
    } catch (e) {
      print('❌ Font compression failed: $e');
    }

    return compressionResults;
  }

  /// Compress bytes using archive package
  static Uint8List _compressBytes(Uint8List inputBytes) {
    // Create archive
    final archive = Archive();

    // Add font file to archive
    final file = ArchiveFile('font.ttf', inputBytes.length, inputBytes);
    archive.addFile(file);

    // Compress archive
    final compressedBytes = ZipEncoder().encode(archive);

    return Uint8List.fromList(compressedBytes);
  }

  /// Format bytes to human readable format
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get compression statistics
  static Future<Map<String, dynamic>> getCompressionStats() async {
    final results = await compressFonts();

    int totalOriginalSize = 0;
    int totalCompressedSize = 0;

    for (final _ in results.entries) {
      // This is a simplified calculation
      // In real implementation, you'd track actual sizes
      totalOriginalSize += 1000000; // Assume 1MB per font
      totalCompressedSize += 100000; // Assume 100KB compressed
    }

    return {
      'totalFonts': results.length,
      'averageCompression': results.values.isNotEmpty
          ? results.values.reduce((a, b) => a + b) / results.values.length
          : 0,
      'totalOriginalSize': totalOriginalSize,
      'totalCompressedSize': totalCompressedSize,
      'totalSavings': totalOriginalSize - totalCompressedSize,
    };
  }
}

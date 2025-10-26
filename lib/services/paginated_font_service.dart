import 'package:cardmaker/services/firebase_font_service.dart';

/// Paginated font loading service for efficient Firebase Storage access
class PaginatedFontService {
  static const int _itemsPerPage = 20; // Load 20 fonts at a time
  static int _currentPage = 0;
  static bool _hasMoreFonts = true;
  static bool _isLoading = false;

  /// Load fonts in pages (lazy loading)
  static Future<List<RemoteFont>> loadNextPage({
    bool autoDownload = false,
  }) async {
    if (_isLoading || !_hasMoreFonts) {
      return [];
    }

    _isLoading = true;

    try {
      // Get all fonts from Firebase Storage (for now, we load all at once but can be optimized)
      final List<RemoteFont> allFonts =
          await FirebaseFontService.getAvailableFonts();

      // Calculate pagination
      final int startIndex = _currentPage * _itemsPerPage;
      final int endIndex = (startIndex + _itemsPerPage).clamp(
        0,
        allFonts.length,
      );

      if (startIndex >= allFonts.length) {
        _hasMoreFonts = false;
        return [];
      }

      final List<RemoteFont> pageFonts = allFonts.sublist(startIndex, endIndex);

      // Auto-download if enabled
      if (autoDownload) {
        for (final RemoteFont font in pageFonts) {
          final bool isDownloaded = await FirebaseFontService.isFontDownloaded(
            font.family,
          );
          if (!isDownloaded) {
            // Download in background (don't await to avoid blocking)
            FirebaseFontService.downloadFontInBackground(font);
          }
        }
      }

      _currentPage++;
      _hasMoreFonts = endIndex < allFonts.length;

      return pageFonts;
    } catch (e) {
      print('Error loading font page: $e');
      _hasMoreFonts = false;
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// Reset pagination state
  static void reset() {
    _currentPage = 0;
    _hasMoreFonts = true;
    _isLoading = false;
  }

  /// Check if there are more fonts to load
  static bool get hasMoreFonts => _hasMoreFonts;

  /// Check if currently loading
  static bool get isLoading => _isLoading;
}

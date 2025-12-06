import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_review/in_app_review.dart';

/// Professional in-app review service with smart timing logic
///
/// Best practices implemented:
/// - Tracks app sessions and user actions
/// - Shows review prompt at optimal moments (after successful exports)
/// - Respects user choice (won't show again if dismissed)
/// - Minimum time between prompts (90 days)
/// - Requires minimum app usage before prompting
class AppReviewService {
  static final AppReviewService _instance = AppReviewService._internal();
  factory AppReviewService() => _instance;
  AppReviewService._internal();

  final _storage = GetStorage();
  final InAppReview _inAppReview = InAppReview.instance;

  // Storage keys
  static const String _keyLastReviewRequest = 'last_review_request_date';
  static const String _keyReviewDismissed = 'review_dismissed';
  static const String _keyAppSessions = 'app_sessions_count';
  static const String _keySuccessfulExports = 'successful_exports_count';
  static const String _keyLastSessionDate = 'last_session_date';

  // Configuration constants
  static const int _minSessionsBeforeReview = 3;
  static const int _minExportsBeforeReview = 2;
  static const int _daysBetweenReviewPrompts = 20;

  /// Track app session (call on app start)
  Future<void> trackSession() async {
    try {
      final now = DateTime.now();
      final lastSessionDate = _getLastSessionDate();

      // Increment session count if it's a new day
      if (lastSessionDate == null || !_isSameDay(lastSessionDate, now)) {
        final currentSessions = _getSessionCount();
        await _storage.write(_keyAppSessions, currentSessions + 1);
        await _storage.write(_keyLastSessionDate, now.toIso8601String());
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error tracking session: $e');
      }
    }
  }

  /// Track successful card export
  Future<void> trackSuccessfulExport() async {
    try {
      final currentExports = _getSuccessfulExportsCount();
      await _storage.write(_keySuccessfulExports, currentExports + 1);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error tracking export: $e');
      }
    }
  }

  /// Check if review should be requested and show it if appropriate
  ///
  /// Returns true if review was requested, false otherwise
  Future<bool> requestReviewIfAppropriate() async {
    try {
      // Check if review was dismissed permanently
      if (_isReviewDismissed()) {
        return false;
      }

      // Check minimum time between prompts
      if (!_canRequestReview()) {
        return false;
      }

      // Check minimum usage requirements
      if (!_meetsMinimumUsageRequirements()) {
        return false;
      }

      // Check if InAppReview is available
      if (!await _inAppReview.isAvailable()) {
        return false;
      }

      // Request review
      await _inAppReview.requestReview();

      // Update last request date
      await _storage.write(
        _keyLastReviewRequest,
        DateTime.now().toIso8601String(),
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting review: $e');
      }
      return false;
    }
  }

  /// Manually open app store for review (for settings screen)
  Future<void> openStoreListing() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.openStoreListing();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error opening store listing: $e');
      }
    }
  }

  /// Mark review as dismissed (user chose not to review)
  Future<void> dismissReview() async {
    await _storage.write(_keyReviewDismissed, true);
  }

  /// Reset review state (for testing or if user wants to see it again)
  Future<void> resetReviewState() async {
    await _storage.remove(_keyLastReviewRequest);
    await _storage.remove(_keyReviewDismissed);
  }

  // Private helper methods

  bool _isReviewDismissed() {
    return _storage.read<bool>(_keyReviewDismissed) ?? false;
  }

  bool _canRequestReview() {
    final lastRequestDate = _getLastReviewRequestDate();
    if (lastRequestDate == null) {
      return true;
    }

    final daysSinceLastRequest = DateTime.now()
        .difference(lastRequestDate)
        .inDays;
    return daysSinceLastRequest >= _daysBetweenReviewPrompts;
  }

  bool _meetsMinimumUsageRequirements() {
    final sessions = _getSessionCount();
    final exports = _getSuccessfulExportsCount();

    // User must have at least minimum sessions OR minimum exports
    return sessions >= _minSessionsBeforeReview ||
        exports >= _minExportsBeforeReview;
  }

  int _getSessionCount() {
    return _storage.read<int>(_keyAppSessions) ?? 0;
  }

  int _getSuccessfulExportsCount() {
    return _storage.read<int>(_keySuccessfulExports) ?? 0;
  }

  DateTime? _getLastReviewRequestDate() {
    final dateString = _storage.read<String>(_keyLastReviewRequest);
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  DateTime? _getLastSessionDate() {
    final dateString = _storage.read<String>(_keyLastSessionDate);
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

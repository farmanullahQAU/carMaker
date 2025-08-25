import 'dart:ui';

extension StringExtension on String {
  String get capitalize =>
      '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}

extension ColorExtension on Color {
  /// Converts a Color to an ARGB32 string (e.g., '0xFF0000FF' for blue).
  String toARGB32() => '${this.toARGB32()}';

  /// Creates a Color from an ARGB32 string, returns null if invalid.
  static Color? fromARGB32(String? colorString) {
    if (colorString == null) return null;
    try {
      final intColor = int.parse(colorString);
      return Color(intColor);
    } catch (e) {
      return null; // Return null for invalid strings
    }
  }
}

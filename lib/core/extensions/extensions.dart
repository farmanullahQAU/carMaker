import 'dart:ui';

import 'package:morphable_shape/morphable_shape.dart';

extension StringExtension on String {
  String get capitalize =>
      '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}

extension ColorExtension on Color {
  /// Converts a Color to an ARGB32 string (e.g., '0xFF0000FF' for blue).
  String toARGB32() => '${this.toARGB32()}';

  /// Creates a Color from an ARGB32 string, returns null if invalid.
  static Color? fromARGB32(dynamic colorString) {
    if (colorString == null) return null;
    try {
      if (colorString is int) {
        return Color(colorString);
      }

      final intColor = int.parse(colorString);
      return Color(intColor);
    } catch (e) {
      return null; // Return null for invalid strings
    }
  }
}

// Add this extension for easy length conversion
extension LengthExtension on double {
  Length get toPXLength => Length(this, unit: LengthUnit.px);
  Length get toPercentLength => Length(this, unit: LengthUnit.percent);
}

// Add this extension for ShapeSide conversion
extension ShapeSideExtension on ShapeSide {
  static ShapeSide fromString(String value) {
    switch (value) {
      case 'ShapeSide.top':
        return ShapeSide.top;
      case 'ShapeSide.bottom':
        return ShapeSide.bottom;
      case 'ShapeSide.left':
        return ShapeSide.left;
      case 'ShapeSide.right':
        return ShapeSide.right;
      default:
        return ShapeSide.bottom;
    }
  }
}

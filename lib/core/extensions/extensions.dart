import 'dart:ui';

import 'package:cardmaker/widgets/common/stack_board/lib/helpers.dart';
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

extension ShapeShadowJson on ShapeShadow {
  static ShapeShadow fromJson(Map<String, dynamic> data) {
    return ShapeShadow(
      color: data['color'] != null
          ? Color(asT<int>(data['strokeColor']))
          : const Color(0xFF000000),
      offset: data['offset'] != null
          ? Offset(
              (data['offset']['dx'] as num).toDouble(),
              (data['offset']['dy'] as num).toDouble(),
            )
          : Offset.zero,
      blurRadius: (data['blurRadius'] as num?)?.toDouble() ?? 0.0,
      spreadRadius: (data['spreadRadius'] as num?)?.toDouble() ?? 0.0,
      blurStyle: data['blurStyle'] != null
          ? BlurStyle.values[data['blurStyle'] as int]
          : BlurStyle.normal,
      // gradient: data['gradient'] != null ? /* parse gradient */ : null,  // Add if using gradients
    );
  }
}

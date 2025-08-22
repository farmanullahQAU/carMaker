import 'dart:convert';
import 'dart:ui';

/// 转换为 Map<String, dynamic>
/// Convert to Map<String, dynamic>
Map<String, dynamic> asMap(dynamic value) {
  if (value == null) {
    return <String, dynamic>{};
  }
  if (value is Map<String, dynamic>) {
    return value; // Directly return the map if it’s already the correct type
  }
  if (value is String && value.isNotEmpty) {
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      print("Failed to decode JSON: $e, value: $value");
      return <String, dynamic>{};
    }
  }
  return <String, dynamic>{}; // Default to empty map for other types
}

/// 自动转换类型
/// Auto convert type
T asT<T>(dynamic value, [T? def]) {
  if (value is T) {
    return value;
  }
  if (T == String) {
    return (def ?? '') as T;
  }
  if (T == bool) {
    return (def ?? false) as T;
  }
  if (T == int) {
    return (def ?? 0) as T;
  }
  if (T == double) {
    return (def ?? 0.0) as T;
  }
  if (<String, String>{} is T) {
    if (value is String && value.isNotEmpty) {
      return json.decode(value) as T;
    }
    return (def ?? <String, String>{}) as T;
  }
  if (<String, dynamic>{} is T) {
    if (value is String) {
      return json.decode(value) as T;
    }
    return (def ?? <String, dynamic>{}) as T;
  }
  if (<dynamic, dynamic>{} is T) {
    if (value is String) {
      return json.decode(value) as T;
    }
    return (def ?? <dynamic, dynamic>{}) as T;
  }
  return def as T ?? (null as T); // Handle nullable types
}

extension ColorDeserialization on Color {
  static Color? from(dynamic value) {
    if (value == null) return null;

    if (value is int) return Color(value);

    if (value is String) {
      final hex = value.replaceFirst('#', '');
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) {
        // Add alpha if missing (assume FF)
        if (hex.length == 6) {
          return Color(0xFF000000 | parsed);
        } else if (hex.length == 8) {
          return Color(parsed);
        }
      }
    }

    return null;
  }

  int toARGB32() => value;
}

/// 自动转换为可空类型
/// Auto convert to nullable type
T? asNullT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

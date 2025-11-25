import 'package:flutter/material.dart';

/// Utility class for detecting text language and direction
class LanguageDetector {
  /// Detect if text contains Urdu/Arabic characters
  /// Returns true if text contains Arabic script characters (Urdu, Arabic, Persian, etc.)
  static bool isUrduOrArabic(String text) {
    if (text.isEmpty) return false;

    // Unicode ranges for Arabic script
    // Arabic: U+0600-U+06FF
    // Arabic Supplement: U+0750-U+077F
    // Arabic Extended-A: U+08A0-U+08FF
    // Arabic Presentation Forms-A: U+FB50-U+FDFF
    // Arabic Presentation Forms-B: U+FE70-U+FEFF
    final arabicPattern = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    );

    return arabicPattern.hasMatch(text);
  }

  /// Detect text direction based on content
  /// Returns TextDirection.rtl if text contains RTL characters, otherwise TextDirection.ltr
  static TextDirection detectTextDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;

    // Check for RTL characters (Arabic, Hebrew, Urdu, etc.)
    if (isUrduOrArabic(text)) {
      return TextDirection.rtl;
    }

    // Check for Hebrew characters
    final hebrewPattern = RegExp(r'[\u0590-\u05FF]');
    if (hebrewPattern.hasMatch(text)) {
      return TextDirection.rtl;
    }

    return TextDirection.ltr;
  }

  /// Detect if text is primarily RTL or LTR
  /// Returns true if more than 50% of characters are RTL
  static bool isPrimarilyRTL(String text) {
    if (text.isEmpty) return false;

    int rtlCount = 0;
    int totalChars = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      // Skip whitespace and punctuation
      if (char.trim().isEmpty || RegExp(r'[^\w\s]').hasMatch(char)) {
        continue;
      }

      totalChars++;
      final codeUnit = char.codeUnitAt(0);

      // Check Arabic script ranges
      if ((codeUnit >= 0x0600 && codeUnit <= 0x06FF) ||
          (codeUnit >= 0x0750 && codeUnit <= 0x077F) ||
          (codeUnit >= 0x08A0 && codeUnit <= 0x08FF) ||
          (codeUnit >= 0xFB50 && codeUnit <= 0xFDFF) ||
          (codeUnit >= 0xFE70 && codeUnit <= 0xFEFF)) {
        rtlCount++;
      }
      // Check Hebrew
      else if (codeUnit >= 0x0590 && codeUnit <= 0x05FF) {
        rtlCount++;
      }
    }

    if (totalChars == 0) return false;
    return (rtlCount / totalChars) > 0.5;
  }

  /// Get language type from text
  static LanguageType detectLanguage(String text) {
    if (text.isEmpty) return LanguageType.english;

    if (isUrduOrArabic(text)) {
      return LanguageType.urdu;
    }

    return LanguageType.english;
  }
}

enum LanguageType { english, urdu, auto }

extension LanguageTypeExtension on LanguageType {
  String get displayName {
    switch (this) {
      case LanguageType.english:
        return 'English';
      case LanguageType.urdu:
        return 'Urdu';
      case LanguageType.auto:
        return 'Auto';
    }
  }

  TextDirection get textDirection {
    switch (this) {
      case LanguageType.english:
        return TextDirection.ltr;
      case LanguageType.urdu:
        return TextDirection.rtl;
      case LanguageType.auto:
        return TextDirection.ltr; // Will be determined dynamically
    }
  }

  bool get isRTL {
    return textDirection == TextDirection.rtl;
  }
}

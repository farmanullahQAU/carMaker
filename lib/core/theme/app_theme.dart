import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardMakerTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter', // Or any font you use
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.branding,
        primary: AppColors.branding,
        surface: AppColors.backgroundLight,
        surfaceContainer: const Color(0xffe6e7eb),
        surfaceContainerHigh: const Color(0xffd1d2d6),
        surfaceContainerHighest: const Color(0xffbabbc0),
        surfaceContainerLow: const Color(0xfff5f5f5),
        surfaceContainerLowest: const Color(0xfffafafa),
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTightTextTheme(Typography.blackMountainView),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter', // Or any font you use
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.branding,
        primary: AppColors.branding,
        surface: AppColors.backgroundDark,
        surfaceContainer: const Color(0xFF16171D),
        surfaceContainerHigh: const Color(0xFF1E1F27),
        surfaceContainerHighest: const Color(0xFF272832),
        surfaceContainerLow: const Color(0xFF101117),
        surfaceContainerLowest: const Color(0xFF08090D),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTightTextTheme(Typography.whiteMountainView),
    );
  }
}

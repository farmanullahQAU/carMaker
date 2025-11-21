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
        surfaceContainer: Color(0xffe6e7eb),
        surfaceContainerHigh: Color(0xffd1d2d6),
        surfaceContainerHighest: Color(0xffbabbc0),
        surfaceContainerLow: Color(0xfff5f5f5),
        surfaceContainerLowest: Color(0xfffafafa),
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
        // seedColor: Colors.pink,
        seedColor: AppColors.branding,
        primary: AppColors.branding,
        surface: AppColors.backgroundDark,
        surfaceContainer: Color(0xff38393e),
        surfaceContainerHigh: Color(0xff41434a),
        surfaceContainerHighest: Color(0xff4a4c52),
        surfaceContainerLow: Color(0xff313237),
        surfaceContainerLowest: Color(0xff292a2f),

        // surfaceContainer: Color(0xff38393e),

        //38393e
        // Dark surface color
        // tertiary: Colors.white,

        // secondary: AppColors.secondary
        // tertiary: AppColors.tertiary,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTightTextTheme(Typography.whiteMountainView),
    );
  }
}

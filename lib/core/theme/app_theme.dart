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
        // tertiary: AppColors.tertiary,
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

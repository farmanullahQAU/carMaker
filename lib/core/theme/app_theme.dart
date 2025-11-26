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
        // Professional light theme colors with better contrast
        surface: AppColors.backgroundLight, // #FAFAFA
        surfaceContainer: const Color(0xFFF0F0F0), // Light gray for containers
        surfaceContainerHigh: const Color(
          0xFFE5E5E5,
        ), // Slightly darker for elevated surfaces
        surfaceContainerHighest: const Color(0xFFD9D9D9), // Highest elevation
        surfaceContainerLow: const Color(
          0xFFF5F5F5,
        ), // Very light gray, slightly darker than surface
        surfaceContainerLowest: const Color(
          0xFFFFFFFF,
        ), // Pure white for lowest surfaces
        // Text colors for better contrast
        onSurface: const Color(0xFF1A1A1A), // Dark text for readability
        onSurfaceVariant: const Color(
          0xFF6B6B6B,
        ), // Medium gray for secondary text
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTightTextTheme(Typography.blackMountainView),
      // Ensure scaffold background uses the surface color
      scaffoldBackgroundColor: AppColors.backgroundLight,
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter', // Or any font you use
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.branding,
        primary: AppColors.branding,
        // Professional dark theme colors with better visibility
        surface: AppColors.backgroundDark, // #1E1E1E
        surfaceContainer: const Color(
          0xFF2C2C2C,
        ), // Lighter gray for containers
        surfaceContainerHigh: const Color(
          0xFF3A3A3A,
        ), // Even lighter for elevated surfaces
        surfaceContainerHighest: const Color(0xFF484848), // Highest elevation
        surfaceContainerLow: const Color(
          0xFF252525,
        ), // Slightly lighter than surface
        surfaceContainerLowest: const Color(
          0xFF1A1A1A,
        ), // Darkest but still visible
        // Text colors for better contrast
        onSurface: const Color(0xFFE5E5E5), // Light gray text
        onSurfaceVariant: const Color(
          0xFFB3B3B3,
        ), // Medium gray for secondary text
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTightTextTheme(Typography.whiteMountainView),
      // Ensure scaffold background uses the surface color
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }
}

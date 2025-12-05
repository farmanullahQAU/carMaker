import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
class CardMakerTheme {
  static ThemeData lightTheme() {
    // Colors from HTML/Tailwind config:
    // background-light: #f6f6f8
    // primary: #135bec
    const Color lightBackgroundColor = Color(
      0xFFF6F6F8,
    ); // From HTML's background-light
    const Color lightPrimaryColor = Color(0xFF135bec); // From HTML's primary

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter', // Or any font you use
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightPrimaryColor,
        primary: lightPrimaryColor,
        // Using lightBackgroundColor for the main surface
        surface: lightBackgroundColor,
        // Calculating professional light theme colors for surfaces based on the new surface color
        surfaceContainer: const Color(
          0xFFEEEEF0,
        ), // Slightly darker gray for containers
        surfaceContainerHigh: const Color(
          0xFFE5E5E7,
        ), // Even darker for elevated surfaces
        surfaceContainerHighest: const Color(0xFFDCDCE0), // Highest elevation
        surfaceContainerLow: const Color(
          0xFFF9F9FB,
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
      // Ensure scaffold background uses the new surface color
      scaffoldBackgroundColor: lightBackgroundColor,
    );
  }

  static ThemeData darkTheme() {
    // Colors from HTML/Tailwind config:
    // background-dark: #101622
    // primary: #135bec
    const Color darkBackgroundColor = Color(
      0xFF101622,
    ); // From HTML's background-dark
    const Color darkPrimaryColor = Color(0xFF135bec); // From HTML's primary

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter', // Or any font you use
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        primary: darkPrimaryColor,
        // Using darkBackgroundColor for the main surface
        surface: darkBackgroundColor, // #101622
        // Professional dark theme colors for surfaces
        surfaceContainer: const Color(0xFF1A212E),
        surfaceContainerHigh: const Color(0xFF242C3B),
        surfaceContainerHighest: const Color(0xFF2E3747),
        surfaceContainerLow: const Color(0xFF151C28),
        surfaceContainerLowest: const Color(0xFF0B111B),
        // Text colors for better contrast on a dark background
        onSurface: const Color(0xFFE5E5E5),
        onSurfaceVariant: const Color(0xFFB3B3B3),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTightTextTheme(Typography.whiteMountainView),
      // Ensure scaffold background uses the new surface color
      scaffoldBackgroundColor: darkBackgroundColor,
    );
  }
}

*/
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

import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';

class CardMakerTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter', // Or any font you use
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.branding,
        primary: AppColors.branding,
        // tertiary: AppColors.tertiary,
        brightness: Brightness.light,
      ),
      textTheme: Typography.blackMountainView,
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
        // tertiary: Colors.white,

        // secondary: AppColors.secondary
        // tertiary: AppColors.tertiary,
        brightness: Brightness.dark,
      ),
      textTheme: Typography.whiteMountainView,
    );
  }
}

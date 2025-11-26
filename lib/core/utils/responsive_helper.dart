import 'package:flutter/material.dart';

/// Helper utility for responsive design calculations
class ResponsiveHelper {
  /// Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Get responsive column count for grid layouts
  /// Returns 2 for mobile, 3 for tablet, 4+ for larger screens
  static int getGridColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      // Mobile phones: 2 columns
      return 2;
    } else if (width < tabletBreakpoint) {
      // Tablets: 3 columns
      return 3;
    } else if (width < desktopBreakpoint) {
      // Small tablets/large phones: 3 columns
      return 3;
    } else {
      // Desktop/large tablets: 4 columns
      return 4;
    }
  }

  /// Get responsive card width for horizontal lists
  /// Returns percentage of screen width based on device size
  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      // Mobile phones: ~30% of screen width
      return width * 0.3;
    } else if (width < tabletBreakpoint) {
      // Tablets: ~25% of screen width
      return width * 0.25;
    } else {
      // Desktop/large tablets: ~20% of screen width
      return width * 0.2;
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 12);
    } else if (width < tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
  }

  /// Get responsive spacing between grid items
  static double getGridSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return 12.0;
    } else if (width < tabletBreakpoint) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileBreakpoint &&
        MediaQuery.of(context).size.width < desktopBreakpoint;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if device is desktop or large tablet
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive card height for horizontal lists
  /// Returns a fixed but responsive height based on device size
  static double getCardHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      // Mobile phones: 140px
      return 140.0;
    } else if (width < tabletBreakpoint) {
      // Tablets: 160px
      return 160.0;
    } else {
      // Desktop/large tablets: 180px
      return 180.0;
    }
  }
}

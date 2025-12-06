import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

/// Helper utility for showing toast notifications using toastification
class ToastHelper {
  // Global navigator key for toast notifications
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get context with Overlay - direct approach
  static BuildContext? _getContext() {
    try {
      // Method 1: Use navigator key's overlay context directly (most reliable)
      final navigatorState = navigatorKey.currentState;
      if (navigatorState != null) {
        final overlay = navigatorState.overlay;
        if (overlay != null && overlay.context.mounted) {
          return overlay.context;
        }
      }

      // Method 2: Use navigator key's current context
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        try {
          Overlay.of(context, rootOverlay: true);
          return context;
        } catch (e) {
          try {
            Overlay.of(context);
            return context;
          } catch (e2) {
            // Continue to next method
          }
        }
      }

      // Method 3: Use Get.key
      try {
        final getKey = Get.key;
        final navState = getKey.currentState;
        if (navState != null) {
          final overlay = navState.overlay;
          if (overlay != null && overlay.context.mounted) {
            return overlay.context;
          }
        }
        final getContext = getKey.currentContext;
        if (getContext != null && getContext.mounted) {
          try {
            Overlay.of(getContext, rootOverlay: true);
            return getContext;
          } catch (e) {
            // Continue
          }
        }
      } catch (e) {
        // Get.key not available
      }

      // Method 4: Use Get.context
      final getContext = Get.context;
      if (getContext != null && getContext.mounted) {
        try {
          Overlay.of(getContext, rootOverlay: true);
          return getContext;
        } catch (e) {
          // No overlay
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Show success toast with modern design
  static void success(String message, {Duration? duration}) {
    // Dismiss any existing toasts before showing a new one
    dismissAll();
    final context = _getContext();
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryContext = _getContext();
        if (retryContext != null) {
          _showSuccessToast(retryContext, message, duration);
        }
      });
      return;
    }
    _showSuccessToast(context, message, duration);
  }

  static void _showSuccessToast(
    BuildContext context,
    String message,
    Duration? duration,
  ) {
    try {
      final colorScheme = Theme.of(context).colorScheme;

      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
            // color: colorScheme.onPrimary,
          ),
        ),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: duration ?? const Duration(seconds: 4),
        showProgressBar: false,
        icon: Icon(
          Icons.check_circle_rounded,
          size: 24,
          // color: colorScheme.onPrimary,
        ),
        borderRadius: BorderRadius.circular(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        primaryColor: colorScheme.primary,
        animationDuration: const Duration(milliseconds: 400),
        animationBuilder: (context, animation, alignment, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: child,
              ),
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('ToastHelper: Error showing success toast: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Show error toast with modern design
  static void error(String message, {Duration? duration}) {
    // Dismiss any existing toasts before showing a new one
    dismissAll();
    final context = _getContext();
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryContext = _getContext();
        if (retryContext != null) {
          _showErrorToast(retryContext, message, duration);
        }
      });
      return;
    }
    _showErrorToast(context, message, duration);
  }

  static void _showErrorToast(
    BuildContext context,
    String message,
    Duration? duration,
  ) {
    try {
      // Error color - red for errors only
      const errorColor = Color(0xFFD32F2F); // Deep red for errors
      final colorScheme = Theme.of(context).colorScheme;

      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
            color: Colors.white, // White text on red background for contrast
          ),
        ),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: duration ?? const Duration(seconds: 4),
        showProgressBar: false,
        icon: const Icon(Icons.error_rounded, size: 24, color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        boxShadow: [
          BoxShadow(
            color: errorColor.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        primaryColor: errorColor, // Red color for errors only
        animationDuration: const Duration(milliseconds: 400),
        animationBuilder: (context, animation, alignment, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: child,
              ),
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('ToastHelper: Error showing error toast: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Show loading/info toast with modern design
  static void loading(String message) {
    // Dismiss any existing toasts before showing a new one
    dismissAll();
    final context = _getContext();
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryContext = _getContext();
        if (retryContext != null) {
          _showLoadingToast(retryContext, message);
        }
      });
      return;
    }
    _showLoadingToast(context, message);
  }

  static void _showLoadingToast(BuildContext context, String message) {
    try {
      final colorScheme = Theme.of(context).colorScheme;

      toastification.show(
        context: context,
        type: ToastificationType.info,
        style: ToastificationStyle.fillColored,
        title: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
            // color: colorScheme.onPrimary,
          ),
        ),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 30),
        showProgressBar: false,
        icon: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            // valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        primaryColor: colorScheme.primary,
        animationDuration: const Duration(milliseconds: 400),
        animationBuilder: (context, animation, alignment, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: child,
              ),
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('ToastHelper: Error showing loading toast: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Show subtle info toast - non-distracting, short duration
  static void info(String message, {Duration? duration}) {
    final context = _getContext();
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryContext = _getContext();
        if (retryContext != null) {
          _showInfoToast(retryContext, message, duration);
        }
      });
      return;
    }
    _showInfoToast(context, message, duration);
  }

  static void _showInfoToast(
    BuildContext context,
    String message,
    Duration? duration,
  ) {
    try {
      final colorScheme = Theme.of(context).colorScheme;

      toastification.show(
        context: context,
        type: ToastificationType.info,
        style: ToastificationStyle.flat, // Flat style is less distracting
        title: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            letterSpacing: 0.1,
            color: colorScheme.onSurface,
          ),
        ),
        alignment: Alignment.bottomCenter,
        autoCloseDuration:
            duration ?? const Duration(seconds: 2), // Short duration
        showProgressBar: false,
        icon: Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Smaller padding
        backgroundColor: colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        primaryColor: colorScheme.primary,
        animationDuration: const Duration(
          milliseconds: 300,
        ), // Faster animation
        animationBuilder: (context, animation, alignment, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('ToastHelper: Error showing info toast: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Dismiss all toasts
  static void dismissAll() {
    try {
      toastification.dismissAll();
    } catch (e) {
      debugPrint('ToastHelper: Error dismissing toasts: $e');
    }
  }
}

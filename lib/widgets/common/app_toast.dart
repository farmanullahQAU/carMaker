import 'package:flutter/material.dart';

// Toast types
enum ToastType { loading, success, error }

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Main Toast Manager
class AppToast {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  // Show a toast
  static void show({
    required ToastType type,
    required String message,
    bool showLogo = false,
    Duration? duration,
    VoidCallback? onDismiss,
  }) {
    // Remove any existing toast
    if (_isVisible) {
      _hide();
    }

    // Create overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        type: type,
        message: message,
        showLogo: showLogo,
        duration: duration,
        onDismiss: () {
          _hide();
          onDismiss?.call();
        },
      ),
    );

    // Insert overlay and set visibility
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState != null) {
      overlayState.insert(_overlayEntry!);
      _isVisible = true;
    }
  }

  // Show loading toast
  static void loading({String message = 'Loading...', bool showLogo = false}) {
    show(type: ToastType.loading, message: message, showLogo: showLogo);
  }

  // Show success toast
  static void success({
    required String message,
    bool showLogo = false,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    show(
      type: ToastType.success,
      message: message,
      showLogo: showLogo,
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  // Show error toast
  static void error({
    required String message,
    bool showLogo = false,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onDismiss,
  }) {
    show(
      type: ToastType.error,
      message: message,
      showLogo: showLogo,
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  // Close loading toast
  static void closeLoading() {
    if (_isVisible && _overlayEntry != null) {
      _hide();
    }
  }

  // Hide the current toast
  static void _hide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _isVisible = false;
  }
}

// Toast Overlay Widget
class _ToastOverlay extends StatefulWidget {
  final ToastType type;
  final String message;
  final bool showLogo;
  final Duration? duration;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.type,
    required this.message,
    required this.showLogo,
    this.duration,
    required this.onDismiss,
  });

  @override
  __ToastOverlayState createState() => __ToastOverlayState();
}

class __ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    // Auto-dismiss if not loading
    if (widget.type != ToastType.loading && widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) {
          _dismissToast();
        }
      });
    }
  }

  void _dismissToast() {
    _animationController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor = Colors.white;
    IconData iconData;
    Color iconColor;

    switch (widget.type) {
      case ToastType.loading:
        iconData = Icons.refresh;
        iconColor = colorScheme.onPrimary;
        break;
      case ToastType.error:
        iconData = Icons.error_outline;
        iconColor = colorScheme.onErrorContainer;
        backgroundColor = colorScheme.errorContainer;
        break;
      case ToastType.success:
        iconData = Icons.check;
        iconColor = colorScheme.onPrimaryContainer;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showLogo) ...[
                      // App logo - replace with your actual logo
                      Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          // color: iconColor,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset("assets/icon.png"),
                      ),
                    ],
                    if (widget.type == ToastType.loading)
                      Container(
                        margin: EdgeInsets.only(right: 12),
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          // padding: EdgeInsets.all(4),
                          // valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                          // strokeWidth: 2.5,
                        ),
                      ),
                    // else
                    //   Icon(iconData, size: 28),
                    // const SizedBox(width: 12),
                    Text(
                      widget.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        // color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.type != ToastType.loading)
                      InkWell(
                        onTap: _dismissToast,

                        child: Icon(iconData, color: iconColor, size: 20),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

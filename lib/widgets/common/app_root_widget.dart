import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:cardmaker/services/update_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final RemoteConfigService _remoteConfigService = RemoteConfigService();
  final UpdateManager _updateManager = UpdateManager();

  bool _isLoading = true;
  String _statusMessage = 'Initializing...';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _statusMessage = 'Loading configuration...');
      Get.find<HomeController>();
      await _remoteConfigService.initialize();

      await Future.delayed(Duration(milliseconds: 800));

      if (mounted) {
        _navigateToMainApp();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Initialization failed. Tap to retry.';
        });
      }
    }
  }

  void _navigateToMainApp() {
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [
        //       colorScheme.primary,
        //       colorScheme.primary.withOpacity(0.95),
        //       colorScheme.primary.withOpacity(0.85),
        //     ],
        //   ),
        // ),
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -100,
              right: -100,
              child: _buildDecorativeCircle(
                size: 250,
                opacity: 0.08,
                color: Get.theme.colorScheme.surfaceContainer,
              ),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: _buildDecorativeCircle(
                size: 300,
                opacity: 0.06,
                color: Get.theme.colorScheme.surfaceContainer,
              ),
            ),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo container
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Image.asset(
                          "assets/icon.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // App name with shader mask
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.branding,
                            AppColors.brandingLight,
                            AppColors.blue400,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Inkkaro',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // const SizedBox(height: 12),

                    // Tagline
                    Text(
                      'Create Beautiful Cards Effortlessly',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Loading indicator with status
                    if (_isLoading) ...[
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 4),
                      ),
                      // const SizedBox(height: 24),
                      // Text(
                      //   _statusMessage,
                      //   style: TextStyle(
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.w400,

                      //     letterSpacing: 0.2,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            // Positioned(
            //   bottom: 24,
            //   left: 0,
            //   right: 0,
            //   child: Column(
            //     children: [
            //       Text(
            //         'v${UpdateManager().currVer}',
            //         style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            //       ),
            //       const SizedBox(height: 6),
            //       Text(
            //         '© 2025 Inkkaro. All rights reserved.',
            //         style: TextStyle(
            //           fontSize: 11,
            //           fontWeight: FontWeight.w300,

            //           letterSpacing: 0.2,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle({
    required double size,
    required double opacity,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

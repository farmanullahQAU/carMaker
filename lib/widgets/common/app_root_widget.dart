import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/services/admob_service.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Main animation controller
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Pulse animation controller for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    Get.put(HomeController());
    final remoteConfigService = RemoteConfigService();

    // Initialize services in parallel for minimum loading time
    // Navigate as soon as RemoteConfig is ready (AdMob can load in background)
    final initStartTime = DateTime.now();
    debugPrint('Initializing RemoteConfig...');
    // Initialize RemoteConfig with shorter timeout for faster failure
    await remoteConfigService
        .initialize()
        .timeout(
          const Duration(seconds: 8), // Reduced from 10s for faster timeout
          onTimeout: () {
            // Timeout is fine - RemoteConfigService uses fallback config automatically
          },
        )
        .catchError((_) {
          // Any error is fine - RemoteConfigService already has fallback config
        });
    debugPrint('Initialized RemoteConfig...');
    debugPrint('Starting AdMob initialization (non-blocking)...');
    // Start AdMob initialization in background (don't wait for it)
    // It will use RemoteConfig once it's ready
    AdMobService().initialize().catchError((error) {
      debugPrint('AdMob initialization failed: $error');
      // Non-critical - app continues without ads
    });
    debugPrint('AdMob initialization started in background...');

    // Ensure minimum splash screen time for smooth UX (600ms minimum)
    // But don't wait longer than necessary
    final elapsed = DateTime.now().difference(initStartTime);
    final minSplashTime = const Duration(milliseconds: 600);
    if (elapsed < minSplashTime) {
      await Future.delayed(minSplashTime - elapsed);
    }

    // Navigate immediately after minimum time (AdMob continues loading in background)
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Get.offNamed(AppRoutes.home);
    }

    // AdMob continues loading in background (non-blocking)
    // No need to await - ads will be ready when needed
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.backgroundDark, // #1E1E1E
                        const Color(0xFF2A2A2A), // Slightly lighter
                        AppColors.backgroundDark,
                      ]
                    : [
                        const Color(0xFFFAFAFA),
                        const Color(0xFFF5F5F5),
                        const Color(0xFFFAFAFA),
                      ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Decorative gradient circles
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.branding.withOpacity(0.15),
                    AppColors.branding.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandingLight.withOpacity(0.12),
                    AppColors.brandingLight.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _mainAnimationController,
                _pulseController,
              ]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App logo with pulse animation
                        Transform.scale(
                          scale:
                              _logoScaleAnimation.value * _pulseAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.branding.withOpacity(0.2),
                                  AppColors.brandingLight.withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.branding.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(
                                        0xFF2C2C2C,
                                      ) // Match surfaceContainer
                                    : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Image.asset(
                                  "assets/icon.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // App name with gradient
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.branding,
                                AppColors.brandingLight,
                                AppColors.branding,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'Artnie',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tagline
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Create Beautiful Designs Effortlessly',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              color: isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.6),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 80),

                        // Professional loading indicator
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.branding.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.branding,
                                    ),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

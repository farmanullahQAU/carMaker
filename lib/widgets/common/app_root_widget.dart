import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 800,
      ), // Reduced for smoother performance
    );

    // _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    // );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.9, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    Get.put(HomeController());
    // Initialize RemoteConfig - it handles errors gracefully with fallback config
    // So we don't need to worry about network errors, it will work offline
    final service = RemoteConfigService();
    await service
        .initialize()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            // Timeout is fine - RemoteConfigService uses fallback config automatically
          },
        )
        .catchError((_) {
          // Any error is fine - RemoteConfigService already has fallback config
        });

    // Don't create controllers here - let InitialBindings handle it
    // This prevents duplicate controller creation and improves performance

    // Small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 800));

    // Navigate to home only once
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Get.offNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: child,
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
                    child: const Text(
                      'Artnie',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Text(
                    'Create Beautiful Designs Effortlessly',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Loading indicator
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 4),
                  ),
                ],
              ),
            ),
          ),
        ],
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

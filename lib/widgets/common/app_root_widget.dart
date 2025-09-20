// lib/widgets/common/splash_screen.dart
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

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize Remote Config
      setState(() => _statusMessage = 'Loading configuration...');
      await _remoteConfigService.initialize();

      // Step 2: Check for updates
      // setState(() => _statusMessage = 'Checking for updates...');
      // await _checkForUpdates();

      // Step 3: If no update required or after update check, proceed to main app
      if (mounted) {
        _navigateToMainApp();
      }
    } catch (error) {
      // Handle initialization errors gracefully
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Initialization failed. Tap to retry.';
        });
      }
    }
  }

  void _navigateToMainApp() {
    // Navigate to the main app screen
    Get.offAllNamed(Routes.home);
  }

  void _retryInitialization() {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Retrying...';
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // backgroundColor: colorScheme.primary,
      body: Stack(
        children: [
          // Background with subtle gradient
          // Container(
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.topCenter,
          //       end: Alignment.bottomCenter,
          //       colors: [
          //         colorScheme.primary,
          //         colorScheme.primary.withOpacity(0.9),
          //         colorScheme.primary.withOpacity(0.8),
          //       ],
          //     ),
          //   ),
          // ),

          // Decorative elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.brandingLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.brandingLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(opacity: _fadeAnimation.value, child: child),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo with container for better presentation
                  Container(
                    // padding: const EdgeInsets.all(20),
                    // decoration: BoxDecoration(
                    //   color: colorScheme.surfaceContainerHigh,
                    //   borderRadius: BorderRadius.circular(20),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: colorScheme.shadow.withOpacity(0.1),
                    //       blurRadius: 10,
                    //       spreadRadius: 2,
                    //       offset: const Offset(0, 5),
                    //     ),
                    //   ],
                    // ),
                    child: Image.asset("assets/icon.png", width: 80),
                  ),

                  const SizedBox(height: 32),

                  // App name text
                  Text(
                    'Inkkaro',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Create Beautiful Cards Effortlessly',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                  ),

                  const SizedBox(height: 40),

                  // Loading indicator or status message
                  if (_isLoading)
                    Column(
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        // const SizedBox(height: 20),
                        // Text(
                        //   _statusMessage,
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w400,
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Footer with version info
          // Positioned(
          //   bottom: 20,
          //   left: 0,
          //   right: 0,
          //   child: Column(
          //     children: [
          //       Text(UpdateManager().currVer, style: TextStyle(fontSize: 12)),
          //       const SizedBox(height: 4),
          //       Text('© 2023 CardMaker App', style: TextStyle(fontSize: 10)),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

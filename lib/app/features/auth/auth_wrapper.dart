import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isPortrait = screenHeight > screenWidth;

            if (screenWidth < 600) {
              return _buildMobileLayout(isPortrait, screenWidth, theme);
            } else if (screenWidth < 900) {
              return _buildTabletLayout(isPortrait, screenWidth, theme);
            } else {
              return _buildDesktopLayout(screenWidth, theme);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    bool isPortrait,
    double screenWidth,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: isPortrait ? 16 : 12,
        ),
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Get.find<AuthService>().isSkipped.value = true;
                  Get.back();
                },
                child: Text(
                  'Skip',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            SizedBox(height: isPortrait ? 18 : 12),

            // App icon
            Container(
              width: isPortrait ? 90 : 70,
              height: isPortrait ? 90 : 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.primary.withOpacity(0.1),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isPortrait ? 18 : 14),
                child: Image.asset('assets/icon.png', fit: BoxFit.contain),
              ),
            ),

            SizedBox(height: isPortrait ? 18 : 16),

            // Main heading
            Text(
              'Sign in to Continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isPortrait ? 24 : 20,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),

            SizedBox(height: isPortrait ? 24 : 18),

            // Benefits list
            _buildBenefitsList(isPortrait, screenWidth, theme),

            SizedBox(height: isPortrait ? 24 : 18),

            // CTA Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: isPortrait ? 52 : 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.auth);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In / Create Account',
                          style: TextStyle(
                            fontSize: isPortrait ? 16 : 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: isPortrait ? 20 : 18),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Get.find<AuthService>().isSkipped.value = true;
                    Get.back();
                  },
                  child: const Text(
                    'Continue as guest',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),

            SizedBox(height: isPortrait ? 16 : 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    bool isPortrait,
    double screenWidth,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isPortrait ? 24 : 18),
      child: isPortrait
          ? _buildTabletPortrait(screenWidth, theme)
          : _buildTabletLandscape(screenWidth, theme),
    );
  }

  Widget _buildTabletPortrait(double screenWidth, ThemeData theme) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () {
              Get.find<AuthService>().isSkipped.value = true;
              Get.back();
            },
            child: const Text('Skip'),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.colorScheme.primary.withOpacity(0.1),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Image.asset('assets/icon.png', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Sign in to Continue',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 28),
        _buildBenefitsList(true, screenWidth, theme),
        const SizedBox(height: 28),
        SizedBox(
          width: screenWidth * 0.65,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(AppRoutes.auth);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Sign In / Create Account',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward, size: 22),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Get.find<AuthService>().isSkipped.value = true;
            Get.back();
          },
          child: const Text(
            'Continue as guest',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLandscape(double screenWidth, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Get.find<AuthService>().isSkipped.value = true;
                    Get.back();
                  },
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to\nContinue',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 24),
              _buildBenefitsList(false, screenWidth, theme),
              const SizedBox(height: 24),
              SizedBox(
                width: screenWidth * 0.4,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.auth);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Sign In / Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.find<AuthService>().isSkipped.value = true;
                  Get.back();
                },
                child: const Text(
                  'Continue as guest',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                color: theme.colorScheme.primary.withOpacity(0.1),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Image.asset('assets/icon.png', fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(double screenWidth, ThemeData theme) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () {
                          Get.find<AuthService>().isSkipped.value = true;
                          Get.back();
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sign in to\nContinue',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _buildBenefitsList(false, screenWidth, theme),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: 320,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.auth);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Sign In / Create Account',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_forward, size: 22),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Get.find<AuthService>().isSkipped.value = true;
                        Get.back();
                      },
                      child: Text(
                        'Continue as guest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Image.asset(
                        'assets/icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsList(
    bool isPortrait,
    double screenWidth,
    ThemeData theme,
  ) {
    final benefits = [
      {
        'icon': Icons.cloud_sync_rounded,
        'title': 'Cloud Sync',
        'description': 'Access your designs anywhere',
        'iconColor': AppColors.green400,
        'bgColor': AppColors.green400Light,
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Secure Backup',
        'description': 'Never lose your work',
        'iconColor': AppColors.red400,
        'bgColor': AppColors.red400Light,
      },
      {
        'icon': Icons.star_rounded,
        'title': 'Premium Templates',
        'description': 'Exclusive designs library',
        'iconColor': AppColors.amber400,
        'bgColor': AppColors.amber400Light,
      },
      {
        'icon': Icons.devices_rounded,
        'title': 'Multi-Device',
        'description': 'Seamless experience',
        'iconColor': AppColors.blue400,
        'bgColor': AppColors.blue400Light,
      },
    ];

    return Column(
      children: benefits.map((benefit) {
        Color iconColor = benefit['iconColor'] as Color;
        final bgColor = benefit['bgColor'] as Color;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit['title'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      benefit['description'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle, size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// import 'package:cardmaker/app/routes/app_routes.dart';
// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:cardmaker/services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final screenWidth = constraints.maxWidth;
//             final screenHeight = constraints.maxHeight;
//             final isPortrait = screenHeight > screenWidth;

//             if (screenWidth < 600) {
//               // Mobile layout
//               return _buildMobileLayout(isPortrait, screenWidth);
//             } else if (screenWidth < 900) {
//               // Tablet layout
//               return _buildTabletLayout(isPortrait, screenWidth);
//             } else {
//               // Desktop layout
//               return _buildDesktopLayout(screenWidth);
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMobileLayout(bool isPortrait, double screenWidth) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: screenWidth * 0.05,
//           vertical: isPortrait ? 20 : 10,
//         ),
//         child: Column(
//           children: [
//             // Skip button
//             Align(
//               alignment: Alignment.topRight,
//               child: TextButton(
//                 onPressed: () {
//                   Get.find<AuthService>().isSkipped.value = true;
//                   Get.back();
//                 },
//                 child: Text(
//                   'Skip',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ),
//             ),

//             SizedBox(height: isPortrait ? 20 : 10),

//             // App icon
//             Container(
//               width: isPortrait ? 120 : 80,
//               height: isPortrait ? 120 : 80,
//               margin: EdgeInsets.only(bottom: isPortrait ? 40 : 20),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(isPortrait ? 28 : 20),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Colors.white, Colors.grey.shade50],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 30,
//                     offset: const Offset(0, 15),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(isPortrait ? 24 : 16),
//                 child: Image.asset('assets/icon.png', fit: BoxFit.contain),
//               ),
//             ),

//             // Main heading
//             Text(
//               'Welcome to Inkkaro',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: isPortrait ? 28 : 22,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.grey.shade900,
//                 letterSpacing: -0.8,
//                 height: 1.2,
//               ),
//             ),

//             SizedBox(height: isPortrait ? 16 : 12),

//             // Subtitle
//             Text(
//               'Create beautiful cards and invitations\nwith professional templates',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: isPortrait ? 16 : 14,
//                 fontWeight: FontWeight.w400,
//                 color: Colors.grey.shade600,
//                 height: 1.5,
//               ),
//             ),

//             SizedBox(height: isPortrait ? 40 : 30),

//             // Feature highlights
//             _buildFeatureRow(isPortrait, screenWidth),

//             SizedBox(height: isPortrait ? 40 : 30),

//             // CTA Button
//             SizedBox(
//               width: double.infinity,
//               height: isPortrait ? 56 : 50,
//               child: FilledButton.icon(
//                 onPressed: () {
//                   Get.toNamed(AppRoutes.auth);
//                 },
//                 icon: Text(
//                   'Get Started',
//                   style: TextStyle(
//                     fontSize: isPortrait ? 17 : 15,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.1,
//                   ),
//                 ),
//                 label: Icon(Icons.arrow_forward, size: isPortrait ? 20 : 18),
//               ),
//             ),

//             SizedBox(height: isPortrait ? 24 : 20),

//             // Bottom text
//             _buildBottomText(isPortrait),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabletLayout(bool isPortrait, double screenWidth) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(isPortrait ? 32 : 24),
//       child: isPortrait
//           ? _buildTabletPortrait(screenWidth)
//           : _buildTabletLandscape(screenWidth),
//     );
//   }

//   Widget _buildTabletPortrait(double screenWidth) {
//     return Column(
//       children: [
//         // Skip button
//         Align(
//           alignment: Alignment.topRight,
//           child: TextButton(onPressed: () => Get.back(), child: Text('Skip')),
//         ),

//         const SizedBox(height: 40),

//         // App icon
//         Container(
//           width: 140,
//           height: 140,
//           margin: const EdgeInsets.only(bottom: 48),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(32),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.white, Colors.grey.shade50],
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 30,
//                 offset: const Offset(0, 15),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(28),
//             child: Image.asset('assets/icon.png', fit: BoxFit.contain),
//           ),
//         ),

//         // Main heading
//         Text(
//           'Welcome to Inkkaro',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 32,
//             fontWeight: FontWeight.w700,
//             color: Colors.grey.shade900,
//             letterSpacing: -0.8,
//             height: 1.2,
//           ),
//         ),

//         const SizedBox(height: 20),

//         // Subtitle
//         Text(
//           'Create beautiful cards and invitations with professional templates',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w400,
//             color: Colors.grey.shade600,
//             height: 1.5,
//           ),
//         ),

//         const SizedBox(height: 60),

//         // Feature highlights
//         _buildFeatureRow(true, screenWidth),

//         const SizedBox(height: 60),

//         // CTA Button
//         SizedBox(
//           width: screenWidth * 0.6,
//           height: 60,
//           child: ElevatedButton(
//             onPressed: () {
//               Get.toNamed(AppRoutes.auth);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Get Started',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.1,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Icon(Icons.arrow_forward, size: 22),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 30),

//         // Bottom text
//         _buildBottomText(false),
//       ],
//     );
//   }

//   Widget _buildTabletLandscape(double screenWidth) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         // Left content
//         Expanded(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Skip button
//               Align(
//                 alignment: Alignment.topRight,
//                 child: TextButton(
//                   onPressed: () => Get.back(),
//                   child: Text(
//                     'Skip',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Main heading
//               Text(
//                 'Welcome to Inkkaro',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.grey.shade900,
//                   letterSpacing: -0.8,
//                   height: 1.2,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Subtitle
//               Text(
//                 'Create beautiful cards and invitations with professional templates',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.grey.shade600,
//                   height: 1.5,
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // Feature highlights
//               _buildFeatureRow(false, screenWidth),

//               const SizedBox(height: 40),

//               // CTA Button
//               SizedBox(
//                 width: screenWidth * 0.4,
//                 height: 60,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Get.toNamed(AppRoutes.auth);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Get Started',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.1,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Icon(Icons.arrow_forward, size: 22),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // Bottom text
//               _buildBottomText(false),
//             ],
//           ),
//         ),

//         // Right icon
//         Expanded(
//           child: Center(
//             child: Container(
//               width: 160,
//               height: 160,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(32),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Colors.white, Colors.grey.shade50],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 30,
//                     offset: const Offset(0, 15),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(32),
//                 child: Image.asset('assets/icon.png', fit: BoxFit.contain),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDesktopLayout(double screenWidth) {
//     return Center(
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 1200),
//         child: Padding(
//           padding: const EdgeInsets.all(40),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Left content
//               Expanded(
//                 flex: 3,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Skip button
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: TextButton(
//                         onPressed: () => Get.back(),
//                         child: Text(
//                           'Skip',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // Main heading
//                     Text(
//                       'Welcome to Inkkaro',
//                       style: TextStyle(
//                         fontSize: 42,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.grey.shade900,
//                         letterSpacing: -1.0,
//                         height: 1.1,
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     // Subtitle
//                     Text(
//                       'Create beautiful cards and invitations with professional templates. Design, customize, and share your creations effortlessly.',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w400,
//                         color: Colors.grey.shade600,
//                         height: 1.6,
//                       ),
//                     ),

//                     const SizedBox(height: 60),

//                     // Feature highlights
//                     _buildFeatureRow(false, screenWidth),

//                     const SizedBox(height: 60),

//                     // CTA Button
//                     SizedBox(
//                       width: 300,
//                       height: 64,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Get.toNamed(AppRoutes.auth);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text(
//                               'Get Started',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing: 0.1,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Icon(Icons.arrow_forward, size: 24),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // Bottom text
//                     _buildBottomText(false),
//                   ],
//                 ),
//               ),

//               // Right icon
//               Expanded(
//                 flex: 2,
//                 child: Center(
//                   child: Container(
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(40),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [Colors.white, Colors.grey.shade50],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 30,
//                           offset: const Offset(0, 15),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(40),
//                       child: Image.asset(
//                         'assets/icon.png',
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureRow(bool isPortrait, double screenWidth) {
//     final isSmallScreen = screenWidth < 400;
//     final iconSize = isSmallScreen ? 40.0 : (isPortrait ? 56.0 : 48.0);
//     final fontSize = isSmallScreen ? 11.0 : (isPortrait ? 13.0 : 12.0);

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildFeatureIcon(
//           Icons.palette_outlined,
//           'Templates',
//           iconSize,
//           fontSize,
//           AppColors.red400,
//           AppColors.red400Light,
//         ),
//         _buildFeatureIcon(
//           Icons.cloud_outlined,
//           'Cloud Sync',
//           iconSize,
//           fontSize,
//           AppColors.amber400,
//           AppColors.amber400Light,
//         ),
//         _buildFeatureIcon(
//           Icons.share_outlined,
//           'Easy Share',
//           iconSize,
//           fontSize,
//           AppColors.green400,
//           AppColors.green400Light,
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatureIcon(
//     IconData icon,
//     String label,
//     double size,
//     double fontSize,
//     Color appColor,
//     Color bgColor,
//   ) {
//     return Column(
//       children: [
//         Container(
//           width: size,
//           height: size,
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(size * 0.3),
//           ),
//           child: Icon(icon, size: size * 0.45, color: appColor),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: fontSize,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomText(bool isPortrait) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: isPortrait ? 24 : 0),
//       child: RichText(
//         textAlign: TextAlign.center,
//         text: TextSpan(
//           style: TextStyle(
//             fontSize: isPortrait ? 13 : 14,
//             color: Colors.grey.shade500,
//             height: 1.4,
//           ),
//           children: [
//             const TextSpan(text: 'By continuing, you agree to our '),
//             TextSpan(
//               text: 'Terms of Service',
//               style: TextStyle(
//                 color: Colors.grey.shade700,
//                 fontWeight: FontWeight.w500,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//             const TextSpan(text: ' and '),
//             TextSpan(
//               text: 'Privacy Policy',
//               style: TextStyle(
//                 color: Colors.grey.shade700,
//                 fontWeight: FontWeight.w500,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

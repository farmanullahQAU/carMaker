// lib/dialogs/update_dialog.dart

import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';

class UpdateDialog {
  static void showRequired(
    BuildContext context, {
    required String title,
    required List<String> newFeatures,
    required VoidCallback onUpdatePressed,
  }) {
    _showDialog(
      context,
      title: title,
      newFeatures: newFeatures,
      onUpdatePressed: onUpdatePressed,
      isOptional: false,
    );
  }

  static void showOptional(
    BuildContext context, {
    required String title,
    required List<String> newFeatures,
    required VoidCallback onUpdatePressed,
    VoidCallback? onSkipPressed,
  }) {
    _showDialog(
      context,
      title: title,
      newFeatures: newFeatures,
      onUpdatePressed: onUpdatePressed,
      onSkipPressed: onSkipPressed ?? () => Navigator.of(context).pop(),
      isOptional: true,
    );
  }

  static void _showDialog(
    BuildContext context, {
    required String title,
    required List<String> newFeatures,
    required VoidCallback onUpdatePressed,
    VoidCallback? onSkipPressed,
    required bool isOptional,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: isOptional,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      // barrierColor: Colors.black.withValues(0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder:
          (
            BuildContext buildContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return WillPopScope(
              onWillPop: () async => isOptional,
              child: Center(
                child: Material(
                  type: MaterialType.transparency,
                  child: ConstrainedBox(
                    // 1. Constrain the max height of the dialog
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Feature Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.brandingLight.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            child: const Icon(
                              Icons.system_update_rounded,
                              color: AppColors.branding,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2. Make the features list flexible and scrollable
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: newFeatures
                                      .map(
                                        (feature) =>
                                            _FeatureListItem(text: feature),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Buttons
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: onUpdatePressed,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    // backgroundColor: AppColors.royalPrimary,
                                    // foregroundColor: Colors.white,
                                    // elevation: 0,
                                    // shadowColor: Colors.transparent,
                                  ),
                                  child: const Text(
                                    'Update Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              if (isOptional)
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: onSkipPressed,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      // foregroundColor: Colors.grey.shade700,
                                    ),
                                    child: const Text(
                                      'Later',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

// Helper widget for feature list items (no changes needed here)
class _FeatureListItem extends StatelessWidget {
  final String text;
  const _FeatureListItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.branding,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

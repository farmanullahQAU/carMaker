import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoDataWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final Widget? actionButton;
  final bool showImage;

  const NoDataWidget({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.iconSize = 48,
    this.actionButton,
    this.showImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showImage)
              Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.inbox_rounded,
                  size: 48,
                  color:
                      iconColor ??
                      Get.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              )
            else
              Icon(
                icon ?? Icons.inbox_rounded,
                size: iconSize,
                color:
                    iconColor ??
                    Get.theme.colorScheme.onSurface.withOpacity(0.5),
              ),

            const SizedBox(height: 16),

            Text(
              title ?? 'No data available',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Get.theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

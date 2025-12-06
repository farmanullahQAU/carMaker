import 'package:flutter/material.dart';

/// Compact and professional empty state widget
///
/// Minimalist design for displaying empty states throughout the app
class NoDataWidget extends StatelessWidget {
  /// Main title text
  final String? title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Icon to display (defaults to search_off_rounded)
  final IconData? icon;

  /// Custom icon color
  final Color? iconColor;

  /// Icon size (defaults to 36 for compact, 48 for expanded)
  final double? iconSize;

  /// Compact mode for horizontal lists (default: true)
  final bool compact;

  /// Custom padding override
  final EdgeInsets? padding;

  const NoDataWidget({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.compact = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Compact responsive sizing
    final effectiveIconSize = iconSize ?? (compact ? 36.0 : 48.0);
    final effectivePadding =
        padding ??
        (compact
            ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
            : const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0));

    // Default icon
    final effectiveIcon = icon ?? Icons.search_off_rounded;

    // Default title
    final effectiveTitle = title ?? 'No results found';

    // Icon color - subtle and professional
    final effectiveIconColor =
        iconColor ?? colorScheme.onSurface.withOpacity(isDark ? 0.3 : 0.25);

    return Center(
      child: Padding(
        padding: effectivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            // Icon with subtle background
            Container(
              width: effectiveIconSize * 1.8,
              height: effectiveIconSize * 1.8,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(
                  isDark ? 0.15 : 0.2,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                effectiveIcon,
                size: effectiveIconSize,
                color: effectiveIconColor,
              ),
            ),

            SizedBox(height: compact ? 10.0 : 16.0),

            // Title - clean and readable
            Text(
              effectiveTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(isDark ? 0.85 : 0.75),
                fontSize: compact ? 13.0 : 14.5,
                letterSpacing: -0.1,
              ),
              textAlign: TextAlign.center,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Subtitle - minimal spacing
            if (subtitle != null) ...[
              SizedBox(height: compact ? 4.0 : 8.0),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(isDark ? 0.5 : 0.45),
                  fontSize: compact ? 11.5 : 12.5,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

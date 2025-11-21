// Helper widgets
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';

class CompactSlider extends StatelessWidget {
  final IconData icon;
  final String? label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? division;

  const CompactSlider({
    super.key,
    required this.icon,
    this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.division,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 16),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: const TextStyle(
                // color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                // activeTrackColor: const Color(0xFFFFA500),
                // activeTrackColor: AppColors.branding,
                // inactiveTrackColor: Colors.white24,
                // thumbColor: const Color(0xFFFFA500),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: division,
                onChanged: onChanged,
              ),
            ),
          ),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.branding,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ColorPickerBox extends StatelessWidget {
  final Color initialColor;
  final void Function(Color color) onColorPicked;

  const ColorPickerBox({
    super.key,
    required this.initialColor,
    required this.onColorPicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedColor = await showDialog<Color>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Pick a color'),
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Colors.primaries.map((color) {
                return GestureDetector(
                  onTap: () => Navigator.pop(context, color),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
        if (pickedColor != null) {
          onColorPicked(pickedColor);
        }
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: initialColor,
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

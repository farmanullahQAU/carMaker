import 'package:flutter/material.dart';

import '../items/shack_shape_item.dart';

class StackShapeCase extends StatelessWidget {
  final StackShapeItem item;

  const StackShapeCase({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.content == null) {
      return Container(
        width: item.size.width,
        height: item.size.height,
        color: Colors.grey.shade300,
        child: const Icon(Icons.error, color: Colors.red),
      );
    }

    final content = item.content!;

    return Container(
      width: item.size.width,
      height: item.size.height,
      decoration: ShapeDecoration(
        shape: content.shapeBorder!,
        color: content.fillColor,
        shadows: content.shadows.map((shadow) {
          return BoxShadow(
            color: shadow.color,
            blurRadius: shadow.blurRadius,
            offset: shadow.offset,
            spreadRadius: shadow.spreadRadius,
          );
        }).toList(),
      ),
    );
  }
}

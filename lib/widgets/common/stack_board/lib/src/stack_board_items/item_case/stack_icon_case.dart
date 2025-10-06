// stack_icon_case.dart
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_icon_item.dart';
import 'package:flutter/material.dart';

class StackIconCase extends StatelessWidget {
  final StackIconItem item;

  const StackIconCase({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.content == null) {
      return SizedBox(
        width: item.size.width,
        height: item.size.height,

        child: const Icon(Icons.error, color: Colors.red),
      );
    }

    final content = item.content!;

    return FittedBox(
      fit: BoxFit.fill,
      // width: item.size.width,
      // height: item.size.height,
      child: Icon(content.icon, color: content.color),
    );
  }
}

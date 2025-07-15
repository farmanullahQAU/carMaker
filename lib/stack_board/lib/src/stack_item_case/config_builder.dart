import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/stack_board/lib/helpers.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:flutter/material.dart';

/// Config Builder
class ConfigBuilder extends StatelessWidget {
  const ConfigBuilder({
    super.key,
    this.shouldRebuild,
    this.childBuilder,
    required this.child,
  });

  final bool Function(StackConfig p, StackConfig n)? shouldRebuild;
  final Widget Function(StackConfig sc, Widget c)? childBuilder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExBuilder<StackConfig>.child(
      valueListenable: StackBoardConfig.of(context).controller,
      shouldRebuild: shouldRebuild,
      childBuilder: childBuilder,
      child: child,
    );
  }

  static Widget withItem(
    String id, {
    required Widget child,
    bool Function(StackItem<StackItemContent> p, StackItem<StackItemContent> n)?
    shouldRebuild,
    Widget Function(StackItem<StackItemContent> item, Widget c)? childBuilder,
  }) {
    return ConfigBuilder(
      shouldRebuild: (StackConfig p, StackConfig n) {
        try {
          final StackItem<StackItemContent> pI = p[id];
          final StackItem<StackItemContent> nI = n[id];

          return shouldRebuild?.call(pI, nI) ?? true;
        } catch (e) {
          return true;
        }
      },
      childBuilder: (StackConfig sc, Widget c) {
        final StackItem<StackItemContent> item = sc[id];
        return childBuilder?.call(item, c) ?? c;
      },
      child: child,
    );
  }
}

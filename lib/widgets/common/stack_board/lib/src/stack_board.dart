import 'package:cardmaker/widgets/common/stack_board/lib/helpers.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_item_case/stack_item_case.dart';
import 'package:flutter/material.dart';

import 'core/case_style.dart';
import 'core/stack_board_controller.dart';
import 'core/stack_board_item/stack_item.dart';
import 'core/stack_board_item/stack_item_content.dart';
import 'core/stack_board_item/stack_item_status.dart';

class StackBoardConfig extends InheritedWidget {
  const StackBoardConfig({
    super.key,
    required this.controller,
    this.caseStyle,
    required super.child,
  });

  final StackBoardController controller;
  final CaseStyle? caseStyle;

  static StackBoardConfig of(BuildContext context) {
    final StackBoardConfig? result = context
        .dependOnInheritedWidgetOfExactType<StackBoardConfig>();
    assert(result != null, 'No StackBoardConfig found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant StackBoardConfig oldWidget) =>
      oldWidget.controller != controller || oldWidget.caseStyle != caseStyle;
}

/// StackBoard
class StackBoard extends StatelessWidget {
  const StackBoard({
    super.key,
    this.controller,
    this.background,
    this.caseStyle,
    this.customBuilder,
    this.onDel,
    this.onEdit,
    this.onTap,
    this.onSizeChanged,
    this.onOffsetChanged,
    this.onAngleChanged,
    this.onStatusChanged,
    this.actionsBuilder,
    this.borderBuilder,
  });

  final StackBoardController? controller;

  /// * 背景
  /// * background
  final Widget? background;

  /// * 操作框样式
  /// * case style
  final CaseStyle? caseStyle;

  /// * 自定义类型控件构建器
  /// * custom builder
  final Widget? Function(StackItem<StackItemContent> item)? customBuilder;

  /// * 移除拦截
  /// * delete intercept
  final void Function(StackItem<StackItemContent> item)? onDel;
  final void Function(StackItem<StackItemContent> item)? onEdit;

  /// * 点击回调
  /// * onTap item
  final void Function(StackItem<StackItemContent> item)? onTap;

  /// * 尺寸变化回调
  /// * 返回值可控制是否继续进行
  /// * size changed callback
  /// * return value can control whether to continue
  final bool? Function(StackItem<StackItemContent> item, Size size)?
  onSizeChanged;

  /// * 位置变化回调
  /// * 返回值可控制是否继续进行
  /// * offset changed callback
  /// * return value can control whether to continue
  final bool? Function(StackItem<StackItemContent> item, Offset offset)?
  onOffsetChanged;

  /// * 角度变化回调
  /// * 返回值可控制是否继续进行
  /// * angle changed callback
  /// * return value can control whether to continue
  final bool? Function(StackItem<StackItemContent> item, double angle)?
  onAngleChanged;

  /// * 操作状态回调
  /// * 返回值可控制是否继续进行
  /// * edit status changed callback
  /// * return value can control whether to continue
  final bool? Function(
    StackItem<StackItemContent> item,
    StackItemStatus operatState,
  )?
  onStatusChanged;

  /// * 操作层构建器
  /// * actions builder
  final Widget Function(StackItemStatus operatState, CaseStyle caseStyle)?
  actionsBuilder;

  /// * 边框构建器
  /// * border builder
  final Widget Function(StackItemStatus operatState, StackItem item)?
  borderBuilder;

  StackBoardController get _controller =>
      controller ?? StackBoardController.def();

  @override
  Widget build(BuildContext context) {
    return StackBoardConfig(
      controller: _controller,
      caseStyle: caseStyle,
      child: GestureDetector(
        onTap: () => _controller.unSelectAll(),
        behavior: HitTestBehavior.opaque,
        child: ExBuilder<StackConfig>(
          valueListenable: _controller,
          shouldRebuild: (StackConfig p, StackConfig n) =>
              p.indexMap != n.indexMap,
          builder: (StackConfig sc) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                const SizedBox.expand(),
                if (background != null) background!,
                for (final StackItem<StackItemContent> item in sc.data)
                  _itemBuilder(item),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _itemBuilder(StackItem<StackItemContent> item) {
    return StackItemCase(
      key: ValueKey<String>(item.id),
      stackItem: item,
      childBuilder: customBuilder,
      caseStyle: caseStyle,
      onDel: () => onDel?.call(item),
      onEdit: () => onEdit?.call(item),
      onTap: () => onTap?.call(item),
      onSizeChanged: (Size size) => onSizeChanged?.call(item, size) ?? true,
      onOffsetChanged: (Offset offset) =>
          onOffsetChanged?.call(item, offset) ?? true,
      onAngleChanged: (double angle) =>
          onAngleChanged?.call(item, angle) ?? true,
      onStatusChanged: (StackItemStatus operatState) =>
          onStatusChanged?.call(item, operatState) ?? true,
      actionsBuilder: actionsBuilder,
      borderBuilder: (s) =>
          borderBuilder != null ? borderBuilder!(s, item) : const SizedBox(),
    );
  }
}

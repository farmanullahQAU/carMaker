import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/text_editor.dart';
import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/stack_board/lib/helpers.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_case.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
import 'package:cardmaker/stack_board/lib/widget_style_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class EditorPage extends GetView<EditorController> {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey stackBoardKey = GlobalKey();
    final RxBool showHueSlider = false.obs;
    final RxBool showStickerPanel = true.obs;
    final RxBool showShapePanel = false.obs;
    final RxInt selectedToolIndex =
        0.obs; // 0: none, 1: sticker, 2: color, 3: text, 4: shape
    final RxBool isTemplateLoaded = false.obs;
    final RxDouble canvasScale = 1.0.obs;
    final RxDouble scaledCanvasWidth = 0.0.obs;
    final RxDouble scaledCanvasHeight = 0.0.obs;

    void updateCanvasAndLoadTemplate(BoxConstraints constraints) {
      if (controller.initialTemplate == null || isTemplateLoaded.value) return;

      final double availableWidth = constraints.maxWidth * 0.9;
      final double availableHeight = 2 * (constraints.maxWidth);

      canvasScale.value = math.min(
        availableWidth / controller.initialTemplate!.width,
        availableHeight / controller.initialTemplate!.height,
      );

      scaledCanvasWidth.value =
          controller.initialTemplate!.width * canvasScale.value;
      scaledCanvasHeight.value =
          controller.initialTemplate!.height * canvasScale.value;

      controller.updateStackBoardRenderSize(
        Size(scaledCanvasWidth.value, scaledCanvasHeight.value),
      );
      debugPrint(
        'Updated StackBoard size: ${scaledCanvasWidth.value} x ${scaledCanvasHeight.value}',
      );

      controller.loadTemplate(
        controller.initialTemplate!,
        canvasScale.value,
        scaledCanvasWidth.value,
        scaledCanvasHeight.value,
        context,
      );
      isTemplateLoaded.value = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.templateName.value.isEmpty
                ? 'Design Editor'
                : controller.templateName.value,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: controller.undo,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: controller.redo,
            tooltip: 'Redo',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (controller.initialTemplate == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                SchedulerBinding.instance.addPostFrameCallback((_) {
                  updateCanvasAndLoadTemplate(constraints);
                });

                return Center(
                  child: Obx(
                    () => Container(
                      width: scaledCanvasWidth.value,
                      height: scaledCanvasHeight.value,
                      key: stackBoardKey,
                      color: Colors.red,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      child: StackBoard(
                        controller: controller.boardController,
                        background: InkWell(
                          onTap: () {
                            controller.boardController.setAllItemStatuses(
                              StackItemStatus.idle,
                            );
                            controller.removeTextEditorOverlay();
                          },
                          child: controller.selectedBackground.value.isNotEmpty
                              ? ColorFiltered(
                                  colorFilter: ColorFilter.matrix(
                                    _hueMatrix(controller.backgroundHue.value),
                                  ),
                                  child: Image.asset(
                                    controller.selectedBackground.value,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            ColoredBox(
                                              color: Colors.grey[200]!,
                                              child: const Center(
                                                child: Text(
                                                  'Background not found',
                                                ),
                                              ),
                                            ),
                                  ),
                                )
                              : ColoredBox(color: Colors.grey[200]!),
                        ),

                        customBuilder: (StackItem<StackItemContent> item) {
                          return InkWell(
                            onTap: () {
                              controller.boardController.setAllItemStatuses(
                                StackItemStatus.idle,
                              );
                              controller.boardController.updateBasic(
                                item.id,
                                status: StackItemStatus.selected,
                              );
                              if (item is StackTextItem) {
                                controller.removeTextEditorOverlay();
                                showTextEditorOverlay(
                                  context,
                                  item.copyWith(
                                    status: StackItemStatus.selected,
                                  ),
                                );
                              }
                            },
                            child:
                                (item is StackTextItem && item.content != null)
                                ? StackTextCase(item: item)
                                : (item is StackImageItem &&
                                      item.content != null)
                                ? StackImageCase(item: item)
                                : (item is ColorStackItem1 &&
                                      item.content != null)
                                ? Container(
                                    width: item.size.width,
                                    height: item.size.height,
                                    color: item.content!.color,
                                  )
                                : (item is ShapeStackItem &&
                                      item.content != null)
                                ? _buildShapeWidget(
                                    item,
                                    item.size.width,
                                    item.size.height,
                                  )
                                : (item is RowStackItem && item.content != null)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: item.content!.items.map((
                                      subItem,
                                    ) {
                                      if (subItem is StackTextItem &&
                                          subItem.content != null) {
                                        return StackTextCase(item: subItem);
                                      } else if (subItem is ShapeStackItem &&
                                          subItem.content != null) {
                                        return _buildShapeWidget(
                                          subItem,
                                          subItem.size.width,
                                          subItem.size.height,
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    }).toList(),
                                  )
                                : const SizedBox.shrink(),
                          );
                        },

                        // customBuilder: (StackItem<StackItemContent> item) {
                        //   return InkWell(
                        //     onTap: () {
                        //       controller.boardController.setAllItemStatuses(
                        //         StackItemStatus.idle,
                        //       );
                        //       controller.boardController.updateBasic(
                        //         item.id,
                        //         status: StackItemStatus.selected,
                        //       );
                        //       if (item is StackTextItem) {
                        //         controller.removeTextEditorOverlay();
                        //         showTextEditorOverlay(
                        //           context,
                        //           item.copyWith(
                        //             status: StackItemStatus.selected,
                        //           ),
                        //         );
                        //       }
                        //     },
                        //     child:
                        //         (item is StackTextItem && item.content != null)
                        //         ? StackTextCase(item: item)
                        //         : (item is StackImageItem &&
                        //               item.content != null)
                        //         ? StackImageCase(item: item)
                        //         : (item is ColorStackItem1 &&
                        //               item.content != null)
                        //         ? Container(
                        //             width: item.size.width,
                        //             height: item.size.height,
                        //             color: item.content!.color,
                        //           )
                        //         : (item is ShapeStackItem &&
                        //               item.content != null)
                        //         ? _buildShapeWidget(
                        //             item,
                        //             item.size.width,
                        //             item.size.height,
                        //           )
                        //         : const SizedBox.shrink(),
                        //   );
                        // },
                        borderBuilder: (status, item) {
                          final CaseStyle style = CaseStyle();
                          final double leftRight =
                              status == StackItemStatus.idle
                              ? 0
                              : -(style.buttonSize) / 2;
                          final double topBottom =
                              status == StackItemStatus.idle
                              ? 0
                              : -(style.buttonSize) * 1.5;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            child: Positioned(
                              left: -leftRight,
                              top: -topBottom,
                              right: -leftRight,
                              bottom: -topBottom,
                              child: IgnorePointer(
                                ignoring: true,
                                child: CustomPaint(
                                  painter: _BorderPainter(
                                    dotted: status == StackItemStatus.idle,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        onDel: controller.deleteItem,
                        onOffsetChanged: (item, offset) {
                          controller.onItemOffsetChanged(
                            item,
                            Offset(
                              offset.dx / canvasScale.value,
                              offset.dy / canvasScale.value,
                            ),
                          );
                          debugPrint('Dragging item ${item.id} to $offset');
                          return true;
                        },
                        onStatusChanged: (item, status) {
                          controller.onItemStatusChanged(item, status);
                          return true;
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            bottom: true,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainer.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(
                        () => _ToolbarButton(
                          icon: Icons.emoji_emotions_outlined,
                          label: 'Stickers',
                          onPressed: () {
                            selectedToolIndex.value =
                                selectedToolIndex.value == 1 ? 0 : 1;
                            showStickerPanel.value =
                                selectedToolIndex.value == 1;
                            showHueSlider.value = false;
                            showShapePanel.value = false;
                          },
                          isActive: selectedToolIndex.value == 1,
                        ),
                      ),
                      Obx(
                        () => _ToolbarButton(
                          icon: Icons.palette_outlined,
                          label: 'Color',
                          onPressed: () {
                            selectedToolIndex.value =
                                selectedToolIndex.value == 2 ? 0 : 2;
                            showHueSlider.value = selectedToolIndex.value == 2;
                            showStickerPanel.value = false;
                            showShapePanel.value = false;
                          },
                          isActive: selectedToolIndex.value == 2,
                        ),
                      ),
                      Obx(
                        () => _ToolbarButton(
                          icon: Icons.text_fields,
                          label: 'Text',
                          onPressed: () {
                            selectedToolIndex.value =
                                selectedToolIndex.value == 3 ? 0 : 3;
                            controller.removeTextEditorOverlay();
                            if (controller.activeItem.value is StackTextItem) {
                              showTextEditorOverlay(
                                context,
                                controller.activeItem.value as StackTextItem,
                              );
                            }
                            showStickerPanel.value = false;
                            showHueSlider.value = false;
                            showShapePanel.value = false;
                          },
                          isActive: selectedToolIndex.value == 3,
                        ),
                      ),
                      Obx(
                        () => _ToolbarButton(
                          icon: Icons.shape_line_outlined,
                          label: 'Shapes',
                          onPressed: () {
                            selectedToolIndex.value =
                                selectedToolIndex.value == 4 ? 0 : 4;
                            showShapePanel.value = selectedToolIndex.value == 4;
                            showStickerPanel.value = false;
                            showHueSlider.value = false;
                          },
                          isActive: selectedToolIndex.value == 4,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => showStickerPanel.value
                        ? _StickerPanel(controller: controller)
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => showHueSlider.value
                        ? _HueAdjustmentPanel(controller: controller)
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => showShapePanel.value
                        ? _ShapePanel(controller: controller)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget-based shape rendering
  Widget _buildShapeWidget(ShapeStackItem item, double width, double height) {
    final content = item.content!;
    switch (content.shapeType) {
      case ShapeType.horizontalLine:
        return Container(
          width: width,
          height: content.strokeWidth, // Use strokeWidth for line thickness
          color: content.color,
        );
      case ShapeType.verticalLine:
        return Container(
          width: content.strokeWidth, // Use strokeWidth for line thickness
          height: height,
          color: content.color,
        );
      case ShapeType.rectangle:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(
              color: content.color,
              width: content.strokeWidth,
            ),
          ),
        );
      case ShapeType.circle:
        return ClipOval(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(
                color: content.color,
                width: content.strokeWidth,
              ),
            ),
          ),
        );
    }
  }

  void showTextEditorOverlay(BuildContext context, StackTextItem item) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          elevation: 6,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(item.content?.style?.fontSize.toString() ?? ".."),
              TextStylingEditor(
                textItem: item,
                onClose: () {
                  Get.find<EditorController>().removeTextEditorOverlay();
                },
              ),
            ],
          ),
        ),
      ),
    );

    final controller = Get.find<EditorController>();
    controller.removeTextEditorOverlay();
    controller.activeTextEditorOverlay.value = entry;
    overlay.insert(entry);
  }

  List<double> _hueMatrix(double degrees) {
    final radians = degrees * math.pi / 180;
    final cosVal = math.cos(radians);
    final sinVal = math.sin(radians);

    const lumR = 0.213;
    const lumG = 0.715;
    const lumB = 0.122;

    return [
      lumR + cosVal * (1 - lumR) + sinVal * (-lumR),
      lumG + cosVal * (-lumG) + sinVal * (-lumG),
      lumB + cosVal * (-lumB) + sinVal * (1 - lumB),
      0,
      0,
      lumR + cosVal * (-lumR) + sinVal * 0.143,
      lumG + cosVal * (1 - lumG) + sinVal * 0.140,
      lumB + cosVal * (-lumB) + sinVal * -0.283,
      0,
      0,
      lumR + cosVal * (-lumR) + sinVal * (-(1 - lumR)),
      lumG + cosVal * (-lumG) + sinVal * lumG,
      lumB + cosVal * (1 - lumB) + sinVal * lumB,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}

// ShapePanel widget for selecting shapes
class _ShapePanel extends StatelessWidget {
  final EditorController controller;

  const _ShapePanel({required this.controller});

  void _addShape(ShapeType shapeType, BuildContext context) {
    final size = shapeType == ShapeType.horizontalLine
        ? Size(100, 10)
        : shapeType == ShapeType.verticalLine
        ? Size(10, 100)
        : Size(100, 100);
    controller.boardController.addItem(
      ShapeStackItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        size: size,
        offset: Offset(50, 50),
        content: ShapeContent(
          shapeType: shapeType,
          color: Colors.black,
          strokeWidth: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.horizontal_rule),
            onPressed: () => _addShape(ShapeType.horizontalLine, context),
            tooltip: 'Horizontal Line',
          ),
          IconButton(
            icon: const Icon(Icons.vertical_align_center),
            onPressed: () => _addShape(ShapeType.verticalLine, context),
            tooltip: 'Vertical Line',
          ),
          IconButton(
            icon: const Icon(Icons.crop_square),
            onPressed: () => _addShape(ShapeType.rectangle, context),
            tooltip: 'Rectangle',
          ),
          IconButton(
            icon: const Icon(Icons.circle_outlined),
            onPressed: () => _addShape(ShapeType.circle, context),
            tooltip: 'Circle',
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          // decoration: BoxDecoration(
          //   color: isActive
          //       ? Theme.of(context).primaryColor.withOpacity(0.1)
          //       : Colors.transparent,
          //   borderRadius: BorderRadius.circular(8),
          // ),
          child: IconButton(
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),

            icon: Icon(icon),
            color: isActive ? Theme.of(context).primaryColor : Colors.grey[800],
            onPressed: onPressed,
            tooltip: label,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Theme.of(context).primaryColor : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

class _StickerPanel extends StatelessWidget {
  final EditorController controller;

  const _StickerPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final categories = {
      'Greetings': [
        '💌',
        '✉️',
        '📩',
        '📨',
        '📧',
        '📮',
        '🏷️',
        '📪',
        '📫',
        '📬',
        '📭',
        '📯',
        '🎀',
        '🎊',
        '🎉',
        '🎈',
      ],
      'Birthday': [
        '🎂',
        '🍰',
        '🧁',
        '🥮',
        '🎁',
        '🎀',
        '🎊',
        '🎉',
        '🎈',
        '🪅',
        '🪩',
        '🎆',
        '🎇',
        '✨',
        '🌟',
        '🎗️',
      ],
      'Party': [
        '🥳',
        '🎭',
        '🎪',
        '🪩',
        '🎠',
        '🎡',
        '🎢',
        '🎪',
        '🎫',
        '🎟️',
        '🎭',
        '🃏',
        '🎴',
        '🀄',
        '🎲',
        '🧩',
      ],
      'Love': [
        '❤️',
        '🧡',
        '💛',
        '💚',
        '💙',
        '💜',
        '🖤',
        '🤍',
        '🤎',
        '💕',
        '💞',
        '💓',
        '💗',
        '💖',
        '💘',
        '💝',
      ],
      'Congratulations': [
        '🏆',
        '🎖️',
        '🏅',
        '🥇',
        '🥈',
        '🥉',
        '🎗️',
        '🎫',
        '🎟️',
        '🎪',
        '🎭',
        '🎨',
        '🎬',
        '🎤',
        '🎧',
        '🎼',
      ],
      'Alphabet Fun': [
        '🅰️',
        '🅱️',
        '🅲',
        '🅳',
        '🅴',
        '🅵',
        '🅶',
        '🅷',
        '🅸',
        '🅹',
        '🅺',
        '🅻',
        '🅼',
        '🅽',
        '🅾️',
        '🅿️',
        '🆀',
        '🆁',
        '🆂',
        '🆃',
        '🆄',
        '🆅',
        '🆆',
        '🆇',
        '🆈',
        '🆉',
      ],

      'Celebration': [
        '🎉',
        '🎊',
        '🎂',
        '🎁',
        '🥳',
        '🎈',
        '🎀',
        '🪅',
        '🎆',
        '🎇',
        '🧨',
        '🪔',
        '🎐',
        '🎏',
        '🧧',
        '🏮',
      ],
      'Nature': [
        '🌿',
        '🌸',
        '🌞',
        '🌻',
        '🍃',
        '🌺',
        '🌴',
        '🌊',
        '🌍',
        '🌎',
        '🌏',
        '🌕',
        '🌖',
        '🌗',
        '🌘',
        '🌑',
        '🌒',
        '🌓',
        '🌔',
      ],
      'Animals': [
        '🐶',
        '🐱',
        '🦋',
        '🐝',
        '🐞',
        '🐠',
        '🦄',
        '🐧',
        '🦁',
        '🐯',
        '🦊',
        '🐰',
        '🐮',
        '🐷',
        '🐸',
        '🐵',
        '🐔',
        '🐦',
        '🐤',
      ],
      'Symbols': [
        '❤️',
        '✨',
        '⭐',
        '💎',
        '🔶',
        '🔷',
        '🟢',
        '🟣',
        '🔴',
        '🟠',
        '🟡',
        '🟤',
        '⚫',
        '⚪',
        '🟥',
        '🟧',
        '🟨',
        '🟩',
        '🟦',
      ],
    };

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: DefaultTabController(
        length: categories.length,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: categories.values.map((stickers) {
                  return GridView.count(
                    padding: EdgeInsets.all(12),
                    crossAxisCount: 8,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: stickers.map((sticker) {
                      return GestureDetector(
                        onTap: () {
                          controller.addText(sticker, size: Size(100, 100));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              sticker,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),

            SafeArea(
              child: TabBar(
                isScrollable: true,

                tabAlignment: TabAlignment.start,
                tabs: categories.keys.map((category) {
                  return Tab(text: category);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HueAdjustmentPanel extends StatelessWidget {
  final EditorController controller;

  const _HueAdjustmentPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ADJUST BACKGROUND COLOR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.color_lens, size: 20, color: Colors.grey[600]),
              SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: controller.backgroundHue.value,
                  min: 0.0,
                  max: 360.0,
                  divisions: 360,
                  label: '${controller.backgroundHue.value.round()}°',
                  onChanged: (value) {
                    controller.updateBackgroundHue(value);
                  },
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.purple,
                      Colors.red,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BorderPainter extends CustomPainter {
  final bool dotted;
  final double stroke = 0.5;
  final double dash = 3;
  final double dash2 = 0;

  const _BorderPainter({required this.dotted});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Get.find<EditorController>().draggedItem.value == null
          ? Colors.blue
          : Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final Rect rect = Offset.zero & size;

    if (!dotted) {
      canvas.drawRect(rect, paint);
      return;
    }
    if (Get.find<EditorController>().draggedItem.value != null) {
      final Path path = Path()..addRect(rect);

      final Path dashedPath = Path();
      for (final pm in path.computeMetrics()) {
        double d = 0;
        while (d < pm.length) {
          final double len = math.min(dash, pm.length - d);
          dashedPath.addPath(pm.extractPath(d, d + len), Offset.zero);
          d += dash * 2;
        }
      }
      canvas.drawPath(dashedPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BorderPainter old) => old.dotted != dotted;
}

class AlignmentGuidePainter extends CustomPainter {
  final StackItem? draggedItem;
  final List<AlignmentPoint> alignmentPoints;
  final Size stackBoardSize;
  final bool showGrid;
  final double gridSize;
  final Color guideColor;
  final Color criticalGuideColor;
  final Color centerGuideColor;

  AlignmentGuidePainter({
    required this.draggedItem,
    required this.alignmentPoints,
    required this.stackBoardSize,
    required this.showGrid,
    required this.gridSize,
    required this.guideColor,
    required this.criticalGuideColor,
    required this.centerGuideColor,
  });

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashWidth = 2;
    const double dashSpace = 2;
    double distance = (end - start).distance;
    final double dx = (end.dx - start.dx) / distance;
    final double dy = (end.dy - start.dy) / distance;
    double remainingDistance = distance;

    Offset current = start;
    while (remainingDistance > 0) {
      final double step = math.min(dashWidth, remainingDistance);
      final Offset next = Offset(
        current.dx + dx * step,
        current.dy + dy * step,
      );
      canvas.drawLine(current, next, paint);
      current = Offset(next.dx + dx * dashSpace, next.dy + dy * dashSpace);
      remainingDistance -= (step + dashSpace);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (draggedItem == null) return;

    final Paint gridPaint = Paint()
      ..color = guideColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.2;

    final Paint guidePaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint snapPaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Paint criticalPaint = Paint()
      ..color = criticalGuideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint centerPaint = Paint()
      ..color = centerGuideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (showGrid) {
      for (double x = 0; x <= stackBoardSize.width; x += gridSize) {
        _drawDashedLine(
          canvas,
          Offset(x, 0),
          Offset(x, stackBoardSize.height),
          gridPaint,
        );
      }
      for (double y = 0; y <= stackBoardSize.height; y += gridSize) {
        _drawDashedLine(
          canvas,
          Offset(0, y),
          Offset(stackBoardSize.width, y),
          gridPaint,
        );
      }
    }

    for (final point in alignmentPoints) {
      Paint paint;
      switch (point.snapType) {
        case SnapType.centerCritical:
          paint = centerPaint;
          break;
        case SnapType.edgeCritical:
          paint = criticalPaint;
          break;
        case SnapType.center:
        case SnapType.edge:
          paint = snapPaint;
          break;
        case SnapType.inactive:
          paint = guidePaint..color = guideColor.withOpacity(0.3);
          break;
      }

      if (point.isVertical) {
        final start = Offset(point.value, 0);
        final end = Offset(point.value, stackBoardSize.height);
        if (point.isSnapped) {
          canvas.drawLine(start, end, paint);
        } else {
          _drawDashedLine(canvas, start, end, paint);
        }
      } else {
        final start = Offset(0, point.value);
        final end = Offset(stackBoardSize.width, point.value);
        if (point.isSnapped) {
          canvas.drawLine(start, end, paint);
        } else {
          _drawDashedLine(canvas, start, end, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant AlignmentGuidePainter oldDelegate) {
    return oldDelegate.draggedItem?.id != draggedItem?.id ||
        oldDelegate.alignmentPoints.length != alignmentPoints.length ||
        oldDelegate.alignmentPoints.any((p) => !alignmentPoints.contains(p)) ||
        oldDelegate.stackBoardSize != stackBoardSize ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.guideColor != guideColor ||
        oldDelegate.criticalGuideColor != criticalGuideColor ||
        oldDelegate.centerGuideColor != centerGuideColor;
  }
}

class ColorStackItem1 extends StackItem<ColorContent> {
  ColorStackItem1({
    required super.size,
    super.id,
    super.offset,
    super.angle = null,
    super.status = null,
    super.content,
  }) : super(lockZOrder: true);

  factory ColorStackItem1.fromJson(Map<String, dynamic> json) {
    return ColorStackItem1(
      id: json['id'],
      size: Size(json['size']['width'], json['size']['height']),
      offset: Offset(json['offset']['dx'], json['offset']['dy']),
      angle: json['angle'],
      status: json['status'] != null
          ? StackItemStatus.values[json['status']]
          : null,
      content: json['content'] != null
          ? ColorContent.fromJson(json['content'])
          : null,
    );
  }

  @override
  ColorStackItem1 copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    ColorContent? content,
  }) {
    return ColorStackItem1(
      id: id,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      content: content ?? this.content,
    );
  }
}

class ColorContent extends StackItemContent {
  ColorContent({required this.color});

  final Color color;

  factory ColorContent.fromJson(Map<String, dynamic> json) {
    return ColorContent(color: Color(json['color']));
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'color': color.value};
  }
}

// ShapeType enum
enum ShapeType { horizontalLine, verticalLine, rectangle, circle }

// ShapeStackItem class
class ShapeStackItem extends StackItem<ShapeContent> {
  ShapeStackItem({
    required super.size,
    super.id,
    super.offset,
    super.angle = null,
    super.status = null,
    super.content,
    this.isCentered = false,
  }) : super(lockZOrder: false);

  @override
  final bool isCentered;

  factory ShapeStackItem.fromJson(Map<String, dynamic> json) {
    return ShapeStackItem(
      id: json['id'],
      size: Size(json['size']['width'], json['size']['height']),
      offset: jsonToOffset(asMap(json['offset'])),
      angle: json['angle'],
      status: json['status'] != null
          ? StackItemStatus.values[json['status']]
          : null,
      content: json['content'] != null
          ? ShapeContent.fromJson(json['content'])
          : null,
      isCentered: json['isCentered'] ?? false,
    );
  }

  @override
  ShapeStackItem copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    ShapeContent? content,
    bool? isCentered,
  }) {
    return ShapeStackItem(
      id: id,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      content: content ?? this.content,
      isCentered: isCentered ?? this.isCentered,
    );
  }
}

// ShapeContent class
class ShapeContent extends StackItemContent {
  ShapeContent({
    required this.shapeType,
    required this.color,
    this.strokeWidth = 2.0,
  });

  final ShapeType shapeType;
  final Color color;
  final double strokeWidth;

  factory ShapeContent.fromJson(Map<String, dynamic> json) {
    return ShapeContent(
      shapeType: ShapeType.values[json['shapeType']],
      color: ColorDeserialization.from(json['color']) ?? Colors.white,
      strokeWidth: json['strokeWidth'] ?? 2.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'shapeType': shapeType.index,
      'color': color.value,
      'strokeWidth': strokeWidth,
    };
  }
}

// New RowStackItem class to handle two items in a row
class RowStackItem extends StackItem<RowStackContent> {
  RowStackItem({
    required super.size,
    super.id,
    super.offset,
    super.angle = null,
    super.status = null,
    super.content,
    this.isCentered = false,
  }) : super(lockZOrder: false);

  @override
  final bool isCentered;

  factory RowStackItem.fromJson(Map<String, dynamic> json) {
    return RowStackItem(
      id: json['id'],
      size: Size(json['size']['width'], json['size']['height']),
      offset: jsonToOffset(json['offset']),
      angle: json['angle'],
      status: json['status'] != null
          ? StackItemStatus.values[json['status']]
          : null,
      content: json['content'] != null
          ? RowStackContent.fromJson(json['content'])
          : null,
      isCentered: json['isCentered'] ?? false,
    );
  }

  @override
  RowStackItem copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    RowStackContent? content,
    bool? isCentered,
  }) {
    return RowStackItem(
      id: id,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      content: content ?? this.content,
      isCentered: isCentered ?? this.isCentered,
    );
  }
}

// Content class for RowStackItem
class RowStackContent extends StackItemContent {
  final List<StackItem> items;

  RowStackContent({required this.items});

  factory RowStackContent.fromJson(Map<String, dynamic> json) {
    return RowStackContent(
      items: (json['items'] as List)
          .map((itemJson) => _deserializeItem(itemJson))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) {
        if (item is StackTextItem) {
          return {
            'type': 'StackTextItem',
            'id': item.id,
            'size': {'width': item.size.width, 'height': item.size.height},
            'offset': {'dx': item.offset.dx, 'dy': item.offset.dy},
            'angle': item.angle,
            'status': item.status.index,
            'content': item.content?.toJson(),
            'isCentered': item.isCentered,
            'textAlign': item.content?.textAlign,
          };
        } else if (item is ShapeStackItem) {
          return {
            'type': 'ShapeStackItem',
            'id': item.id,
            'size': {'width': item.size.width, 'height': item.size.height},
            'offset': {'dx': item.offset.dx, 'dy': item.offset.dy},
            'angle': item.angle,
            'status': item.status.index,
            'content': item.content?.toJson(),
            'isCentered': item.isCentered,
          };
        } else {
          throw Exception(
            'Unsupported item type in RowStackContent: ${item.runtimeType}',
          );
        }
      }).toList(),
    };
  }

  static StackItem _deserializeItem(Map<String, dynamic> itemJson) {
    final type = itemJson['type'];
    if (type == 'StackTextItem') {
      return StackTextItem.fromJson(itemJson);
    } else if (type == 'StackImageItem') {
      return StackImageItem.fromJson(itemJson);
    } else if (type == 'ShapeStackItem') {
      return ShapeStackItem.fromJson(itemJson);
    } else if (type == 'RowStackItem') {
      return RowStackItem.fromJson(itemJson);
    } else {
      throw Exception('Unsupported item type: $type');
    }
  }
}

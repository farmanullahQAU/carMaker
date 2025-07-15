import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/text_editor.dart';
import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_case.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class EditorPage extends GetView<EditorController> {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey stackBoardKey = GlobalKey();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (stackBoardKey.currentContext != null) {
        final RenderBox renderBox =
            stackBoardKey.currentContext!.findRenderObject() as RenderBox;
        final Size size = renderBox.size;
        if (controller.actualStackBoardRenderSize.value != size) {
          controller.updateStackBoardRenderSize(size);
        }
      }
    });

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
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (controller.initialTemplate == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final double templateAspectRatio =
              controller.initialTemplate!.width /
              controller.initialTemplate!.height;
          final double maxHeight = Get.height * 0.7;
          final double availableWidthForCanvas = constraints.maxWidth - 32;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: availableWidthForCanvas,
                maxHeight: maxHeight,
                minWidth: 0,
                minHeight: 0,
              ),
              child: AspectRatio(
                aspectRatio: templateAspectRatio,
                child: Container(
                  key: stackBoardKey,
                  color: Colors.grey[200],
                  child: Obx(
                    () => Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: StackBoard(
                                controller: controller.boardController,
                                background: InkWell(
                                  onTap: () {
                                    print("xxxxxxxxxxxxxxx");
                                    controller.boardController
                                        .setAllItemStatuses(
                                          StackItemStatus.idle,
                                        );
                                  },
                                  child:
                                      controller
                                          .selectedBackground
                                          .value
                                          .isNotEmpty
                                      ? Image.asset(
                                          controller.selectedBackground.value,
                                          fit: BoxFit.cover,
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
                                        )
                                      : ColoredBox(color: Colors.grey[200]!),
                                ),
                                customBuilder: (StackItem<StackItemContent> item) {
                                  return InkWell(
                                    // Double tap to open text styling editor for text items
                                    onTap: () {
                                      controller.boardController
                                          .setAllItemStatuses(
                                            StackItemStatus.idle,
                                          );
                                      controller.boardController.updateBasic(
                                        item.id,
                                        status: StackItemStatus.selected,
                                      );
                                      if (item is StackTextItem &&
                                          item.content != null) {
                                        showTextStylingEditor(item);
                                      }
                                    },
                                    child: Container(
                                      child:
                                          (item is StackTextItem &&
                                              item.content != null)
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
                                          : SizedBox.shrink(),
                                    ),
                                  );
                                },

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
                                    duration: Duration(milliseconds: 500),

                                    child: Positioned(
                                      left: -leftRight,
                                      top: -topBottom,
                                      right: -leftRight,
                                      bottom: -topBottom,
                                      child: IgnorePointer(
                                        ignoring: true,
                                        child: CustomPaint(
                                          painter: _BorderPainter(
                                            dotted:
                                                status == StackItemStatus.idle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onDel: controller.deleteItem,
                                onOffsetChanged: (item, offset) {
                                  controller.onItemOffsetChanged(item, offset);
                                  return true;
                                },
                                onStatusChanged: (item, status) {
                                  controller.onItemStatusChanged(item, status);
                                  return true;
                                },
                              ),
                            ),
                          ],
                        ),
                        Obx(() {
                          final isDragging =
                              controller.draggedItem.value != null;
                          return AnimatedOpacity(
                            opacity: isDragging ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: CustomPaint(
                              painter: AlignmentGuidePainter(
                                draggedItem: controller.draggedItem.value,
                                alignmentPoints:
                                    controller.alignmentPoints.value,
                                stackBoardSize:
                                    controller.actualStackBoardRenderSize.value,
                                showGrid:
                                    controller.showGrid.value && isDragging,
                                gridSize: controller.gridSize.value,
                                guideColor: Colors.blueAccent.withOpacity(0.6),
                                criticalGuideColor: Colors.greenAccent,
                                centerGuideColor: Colors.purple,
                              ),
                              size: controller.actualStackBoardRenderSize.value,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void showTextStylingEditor(StackTextItem textItem) {
    Get.bottomSheet(
      TextStylingEditor(textItem: textItem, onClose: () => Get.back()),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
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

    // Draw grid
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

    // Draw alignment guides
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
          // break;
          // case SnapType.grid:
          //   paint = guidePaint;
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

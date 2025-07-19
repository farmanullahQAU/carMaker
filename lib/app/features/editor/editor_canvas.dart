// import 'dart:math' as math;

// import 'package:cardmaker/app/features/editor/controller.dart';
// import 'package:cardmaker/app/features/editor/text_editor.dart';
// import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
// import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
// import 'package:cardmaker/stack_board/lib/stack_case.dart';
// import 'package:cardmaker/stack_board/lib/stack_items.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:get/get.dart';

// class EditorPage extends GetView<EditorController> {
//   const EditorPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final GlobalKey stackBoardKey = GlobalKey();
//     final RxBool showHueSlider = false.obs;

//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       if (stackBoardKey.currentContext != null &&
//           controller.activeItem.value == null) {
//         final RenderBox? renderBox =
//             stackBoardKey.currentContext!.findRenderObject() as RenderBox?;
//         if (renderBox != null) {
//           final Size size = renderBox.size;
//           if (controller.actualStackBoardRenderSize.value != size) {
//             controller.updateStackBoardRenderSize(size);
//           }
//         }
//       }
//     });

//     return Scaffold(
//       appBar: AppBar(
//         title: Obx(
//           () => Text(
//             controller.templateName.value.isEmpty
//                 ? 'Design Editor'
//                 : controller.templateName.value,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.undo),
//             onPressed: controller.undo,
//             tooltip: 'Undo',
//           ),
//           IconButton(
//             icon: const Icon(Icons.redo),
//             onPressed: controller.redo,
//             tooltip: 'Redo',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 16),
//               child: Stack(
//                 alignment: Alignment.bottomCenter,
//                 children: [
//                   LayoutBuilder(
//                     builder: (BuildContext context, BoxConstraints constraints) {
//                       if (controller.initialTemplate == null) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       final double templateAspectRatio =
//                           controller.initialTemplate!.width /
//                           controller.initialTemplate!.height;
//                       final double maxHeight = Get.height * 0.7;
//                       final double availableWidthForCanvas =
//                           constraints.maxWidth;

//                       return Container(
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 16,
//                         ),
//                         child: ConstrainedBox(
//                           constraints: BoxConstraints(
//                             maxWidth: availableWidthForCanvas,
//                             maxHeight: maxHeight,
//                             minWidth: 0,
//                             minHeight: 0,
//                           ),
//                           child: AspectRatio(
//                             aspectRatio: templateAspectRatio,
//                             child: Container(
//                               key: stackBoardKey,
//                               color: Colors.grey[200],
//                               child: Obx(
//                                 () => Stack(
//                                   children: [
//                                     Column(
//                                       children: [
//                                         Expanded(
//                                           child: StackBoard(
//                                             controller:
//                                                 controller.boardController,
//                                             background: InkWell(
//                                               onTap: () {
//                                                 controller.boardController
//                                                     .setAllItemStatuses(
//                                                       StackItemStatus.idle,
//                                                     );
//                                                 controller
//                                                     .removeTextEditorOverlay();
//                                               },
//                                               child:
//                                                   controller
//                                                       .selectedBackground
//                                                       .value
//                                                       .isNotEmpty
//                                                   ? ColorFiltered(
//                                                       colorFilter:
//                                                           ColorFilter.matrix(
//                                                             _hueMatrix(
//                                                               controller
//                                                                   .backgroundHue
//                                                                   .value,
//                                                             ),
//                                                           ),
//                                                       child: Image.asset(
//                                                         controller
//                                                             .selectedBackground
//                                                             .value,
//                                                         fit: BoxFit.cover,
//                                                         errorBuilder:
//                                                             (
//                                                               context,
//                                                               error,
//                                                               stackTrace,
//                                                             ) => ColoredBox(
//                                                               color: Colors
//                                                                   .grey[200]!,
//                                                               child: const Center(
//                                                                 child: Text(
//                                                                   'Background not found',
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                       ),
//                                                     )
//                                                   : ColoredBox(
//                                                       color: Colors.grey[200]!,
//                                                     ),
//                                             ),
//                                             customBuilder: (StackItem<StackItemContent> item) {
//                                               return InkWell(
//                                                 onTap: () {
//                                                   controller.boardController
//                                                       .setAllItemStatuses(
//                                                         StackItemStatus.idle,
//                                                       );
//                                                   controller.boardController
//                                                       .updateBasic(
//                                                         item.id,
//                                                         status: StackItemStatus
//                                                             .selected,
//                                                       );
//                                                   if (item is StackTextItem) {
//                                                     controller
//                                                         .removeTextEditorOverlay();
//                                                     showTextEditorOverlay(
//                                                       context,
//                                                       item,
//                                                     );
//                                                   }
//                                                 },
//                                                 child: Container(
//                                                   child:
//                                                       (item is StackTextItem &&
//                                                           item.content != null)
//                                                       ? StackTextCase(
//                                                           item: item,
//                                                         )
//                                                       : (item is StackImageItem &&
//                                                             item.content != null)
//                                                       ? StackImageCase(
//                                                           item: item,
//                                                         )
//                                                       : (item is ColorStackItem1 &&
//                                                             item.content != null)
//                                                       ? Container(
//                                                           width:
//                                                               item.size.width,
//                                                           height:
//                                                               item.size.height,
//                                                           color: item
//                                                               .content!
//                                                               .color,
//                                                         )
//                                                       : SizedBox.shrink(),
//                                                 ),
//                                               );
//                                             },
//                                             borderBuilder: (status, item) {
//                                               final CaseStyle style =
//                                                   CaseStyle();
//                                               final double leftRight =
//                                                   status == StackItemStatus.idle
//                                                   ? 0
//                                                   : -(style.buttonSize) / 2;
//                                               final double topBottom =
//                                                   status == StackItemStatus.idle
//                                                   ? 0
//                                                   : -(style.buttonSize) * 1.5;
//                                               return AnimatedContainer(
//                                                 duration: Duration(
//                                                   milliseconds: 500,
//                                                 ),
//                                                 child: Positioned(
//                                                   left: -leftRight,
//                                                   top: -topBottom,
//                                                   right: -leftRight,
//                                                   bottom: -topBottom,
//                                                   child: IgnorePointer(
//                                                     ignoring: true,
//                                                     child: CustomPaint(
//                                                       painter: _BorderPainter(
//                                                         dotted:
//                                                             status ==
//                                                             StackItemStatus
//                                                                 .idle,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                             onDel: controller.deleteItem,
//                                             onOffsetChanged: (item, offset) {
//                                               controller.onItemOffsetChanged(
//                                                 item,
//                                                 offset,
//                                               );
//                                               return true;
//                                             },
//                                             onSizeChanged: (item, size) {
//                                               controller.onItemSizeChanged(
//                                                 item,
//                                                 size,
//                                               );
//                                               return true;
//                                             },
//                                             onStatusChanged: (item, status) {
//                                               controller.onItemStatusChanged(
//                                                 item,
//                                                 status,
//                                               );
//                                               return true;
//                                             },
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Obx(() {
//                                       final isDragging =
//                                           controller.draggedItem.value != null;
//                                       return AnimatedOpacity(
//                                         opacity: isDragging ? 1.0 : 0.0,
//                                         duration: const Duration(
//                                           milliseconds: 200,
//                                         ),
//                                         child: CustomPaint(
//                                           painter: AlignmentGuidePainter(
//                                             draggedItem:
//                                                 controller.draggedItem.value,
//                                             alignmentPoints: controller
//                                                 .alignmentPoints
//                                                 .value,
//                                             stackBoardSize: controller
//                                                 .actualStackBoardRenderSize
//                                                 .value,
//                                             showGrid:
//                                                 controller.showGrid.value &&
//                                                 isDragging,
//                                             gridSize: controller.gridSize.value,
//                                             guideColor: Colors.blueAccent
//                                                 .withOpacity(0.6),
//                                             criticalGuideColor:
//                                                 Colors.greenAccent,
//                                             centerGuideColor: Colors.purple,
//                                           ),
//                                           size: controller
//                                               .actualStackBoardRenderSize
//                                               .value,
//                                         ),
//                                       );
//                                     }),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.all(8),
//             color: Colors.white,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Example sticker path (replace with actual sticker selection logic)
//                     controller.addSticker('assets/stickers/sticker1.png');
//                   },
//                   icon: Icon(Icons.image),
//                   label: Text('Sticker'),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     showHueSlider.value = !showHueSlider.value;
//                   },
//                   icon: Icon(Icons.color_lens),
//                   label: Text('Hue'),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     controller.addText();
//                     controller.removeTextEditorOverlay();
//                     if (controller.activeItem.value is StackTextItem) {
//                       showTextEditorOverlay(
//                         context,
//                         controller.activeItem.value as StackTextItem,
//                       );
//                     }
//                   },
//                   icon: Icon(Icons.text_fields),
//                   label: Text('Text'),
//                 ),
//               ],
//             ),
//           ),
//           Obx(
//             () => showHueSlider.value
//                 ? Container(
//                     padding: EdgeInsets.all(8),
//                     color: Colors.white,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text('Adjust Background Hue'),
//                         Slider(
//                           value: controller.backgroundHue.value,
//                           min: 0.0,
//                           max: 360.0,
//                           divisions: 360,
//                           label: '${controller.backgroundHue.value.round()}°',
//                           onChanged: (value) {
//                             controller.updateBackgroundHue(value);
//                           },
//                         ),
//                       ],
//                     ),
//                   )
//                 : SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }

//   void showTextEditorOverlay(BuildContext context, StackTextItem item) {
//     final overlay = Overlay.of(context);
//     late final OverlayEntry entry;

//     entry = OverlayEntry(
//       builder: (_) => Positioned(
//         bottom: 0,
//         left: 0,
//         right: 0,
//         child: Material(
//           elevation: 6,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: TextStylingEditor(
//             textItem: item,
//             onClose: () =>
//                 Get.find<EditorController>().removeTextEditorOverlay(),
//           ),
//         ),
//       ),
//     );

//     final controller = Get.find<EditorController>();
//     controller.removeTextEditorOverlay();
//     controller.activeTextEditorOverlay.value = entry;
//     overlay.insert(entry);
//   }

//   // Hue matrix for ColorFilter
//   List<double> _hueMatrix(double degrees) {
//     final radians = degrees * math.pi / 180;
//     final cosVal = math.cos(radians);
//     final sinVal = math.sin(radians);

//     const lumR = 0.213;
//     const lumG = 0.715;
//     const lumB = 0.122;

//     return [
//       lumR + cosVal * (1 - lumR) + sinVal * (-lumR),
//       lumG + cosVal * (-lumG) + sinVal * (-lumG),
//       lumB + cosVal * (-lumB) + sinVal * (1 - lumB),
//       0,
//       0,
//       lumR + cosVal * (-lumR) + sinVal * 0.143,
//       lumG + cosVal * (1 - lumG) + sinVal * 0.140,
//       lumB + cosVal * (-lumB) + sinVal * -0.283,
//       0,
//       0,
//       lumR + cosVal * (-lumR) + sinVal * (-(1 - lumR)),
//       lumG + cosVal * (-lumG) + sinVal * lumG,
//       lumB + cosVal * (1 - lumB) + sinVal * lumB,
//       0,
//       0,
//       0,
//       0,
//       0,
//       1,
//       0,
//     ];
//   }
// }

// class _BorderPainter extends CustomPainter {
//   final bool dotted;
//   final double stroke = 0.5;
//   final double dash = 3;
//   final double dash2 = 0;

//   const _BorderPainter({required this.dotted});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Get.find<EditorController>().draggedItem.value == null
//           ? Colors.blue
//           : Colors.red
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = stroke;

//     final Rect rect = Offset.zero & size;

//     if (!dotted) {
//       canvas.drawRect(rect, paint);
//       return;
//     }
//     if (Get.find<EditorController>().draggedItem.value != null) {
//       final Path path = Path()..addRect(rect);

//       final Path dashedPath = Path();
//       for (final pm in path.computeMetrics()) {
//         double d = 0;
//         while (d < pm.length) {
//           final double len = math.min(dash, pm.length - d);
//           dashedPath.addPath(pm.extractPath(d, d + len), Offset.zero);
//           d += dash * 2;
//         }
//       }
//       canvas.drawPath(dashedPath, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _BorderPainter old) => old.dotted != dotted;
// }

// class AlignmentGuidePainter extends CustomPainter {
//   final StackItem? draggedItem;
//   final List<AlignmentPoint> alignmentPoints;
//   final Size stackBoardSize;
//   final bool showGrid;
//   final double gridSize;
//   final Color guideColor;
//   final Color criticalGuideColor;
//   final Color centerGuideColor;

//   AlignmentGuidePainter({
//     required this.draggedItem,
//     required this.alignmentPoints,
//     required this.stackBoardSize,
//     required this.showGrid,
//     required this.gridSize,
//     required this.guideColor,
//     required this.criticalGuideColor,
//     required this.centerGuideColor,
//   });

//   void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
//     const double dashWidth = 2;
//     const double dashSpace = 2;
//     double distance = (end - start).distance;
//     final double dx = (end.dx - start.dx) / distance;
//     final double dy = (end.dy - start.dy) / distance;
//     double remainingDistance = distance;

//     Offset current = start;
//     while (remainingDistance > 0) {
//       final double step = math.min(dashWidth, remainingDistance);
//       final Offset next = Offset(
//         current.dx + dx * step,
//         current.dy + dy * step,
//       );
//       canvas.drawLine(current, next, paint);
//       current = Offset(next.dx + dx * dashSpace, next.dy + dy * dashSpace);
//       remainingDistance -= (step + dashSpace);
//     }
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (draggedItem == null) return;

//     final Paint gridPaint = Paint()
//       ..color = guideColor.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 0.2;

//     final Paint guidePaint = Paint()
//       ..color = guideColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.0;

//     final Paint snapPaint = Paint()
//       ..color = guideColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     final Paint criticalPaint = Paint()
//       ..color = criticalGuideColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.0;

//     final Paint centerPaint = Paint()
//       ..color = centerGuideColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.0;

//     if (showGrid) {
//       for (double x = 0; x <= stackBoardSize.width; x += gridSize) {
//         _drawDashedLine(
//           canvas,
//           Offset(x, 0),
//           Offset(x, stackBoardSize.height),
//           gridPaint,
//         );
//       }
//       for (double y = 0; y <= stackBoardSize.height; y += gridSize) {
//         _drawDashedLine(
//           canvas,
//           Offset(0, y),
//           Offset(stackBoardSize.width, y),
//           gridPaint,
//         );
//       }
//     }

//     for (final point in alignmentPoints) {
//       Paint paint;
//       switch (point.snapType) {
//         case SnapType.centerCritical:
//           paint = centerPaint;
//           break;
//         case SnapType.edgeCritical:
//           paint = criticalPaint;
//           break;
//         case SnapType.center:
//         case SnapType.edge:
//           paint = snapPaint;
//           break;
//         case SnapType.inactive:
//           paint = guidePaint..color = guideColor.withOpacity(0.3);
//           break;
//       }

//       if (point.isVertical) {
//         final start = Offset(point.value, 0);
//         final end = Offset(point.value, stackBoardSize.height);
//         if (point.isSnapped) {
//           canvas.drawLine(start, end, paint);
//         } else {
//           _drawDashedLine(canvas, start, end, paint);
//         }
//       } else {
//         final start = Offset(0, point.value);
//         final end = Offset(stackBoardSize.width, point.value);
//         if (point.isSnapped) {
//           canvas.drawLine(start, end, paint);
//         } else {
//           _drawDashedLine(canvas, start, end, paint);
//         }
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant AlignmentGuidePainter oldDelegate) {
//     return oldDelegate.draggedItem?.id != draggedItem?.id ||
//         oldDelegate.alignmentPoints.length != alignmentPoints.length ||
//         oldDelegate.alignmentPoints.any((p) => !alignmentPoints.contains(p)) ||
//         oldDelegate.stackBoardSize != stackBoardSize ||
//         oldDelegate.showGrid != showGrid ||
//         oldDelegate.gridSize != gridSize ||
//         oldDelegate.guideColor != guideColor ||
//         oldDelegate.criticalGuideColor != criticalGuideColor ||
//         oldDelegate.centerGuideColor != centerGuideColor;
//   }
// }

// class ColorStackItem1 extends StackItem<ColorContent> {
//   ColorStackItem1({
//     required super.size,
//     super.id,
//     super.offset,
//     super.angle = null,
//     super.status = null,
//     super.content,
//   }) : super(lockZOrder: true);

//   factory ColorStackItem1.fromJson(Map<String, dynamic> json) {
//     return ColorStackItem1(
//       id: json['id'],
//       size: Size(json['size']['width'], json['size']['height']),
//       offset: Offset(json['offset']['dx'], json['offset']['dy']),
//       angle: json['angle'],
//       status: json['status'] != null
//           ? StackItemStatus.values[json['status']]
//           : null,
//       content: json['content'] != null
//           ? ColorContent.fromJson(json['content'])
//           : null,
//     );
//   }

//   @override
//   ColorStackItem1 copyWith({
//     Size? size,
//     Offset? offset,
//     double? angle,
//     StackItemStatus? status,
//     bool? lockZOrder,
//     ColorContent? content,
//   }) {
//     return ColorStackItem1(
//       id: id,
//       size: size ?? this.size,
//       offset: offset ?? this.offset,
//       angle: angle ?? this.angle,
//       status: status ?? this.status,
//       content: content ?? this.content,
//     );
//   }
// }

// class ColorContent extends StackItemContent {
//   ColorContent({required this.color});

//   final Color color;

//   factory ColorContent.fromJson(Map<String, dynamic> json) {
//     return ColorContent(color: Color(json['color']));
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return <String, dynamic>{'color': color.value};
//   }
// }
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
    final RxBool showHueSlider = false.obs;
    final RxBool showStickerPanel = true.obs;
    final RxInt selectedToolIndex =
        0.obs; // 0: none, 1: sticker, 2: color, 3: text

    // Update StackBoard size after rendering
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (stackBoardKey.currentContext != null &&
          controller.activeItem.value == null) {
        final RenderBox? renderBox =
            stackBoardKey.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final Size size = renderBox.size;
          if (controller.actualStackBoardRenderSize.value != size) {
            controller.updateStackBoardRenderSize(size);
            debugPrint('Updated StackBoard size: $size');
            // Reload template to apply correct sizing
            if (controller.initialTemplate != null) {
              controller.loadTemplate(controller.initialTemplate!);
            }
          }
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
      body: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      if (controller.initialTemplate == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final double templateAspectRatio =
                          controller.initialTemplate!.width /
                          controller.initialTemplate!.height;
                      final double availableWidthForCanvas =
                          constraints.maxWidth;
                      final double availableHeightForCanvas =
                          constraints.maxHeight;
                      final double targetWidth = availableWidthForCanvas;
                      final double targetHeight =
                          targetWidth / templateAspectRatio;

                      // Ensure canvas fits within available height
                      final double finalHeight = targetHeight.clamp(
                        0.0,
                        availableHeightForCanvas,
                      );
                      final double finalWidth =
                          finalHeight * templateAspectRatio;

                      debugPrint(
                        'EditorPage: templateAspectRatio=$templateAspectRatio, '
                        'availableWidth=$availableWidthForCanvas, availableHeight=$availableHeightForCanvas, '
                        'targetWidth=$finalWidth, targetHeight=$finalHeight',
                      );

                      return Column(
                        children: [
                          // Text(targetWidth.toString()),
                          // Text(Get.width.toString()),
                          // Text(finalWidth.toString()),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: finalWidth,
                                maxHeight: finalHeight,
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              child: AspectRatio(
                                aspectRatio: templateAspectRatio,
                                child: Container(
                                  key: stackBoardKey,
                                  color: Colors.red[200],
                                  child: Obx(
                                    () => Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Expanded(
                                              child: StackBoard(
                                                controller:
                                                    controller.boardController,
                                                background: InkWell(
                                                  onTap: () {
                                                    controller.boardController
                                                        .setAllItemStatuses(
                                                          StackItemStatus.idle,
                                                        );
                                                    controller
                                                        .removeTextEditorOverlay();
                                                  },
                                                  child:
                                                      controller
                                                          .selectedBackground
                                                          .value
                                                          .isNotEmpty
                                                      ? ColorFiltered(
                                                          colorFilter:
                                                              ColorFilter.matrix(
                                                                _hueMatrix(
                                                                  controller
                                                                      .backgroundHue
                                                                      .value,
                                                                ),
                                                              ),
                                                          child: Image.asset(
                                                            controller
                                                                .selectedBackground
                                                                .value,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) => ColoredBox(
                                                                  color: Colors
                                                                      .grey[200]!,
                                                                  child: const Center(
                                                                    child: Text(
                                                                      'Background not found',
                                                                    ),
                                                                  ),
                                                                ),
                                                          ),
                                                        )
                                                      : ColoredBox(
                                                          color:
                                                              Colors.grey[200]!,
                                                        ),
                                                ),
                                                customBuilder:
                                                    (
                                                      StackItem<
                                                        StackItemContent
                                                      >
                                                      item,
                                                    ) {
                                                      return InkWell(
                                                        onTap: () {
                                                          controller
                                                              .boardController
                                                              .setAllItemStatuses(
                                                                StackItemStatus
                                                                    .idle,
                                                              );
                                                          controller
                                                              .boardController
                                                              .updateBasic(
                                                                item.id,
                                                                status:
                                                                    StackItemStatus
                                                                        .selected,
                                                              );
                                                          if (item
                                                              is StackTextItem) {
                                                            controller
                                                                .removeTextEditorOverlay();
                                                            showTextEditorOverlay(
                                                              context,
                                                              item,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          color: Colors
                                                              .blueAccent
                                                              .withOpacity(0.2),
                                                          child:
                                                              (item
                                                                      is StackTextItem &&
                                                                  item.content !=
                                                                      null)
                                                              ? StackTextCase(
                                                                  item: item,
                                                                )
                                                              : (item
                                                                        is StackImageItem &&
                                                                    item.content !=
                                                                        null)
                                                              ? StackImageCase(
                                                                  item: item,
                                                                )
                                                              : (item
                                                                        is ColorStackItem1 &&
                                                                    item.content !=
                                                                        null)
                                                              ? Container(
                                                                  width: item
                                                                      .size
                                                                      .width,
                                                                  height: item
                                                                      .size
                                                                      .height,
                                                                  color: item
                                                                      .content!
                                                                      .color,
                                                                )
                                                              : SizedBox.shrink(),
                                                        ),
                                                      );
                                                    },

                                                borderBuilder: (status, item) {
                                                  final CaseStyle style =
                                                      CaseStyle();
                                                  final double leftRight =
                                                      status ==
                                                          StackItemStatus.idle
                                                      ? 0
                                                      : -(style.buttonSize) / 2;
                                                  final double topBottom =
                                                      status ==
                                                          StackItemStatus.idle
                                                      ? 0
                                                      : -(style.buttonSize) *
                                                            1.5;
                                                  return AnimatedContainer(
                                                    duration: Duration(
                                                      milliseconds: 500,
                                                    ),
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
                                                                status ==
                                                                StackItemStatus
                                                                    .idle,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                onDel: controller.deleteItem,
                                                onOffsetChanged:
                                                    (item, offset) {
                                                      controller
                                                          .onItemOffsetChanged(
                                                            item,
                                                            offset,
                                                          );
                                                      return true;
                                                    },
                                                onSizeChanged: (item, size) {
                                                  controller.onItemSizeChanged(
                                                    item,
                                                    size,
                                                  );
                                                  return true;
                                                },
                                                onStatusChanged:
                                                    (item, status) {
                                                      controller
                                                          .onItemStatusChanged(
                                                            item,
                                                            status,
                                                          );
                                                      return true;
                                                    },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Obx(() {
                                          final isDragging =
                                              controller.draggedItem.value !=
                                              null;
                                          return AnimatedOpacity(
                                            opacity: isDragging ? 1.0 : 0.0,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: CustomPaint(
                                              painter: AlignmentGuidePainter(
                                                draggedItem: controller
                                                    .draggedItem
                                                    .value,
                                                alignmentPoints: controller
                                                    .alignmentPoints
                                                    .value,
                                                stackBoardSize: controller
                                                    .actualStackBoardRenderSize
                                                    .value,
                                                showGrid:
                                                    controller.showGrid.value &&
                                                    isDragging,
                                                gridSize:
                                                    controller.gridSize.value,
                                                guideColor: Colors.blueAccent
                                                    .withOpacity(0.6),
                                                criticalGuideColor:
                                                    Colors.greenAccent,
                                                centerGuideColor: Colors.purple,
                                              ),
                                              size: controller
                                                  .actualStackBoardRenderSize
                                                  .value,
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: true,
            child: Container(
              padding: EdgeInsets.all(4),
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
                          },
                          isActive: selectedToolIndex.value == 3,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => showStickerPanel.value
                        ? _StickerPanel(controller: controller)
                        : SizedBox.shrink(),
                  ),
                  Obx(
                    () => showHueSlider.value
                        ? _HueAdjustmentPanel(controller: controller)
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          child: TextStylingEditor(
            textItem: item,
            onClose: () {
              Get.find<EditorController>().removeTextEditorOverlay();
            },
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

import 'dart:io';
import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/text_editor.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_case.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
import 'package:cardmaker/stack_board/lib/widget_style_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_view/photo_view.dart';
import 'package:screenshot/screenshot.dart';

// Define panel types as an enum
enum PanelType {
  none,
  stickers,
  color,
  text,
  shapes,
  advancedImage, // Add this new panel type
}

enum ImagePreset { vintage, blackAndWhite, vibrant, soft, dramatic }

class EditorPage extends GetView<EditorController> {
  bool isExporting = false;

  EditorPage({super.key});

  final ScreenshotController screenshotController = ScreenshotController();
  final RxBool allowTouch =
      false.obs; // Default to false, enable for active PhotoView
  final Rx<StackImageItem?> activePhotoItem = Rx<StackImageItem?>(
    null,
  ); // Track active PhotoView

  // Single state to manage active panel
  final Rx<PanelType> activePanel = PanelType.none.obs;
  RxBool isShowEditIcon = false.obs;

  StackItem deserializeItem(Map<String, dynamic> itemJson) {
    final type = itemJson['type'];
    if (type == 'StackTextItem') {
      return StackTextItem.fromJson(itemJson);
    } else if (type == 'StackImageItem') {
      return StackImageItem.fromJson(itemJson);
    } else if (type == 'RowStackItem') {
      return RowStackItem.fromJson(itemJson);
    } else {
      throw Exception('Unsupported item type: $type');
    }
  }

  Widget _buildCanvasStack({
    required bool showGrid,
    required bool showBorders,
    required GlobalKey stackBoardKey,
    required RxDouble canvasScale,
    required RxDouble scaledCanvasWidth,
    required RxDouble scaledCanvasHeight,
  }) {
    return Obx(
      () => Stack(
        alignment: Alignment.center,
        children: [
          // Background image
          IgnorePointer(
            ignoring: true,
            child: SizedBox(
              width: scaledCanvasWidth.value,
              height: scaledCanvasHeight.value,
              child: controller.selectedBackground.value.isNotEmpty
                  ? ColorFiltered(
                      colorFilter: ColorFilter.matrix(
                        _hueMatrix(controller.backgroundHue.value),
                      ),
                      child: Image.asset(
                        controller.selectedBackground.value,
                        width: scaledCanvasWidth.value,
                        height: scaledCanvasHeight.value,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Container(color: Colors.grey[200]),
            ),
          ),
          // Dynamic PhotoView for each profile image
          ...controller.profileImageItems.map(
            (profileItem) => Positioned(
              left: profileItem.offset.dx * canvasScale.value,
              top: profileItem.offset.dy * canvasScale.value,
              child: ClipRect(
                child: SizedBox(
                  width: profileItem.size.width * canvasScale.value,
                  height: profileItem.size.height * canvasScale.value,
                  child: PhotoView(
                    imageProvider: AssetImage(
                      profileItem.content?.assetName ?? "",
                    ),
                    minScale: PhotoViewComputedScale.contained * 0.4,
                    maxScale: PhotoViewComputedScale.covered * 3.0,
                    initialScale: PhotoViewComputedScale.contained,
                    basePosition: Alignment.center,
                    enablePanAlways: true,
                    filterQuality: FilterQuality.high,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Foreground image with transparent hole
          if (controller.initialTemplate?.backgroundImage.isNotEmpty ?? false)
            IgnorePointer(
              ignoring: true,
              child: SizedBox(
                width: scaledCanvasWidth.value,
                height: scaledCanvasHeight.value,
                child: Image.asset(
                  controller.initialTemplate?.backgroundImage ?? "",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          // StackBoard with touch handling
          SizedBox(
            width: scaledCanvasWidth.value,
            height: scaledCanvasHeight.value,
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: showGrid
                  ? (event) {
                      final localPos = event.localPosition;
                      final scale = canvasScale.value;
                      StackImageItem? tappedItem = controller.profileImageItems
                          .firstWhereOrNull((item) {
                            final hole = Rect.fromLTWH(
                              item.offset.dx * scale,
                              item.offset.dy * scale,
                              item.size.width * scale,
                              item.size.height * scale,
                            );
                            return hole.contains(localPos);
                          });
                      if (tappedItem != null) {
                        print(
                          "Touched inside ${tappedItem.id}, activating PhotoView.",
                        );
                        activePhotoItem.value = tappedItem;
                        allowTouch.value =
                            true; // Lock StackBoard for this PhotoView
                      } else {
                        print(
                          "Touched outside PhotoView areas, enabling StackBoard.",
                        );
                        activePhotoItem.value = null;
                        allowTouch.value = false; // Enable StackBoard
                      }
                    }
                  : null,
              child: Obx(
                () => IgnorePointer(
                  ignoring: allowTouch.value,
                  child: StackBoard(
                    key: stackBoardKey,

                    controller: controller.boardController,
                    background: InkWell(
                      onTap: () {
                        activePanel.value = PanelType.none;

                        controller.boardController.unSelectAll(
                          // StackItemStatus.idle,
                        );
                      },
                    ),
                    customBuilder: (StackItem<StackItemContent> item) {
                      return (item is StackTextItem && item.content != null)
                          ? StackTextCase(item: item, isFitted: true)
                          : (item is StackImageItem && item.content != null)
                          ? StackImageCase(item: item)
                          : (item is ColorStackItem1 && item.content != null)
                          ? Container(
                              width: item.size.width,
                              height: item.size.height,
                              color: item.content!.color,
                            )
                          : (item is RowStackItem && item.content != null)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: item.content!.items
                                  .map(
                                    (subItem) => subItem is StackTextItem
                                        ? StackTextCase(item: subItem)
                                        : const SizedBox.shrink(),
                                  )
                                  .toList(),
                            )
                          : const SizedBox.shrink();
                    },

                    borderBuilder: showBorders
                        ? (status, item) {
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
                                    painter: BorderPainter(
                                      dotted: status == StackItemStatus.idle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        : (status, item) => const SizedBox.shrink(),
                    onDel: (item) =>
                        controller.boardController.removeById(item.id),

                    // onStatusChanged: (item, status) {
                    //   if (status == StackItemStatus.selected) {
                    //     controller.activeItem.value = item;
                    //     if (item is StackTextItem) {
                    //       activePanel.value = PanelType.text;
                    //     } else {
                    //       activePanel.value = PanelType.none;
                    //     }
                    //     controller.draggedItem.value =
                    //         null; // Clear dragged item
                    //     controller.alignmentPoints.value =
                    //         []; // Clear alignment points
                    //   } else if (status == StackItemStatus.moving) {
                    //     activePanel.value = PanelType.none;
                    //     controller.draggedItem.value = item; // Set dragged item
                    //   } else if (status == StackItemStatus.idle) {
                    //     activePanel.value = PanelType.none;
                    //     if (controller.draggedItem.value?.id == item.id) {
                    //       controller.draggedItem.value =
                    //           null; // Clear dragged item
                    //     }
                    //   }
                    //   return true;
                    // },
                    onStatusChanged: (item, status) {
                      if (status == StackItemStatus.selected) {
                        controller.activeItem.value = item;
                        if (item is StackTextItem) {
                          activePanel.value = PanelType.text;
                        } else if (item is StackImageItem) {
                          // Show advanced image panel when image is selected
                          activePanel.value = PanelType.advancedImage;
                        } else {
                          activePanel.value = PanelType.none;
                        }
                        controller.draggedItem.value = null;
                        controller.alignmentPoints.value = [];
                      } else if (status == StackItemStatus.moving) {
                        activePanel.value = PanelType.none;
                        controller.draggedItem.value = item;
                      } else if (status == StackItemStatus.idle) {
                        activePanel.value = PanelType.none;
                        if (controller.draggedItem.value?.id == item.id) {
                          controller.draggedItem.value = null;
                        }
                      }
                      return true;
                    },
                  ),
                ),
              ),
            ),
          ),
          // Alignment guides
          if (showGrid)
            IgnorePointer(
              ignoring: true,
              child: CustomPaint(
                size: Size(scaledCanvasWidth.value, scaledCanvasHeight.value),
                painter: AlignmentGuidePainter(
                  draggedItem: controller.draggedItem.value,
                  alignmentPoints: controller.alignmentPoints,
                  stackBoardSize: Size(
                    scaledCanvasWidth.value,
                    scaledCanvasHeight.value,
                  ),
                  showGrid: controller.showGrid.isTrue,
                  gridSize: 50.0,
                  guideColor: Colors.blue.withOpacity(0.5),
                  criticalGuideColor: Colors.red,
                  centerGuideColor: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> exportAsPDF() async {
      try {
        isExporting = true;
        controller.update(['export_button']);
        controller.boardController.unSelectAll();
        final exportKey = GlobalKey();
        final image = await screenshotController.captureFromWidget(
          Material(
            child: SizedBox(
              width: controller.scaledCanvasWidth.value,
              height: controller.scaledCanvasHeight.value,
              key: exportKey,
              child: Transform.scale(
                scale: 0.95,
                child: _buildCanvasStack(
                  showGrid: false,
                  showBorders: false,
                  stackBoardKey: GlobalKey(),
                  canvasScale: controller.canvasScale,
                  scaledCanvasWidth: controller.scaledCanvasWidth,
                  scaledCanvasHeight: controller.scaledCanvasHeight,
                ),
              ),
            ),
          ),
          targetSize: Size(
            controller.scaledCanvasWidth.value,
            controller.scaledCanvasHeight.value,
          ),
          pixelRatio: 2,
        );

        final tempDir = await getTemporaryDirectory();
        final imagePath = '${tempDir.path}/temp_invitation_card.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        final pdf = pw.Document();
        final imageProvider = pw.MemoryImage(image);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              controller.scaledCanvasWidth.value,
              controller.scaledCanvasHeight.value,
            ),
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(imageProvider));
            },
          ),
        );

        final pdfPath = '${tempDir.path}/invitation_card.pdf';
        final pdfFile = File(pdfPath);
        await pdfFile.writeAsBytes(await pdf.save());

        if (await pdfFile.exists()) {
          Get.to(
            () => ExportPreviewPage(imagePath: imagePath, pdfPath: pdfPath),
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to create PDF file',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      } catch (e, s) {
        debugPrint('Export PDF failed: $e\n$s');
        Get.snackbar(
          'Error',
          'Failed to export PDF due to widget issue',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      } finally {
        isExporting = false;
        controller.update(['export_button']);
      }
    }

    Future<void> exportAsImage() async {
      try {
        isExporting = true;
        controller.update(['export_button']);
        controller.boardController.unSelectAll();
        final exportKey = GlobalKey();

        final image = await screenshotController.captureFromWidget(
          Material(
            child: SizedBox(
              width: controller.scaledCanvasWidth.value,
              height: controller.scaledCanvasHeight.value,
              key: exportKey,
              child: _buildCanvasStack(
                showGrid: false,
                showBorders: false,
                stackBoardKey: GlobalKey(),
                canvasScale: controller.canvasScale,
                scaledCanvasWidth: controller.scaledCanvasWidth,
                scaledCanvasHeight: controller.scaledCanvasHeight,
              ),
            ),
          ),
          targetSize: Size(
            controller.scaledCanvasWidth.value,
            controller.scaledCanvasHeight.value,
          ),
          pixelRatio: 2,
        );

        final output = await getTemporaryDirectory();
        final file = File("${output.path}/invitation_card.png");
        await file.writeAsBytes(image);
        Get.snackbar(
          'Success',
          'Image exported successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        Get.to(() => ExportPreviewPage(imagePath: file.path, pdfPath: ''));
      } catch (e, s) {
        debugPrint('Export Image failed: $e\n$s');
        Get.snackbar(
          'Error',
          'Failed to export image due to widget issue',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      } finally {
        isExporting = false;
        controller.update(['export_button']);
      }
    }

    Widget buildPanelContent() {
      if (activePanel.value == PanelType.stickers) {
        return _StickerPanel(controller: controller);
      } else if (activePanel.value == PanelType.color) {
        return _HueAdjustmentPanel(controller: controller);
      } else if (activePanel.value == PanelType.text &&
          controller.activeItem.value is StackTextItem) {
        return _TextEditorPanel(
          key: ValueKey(controller.activeItem.value!.id),
          controller: controller,
          textItem: controller.activeItem.value as StackTextItem,
        );
      } else if (activePanel.value == PanelType.shapes) {
        return _ShapePanel(controller: controller);
      } else if (activePanel.value == PanelType.advancedImage &&
          controller.activeItem.value is StackImageItem) {
        // Add the new advanced image panel
        return AdvancedImagePanel(
          key: ValueKey(controller.activeItem.value!.id),
          imageItem: controller.activeItem.value as StackImageItem,
          onUpdate: () {
            // Update the canvas when image properties change
            controller.update();
          },
        );
      }
      return const SizedBox.shrink();
    }

    IconData getPanelIcon(PanelType panelType) {
      switch (panelType) {
        case PanelType.stickers:
          return Icons.emoji_emotions;
        case PanelType.color:
          return Icons.palette;
        case PanelType.text:
          return Icons.text_fields;
        case PanelType.shapes:
          return Icons.outbond_outlined;
        case PanelType.advancedImage:
          return Icons.photo_filter;
        case PanelType.none:
        default:
          return Icons.close;
      }
    }

    // Update your _getPanelTitle helper method:
    String getPanelTitle(PanelType panelType) {
      switch (panelType) {
        case PanelType.stickers:
          return 'Stickers';
        case PanelType.color:
          return 'Colors';
        case PanelType.text:
          return 'Text Editor';
        case PanelType.shapes:
          return 'Shapes';
        case PanelType.advancedImage:
          return 'Image Editor';
        case PanelType.none:
        default:
          return '';
      }
    }

    // Widget buildPanelContent() {
    //   if (activePanel.value == PanelType.stickers) {
    //     return _StickerPanel(controller: controller);
    //   } else if (activePanel.value == PanelType.color) {
    //     return _HueAdjustmentPanel(controller: controller);
    //   } else if (activePanel.value == PanelType.text &&
    //       controller.activeItem.value is StackTextItem) {
    //     return _TextEditorPanel(
    //       key: ValueKey(controller.activeItem.value!.id),
    //       controller: controller,
    //       textItem: controller.activeItem.value as StackTextItem,
    //     );
    //   } else if (activePanel.value == PanelType.shapes) {
    //     return _ShapePanel(controller: controller);
    //   }
    //   return const SizedBox.shrink();
    // }

    return Scaffold(
      // Professional App Bar
      appBar: AppBar(
        elevation: 0,

        // backgroundColor: Colors.white,
        actions: [
          // Export Button with Menu
          _ModernExportButton(
            onExportPDF: exportAsPDF,
            onExportImage: exportAsImage,
            onSave: () => controller.exportDesign(),
            isExporting: isExporting,
          ),

          SizedBox(width: 16),
        ],
      ),

      // Dynamic Bottom Sheet for Panels
      bottomSheet: Obx(() {
        if (activePanel.value == PanelType.none) return SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Panel Header
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),

            //   child: Row(
            //     children: [
            //       Icon(
            //         _getPanelIcon(activePanel.value),
            //         size: 20,
            //         color: AppColors.branding,
            //       ),
            //       SizedBox(width: 8),
            //       Text(
            //         _getPanelTitle(activePanel.value),
            //         style: TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w600,
            //           color: Colors.grey[800],
            //         ),
            //       ),
            //       Spacer(),
            //       IconButton(
            //         icon: Icon(Icons.close, size: 20),
            //         onPressed: () => activePanel.value = PanelType.none,
            //         color: Colors.grey[600],
            //       ),
            //     ],
            //   ),
            // ),
            // Panel Content
            AnimatedSize(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: buildPanelContent(),
            ),
          ],
        );
      }),

      // Main Body
      body: GestureDetector(
        onTap: () {
          activePanel.value = PanelType.none;
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Canvas Area
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    elevation: 10,
                    // alignment: Alignment.topCenter,

                    // margin: EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              controller.updateCanvasAndLoadTemplate(
                                constraints,
                                context,
                              );
                            });
                            return _buildCanvasStack(
                              showGrid: true,
                              showBorders: true,
                              stackBoardKey: controller.stackBoardKey,
                              canvasScale: controller.canvasScale,
                              scaledCanvasWidth: controller.scaledCanvasWidth,
                              scaledCanvasHeight: controller.scaledCanvasHeight,
                            );
                          },
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Get.theme.shadowColor)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfessionalToolbarButton(
                        icon: Icons.emoji_emotions_outlined,
                        activeIcon: Icons.emoji_emotions,
                        label: 'Stickers',
                        panelType: PanelType.stickers,
                        activePanel: activePanel,
                        onPressed: () {
                          activePanel.value =
                              activePanel.value == PanelType.stickers
                              ? PanelType.none
                              : PanelType.stickers;
                        },
                      ),
                      _ProfessionalToolbarButton(
                        icon: Icons.palette_outlined,
                        activeIcon: Icons.palette,
                        label: 'Colors',
                        panelType: PanelType.color,
                        activePanel: activePanel,
                        onPressed: () {
                          activePanel.value =
                              activePanel.value == PanelType.color
                              ? PanelType.none
                              : PanelType.color;
                        },
                      ),
                      _ProfessionalToolbarButton(
                        icon: Icons.text_fields_outlined,
                        activeIcon: Icons.text_fields,
                        label: 'Text',
                        panelType: PanelType.text,
                        activePanel: activePanel,
                        onPressed: () {
                          if (activePanel.value == PanelType.text) {
                            activePanel.value = PanelType.none;
                          } else {
                            if (controller.activeItem.value == null ||
                                controller.activeItem.value is! StackTextItem) {
                              controller.addText("Tap to edit text");
                            }
                            activePanel.value = PanelType.text;
                          }
                        },
                      ),
                      // Add new image editing button
                      _ProfessionalToolbarButton(
                        icon: Icons.photo_filter_outlined,
                        activeIcon: Icons.photo_filter,
                        label: 'Image',
                        panelType: PanelType.advancedImage,
                        activePanel: activePanel,
                        onPressed: () {
                          if (activePanel.value == PanelType.advancedImage) {
                            activePanel.value = PanelType.none;
                          } else {
                            // Check if there's an active image item
                            if (controller.activeItem.value != null &&
                                controller.activeItem.value is StackImageItem) {
                              activePanel.value = PanelType.advancedImage;
                            } else {
                              // Show message to select an image first
                              Get.snackbar(
                                'Select Image',
                                'Please select an image to edit its properties',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange.shade100,
                                colorText: Colors.orange.shade900,
                                duration: const Duration(seconds: 2),
                              );
                            }
                          }
                        },
                      ),
                      _ProfessionalToolbarButton(
                        icon: Icons.outbond,
                        activeIcon: Icons.outbond_outlined,
                        label: 'Shapes',
                        panelType: PanelType.shapes,
                        activePanel: activePanel,
                        onPressed: () {
                          activePanel.value =
                              activePanel.value == PanelType.shapes
                              ? PanelType.none
                              : PanelType.shapes;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Professional Toolbar
              // SafeArea(
              //   child: Container(
              //     margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
              //     padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              //     decoration: BoxDecoration(
              //       color: Get.theme.colorScheme.surfaceContainer,
              //       borderRadius: BorderRadius.circular(16),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Get.theme.shadowColor,
              //           // blurRadius: 20,
              //           // offset: Offset(0, 4),
              //         ),
              //       ],
              //     ),

              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       children: [
              //         _ProfessionalToolbarButton(
              //           icon: Icons.emoji_emotions_outlined,
              //           activeIcon: Icons.emoji_emotions,
              //           label: 'Stickers',
              //           panelType: PanelType.stickers,
              //           activePanel: activePanel,
              //           onPressed: () {
              //             activePanel.value =
              //                 activePanel.value == PanelType.stickers
              //                 ? PanelType.none
              //                 : PanelType.stickers;
              //           },
              //         ),
              //         _ProfessionalToolbarButton(
              //           icon: Icons.palette_outlined,
              //           activeIcon: Icons.palette,
              //           label: 'Colors',
              //           panelType: PanelType.color,
              //           activePanel: activePanel,
              //           onPressed: () {
              //             activePanel.value =
              //                 activePanel.value == PanelType.color
              //                 ? PanelType.none
              //                 : PanelType.color;
              //           },
              //         ),
              //         _ProfessionalToolbarButton(
              //           icon: Icons.text_fields_outlined,
              //           activeIcon: Icons.text_fields,
              //           label: 'Text',
              //           panelType: PanelType.text,
              //           activePanel: activePanel,
              //           onPressed: () {
              //             if (activePanel.value == PanelType.text) {
              //               activePanel.value = PanelType.none;
              //             } else {
              //               if (controller.activeItem.value == null ||
              //                   controller.activeItem.value is! StackTextItem) {
              //                 controller.addText("Tap to edit text");
              //               }
              //               activePanel.value = PanelType.text;
              //             }
              //           },
              //         ),
              //         _ProfessionalToolbarButton(
              //           icon: Icons.outbond,
              //           activeIcon: Icons.outbond_outlined,
              //           label: 'Shapes',
              //           panelType: PanelType.shapes,
              //           activePanel: activePanel,
              //           onPressed: () {
              //             activePanel.value =
              //                 activePanel.value == PanelType.shapes
              //                 ? PanelType.none
              //                 : PanelType.shapes;
              //           },
              //         ),
              //       ],
              //     ),
              //   ),

              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for panel management

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

class _ShapePanel extends StatelessWidget {
  final EditorController controller;

  const _ShapePanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.grey[200],
      child: Center(child: Text('Shapes Panel (Implement as needed)')),
    );
  }
}

class _StickerPanel extends StatelessWidget {
  final EditorController controller;

  const _StickerPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final categories = {
      'Popular': [
        '❤️',
        '😍',
        '🎉',
        '✨',
        '🌟',
        '💝',
        '🎈',
        '🎊',
        '🥳',
        '💕',
        '🎁',
        '🌈',
        '⭐',
        '💎',
        '🔥',
        '👑',
      ],
      'Emojis': [
        '😀',
        '😂',
        '🥰',
        '😎',
        '🤩',
        '😘',
        '🙂',
        '😊',
        '😇',
        '🤗',
        '🤔',
        '😋',
        '😜',
        '🤪',
        '😴',
        '🥺',
      ],
      'Hearts': [
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
      'Party': [
        '🎉',
        '🎊',
        '🎈',
        '🎁',
        '🎂',
        '🍰',
        '🥳',
        '🪅',
        '🎆',
        '🎇',
        '✨',
        '🌟',
        '💫',
        '⭐',
        '🎪',
        '🎭',
      ],
      'Nature': [
        '🌸',
        '🌺',
        '🌻',
        '🌷',
        '🌹',
        '🌿',
        '🍃',
        '🌳',
        '🌲',
        '🌴',
        '🌵',
        '🌾',
        '🌊',
        '⛅',
        '🌈',
        '☀️',
      ],
      'Symbols': [
        '✨',
        '⭐',
        '💎',
        '👑',
        '🔥',
        '💫',
        '⚡',
        '🌟',
        '💥',
        '🎯',
        '🏆',
        '🎖️',
        '🏅',
        '🥇',
        '🎗️',
        '🎪',
      ],
    };

    return Container(
      height: 180,
      decoration: BoxDecoration(color: Colors.white),
      child: DefaultTabController(
        length: categories.length,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.branding,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppColors.branding,
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: categories.keys.map((category) {
                  return Tab(text: category);
                }).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: categories.values.map((stickers) {
                  return GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: stickers.length,
                    itemBuilder: (context, index) {
                      final sticker = stickers[index];
                      return GestureDetector(
                        onTap: () {
                          controller.addText(sticker);
                          // Haptic feedback
                          // HapticFeedback.lightImpact();
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Center(
                            child: Text(
                              sticker,
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      );
                    },
                  );
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Background Color',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Obx(
            () => Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hue: ${controller.backgroundHue.value.round()}°',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.branding,
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: AppColors.branding,
                          overlayColor: AppColors.branding.withOpacity(0.2),
                          trackHeight: 6,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: controller.backgroundHue.value,
                          min: 0.0,
                          max: 360.0,
                          onChanged: (value) {
                            controller.updateBackgroundHue(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.refresh, color: Colors.grey[600]),
                    onPressed: () {
                      controller.updateBackgroundHue(0.0);
                    },
                    tooltip: 'Reset',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Color Presets
          Text(
            'Presets',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _ColorPreset(color: Colors.red, hue: 0, controller: controller),
              _ColorPreset(
                color: Colors.orange,
                hue: 30,
                controller: controller,
              ),
              _ColorPreset(
                color: Colors.yellow,
                hue: 60,
                controller: controller,
              ),
              _ColorPreset(
                color: Colors.green,
                hue: 120,
                controller: controller,
              ),
              _ColorPreset(
                color: Colors.blue,
                hue: 240,
                controller: controller,
              ),
              _ColorPreset(
                color: Colors.purple,
                hue: 270,
                controller: controller,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Color Preset Widget
class _ColorPreset extends StatelessWidget {
  final Color color;
  final double hue;
  final EditorController controller;

  const _ColorPreset({
    required this.color,
    required this.hue,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.updateBackgroundHue(hue),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  final bool dotted;
  final double stroke = 0.5;
  final double dash = 3;
  final double dash2 = 0;

  const BorderPainter({required this.dotted});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Get.find<EditorController>().draggedItem.value == null
          ? AppColors.accent
          : AppColors.accent
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
  bool shouldRepaint(covariant BorderPainter old) => old.dotted != dotted;
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

    if (draggedItem != null) {
      _drawDashedLine(
        canvas,
        Offset(stackBoardSize.width / 2, 0),
        Offset(stackBoardSize.width / 2, stackBoardSize.height),
        centerPaint,
      );
      _drawDashedLine(
        canvas,
        Offset(0, stackBoardSize.height / 2),
        Offset(stackBoardSize.width, stackBoardSize.height / 2),
        centerPaint,
      );
    }

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
    bool? isCentered,
    bool? isProfileImage,
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
    bool? isProfileImage, // Added to match base class signature
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
    } else if (type == 'RowStackItem') {
      return RowStackItem.fromJson(itemJson);
    } else {
      throw Exception('Unsupported item type: $type');
    }
  }
}

class ExportPreviewPage extends StatelessWidget {
  final String imagePath;
  final String pdfPath;

  const ExportPreviewPage({
    super.key,
    required this.imagePath,
    required this.pdfPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Generated Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.file(
              File(imagePath),
              width: 300,
              height: 400,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Generated PDF',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await OpenFile.open(pdfPath);
                if (result.type != ResultType.done) {
                  Get.snackbar(
                    'Error',
                    'Failed to open PDF: ${result.message}',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Open PDF'),
            ),
            const SizedBox(height: 10),
            Text(
              'Location: $pdfPath',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalToolbarButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final PanelType panelType;
  final Rx<PanelType> activePanel;
  final VoidCallback onPressed;

  const _ProfessionalToolbarButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.panelType,
    required this.activePanel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = activePanel.value == panelType;
      return GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.branding.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: Duration(milliseconds: 200),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.branding : Colors.grey[600],
                  size: 24,
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.branding : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// Professional Export Menu Button
// Professional Export Menu Button
// Modern Export Button
class _ModernExportButton extends StatelessWidget {
  final VoidCallback onExportPDF;
  final VoidCallback onExportImage;
  final VoidCallback onSave;
  final bool isExporting;

  const _ModernExportButton({
    required this.onExportPDF,
    required this.onExportImage,
    required this.onSave,
    required this.isExporting,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: "export_button",
      builder: (_) => PopupMenuButton<String>(
        offset: Offset(0, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        enabled: !isExporting,
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'save',
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.save_outlined,
                    color: AppColors.accent,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save Project',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Save current design',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'pdf',
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: Colors.red.shade700,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export as PDF',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'High-quality PDF format',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'image',
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.purple.shade700,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export as Image',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'PNG format for sharing',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case 'save':
              onSave();
              // Show success feedback
              Get.snackbar(
                '',
                '',
                titleText: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Saved!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                messageText: Text('Your design has been saved successfully'),
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green.shade50,
                colorText: Colors.green.shade800,
                borderRadius: 12,
                margin: EdgeInsets.all(16),
                duration: Duration(seconds: 2),
              );
              break;
            case 'pdf':
              onExportPDF();
              break;
            case 'image':
              onExportImage();
              break;
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.branding,
            // gradient: LinearGradient(
            //   colors: [
            //     AppColors.branding,
            //     AppColors.accent.withValues(alpha: 0.5),
            //   ],
            // ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isExporting) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Exporting...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.file_download_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Export',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.expand_more, size: 18, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced Text Editor Panel
class _TextEditorPanel extends StatelessWidget {
  final EditorController controller;
  final StackTextItem textItem;

  const _TextEditorPanel({
    super.key,
    required this.controller,
    required this.textItem,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,

      alignment: Alignment.topRight,
      children: [
        TextStylingEditor(
          key: key,
          textItem: textItem,
          onClose: () {
            // Keep the panel open for better UX
          },
        ),

        Positioned(
          top: -32,
          child: FloatingActionButton.small(
            backgroundColor: AppColors.accent,
            child: Icon(Icons.edit, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

// Professional Compact Image Editor Panel
class AdvancedImagePanel extends StatefulWidget {
  final StackImageItem imageItem;
  final VoidCallback onUpdate;

  const AdvancedImagePanel({
    super.key,
    required this.imageItem,
    required this.onUpdate,
  });

  @override
  State<AdvancedImagePanel> createState() => _AdvancedImagePanelState();
}

class _AdvancedImagePanelState extends State<AdvancedImagePanel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  ImageItemContent get content => widget.imageItem.content!;

  void _updateImage() {
    widget.onUpdate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: _isExpanded ? 300 : 140,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compact Header
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.photo_filter,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Image Editor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _CompactButton(
                  icon: Icons.refresh_rounded,
                  onTap: () {
                    content.resetFilters();
                    _updateImage();
                  },
                ),
                const SizedBox(width: 8),
                _CompactButton(
                  icon: _isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),

          // Category Tabs
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryTab(
                  title: 'Adjust',
                  icon: Icons.tune,
                  isActive: _currentPage == 0,
                  onTap: () => _goToPage(0),
                ),
                _CategoryTab(
                  title: 'Filters',
                  icon: Icons.filter_vintage,
                  isActive: _currentPage == 1,
                  onTap: () => _goToPage(1),
                ),
                _CategoryTab(
                  title: 'Effects',
                  icon: Icons.auto_fix_high,
                  isActive: _currentPage == 2,
                  onTap: () => _goToPage(2),
                ),
                _CategoryTab(
                  title: 'Border',
                  icon: Icons.border_outer,
                  isActive: _currentPage == 3,
                  onTap: () => _goToPage(3),
                ),
                _CategoryTab(
                  title: 'Transform',
                  icon: Icons.transform,
                  isActive: _currentPage == 4,
                  onTap: () => _goToPage(4),
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _AdjustPage(content: content, onUpdate: _updateImage),
                _FiltersPage(content: content, onUpdate: _updateImage),
                _EffectsPage(content: content, onUpdate: _updateImage),
                _BorderPage(content: content, onUpdate: _updateImage),
                _TransformPage(content: content, onUpdate: _updateImage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}

// Adjust Page - Compact sliders
class _AdjustPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;

  const _AdjustPage({required this.content, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CompactSlider(
                  icon: Icons.brightness_6,
                  value: content.brightness,
                  min: -1.0,
                  max: 1.0,
                  onChanged: (v) {
                    content.adjustBrightness(v);
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactSlider(
                  icon: Icons.contrast,
                  value: content.contrast,
                  min: 0.0,
                  max: 2.0,
                  defaultValue: 1.0,
                  onChanged: (v) {
                    content.adjustContrast(v);
                    onUpdate();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CompactSlider(
                  icon: Icons.water_drop,
                  value: content.saturation,
                  min: 0.0,
                  max: 2.0,
                  defaultValue: 1.0,
                  onChanged: (v) {
                    content.adjustSaturation(v);
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactSlider(
                  icon: Icons.opacity,
                  value: content.opacity,
                  min: 0.0,
                  max: 1.0,
                  defaultValue: 1.0,
                  onChanged: (v) {
                    content.adjustOpacity(v);
                    onUpdate();
                  },
                ),
              ),
            ],
          ),
          if (context
                  .findAncestorStateOfType<_AdvancedImagePanelState>()
                  ?._isExpanded ??
              false) ...[
            const SizedBox(height: 12),
            _CompactSlider(
              icon: Icons.palette,
              value: content.hue,
              min: 0.0,
              max: 360.0,
              onChanged: (v) {
                content.adjustHue(v);
                onUpdate();
              },
            ),
          ],
        ],
      ),
    );
  }
}

// Filters Page - Grid of filter thumbnails
class _FiltersPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;

  const _FiltersPage({required this.content, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Quick Presets Row
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterPreview(
                  name: 'Original',
                  isActive: _isOriginal(),
                  onTap: () {
                    content.resetFilters();
                    onUpdate();
                  },
                ),
                _FilterPreview(
                  name: 'Vintage',
                  isActive: content.vintage,
                  onTap: () {
                    _applyVintage();
                    onUpdate();
                  },
                ),
                _FilterPreview(
                  name: 'B&W',
                  isActive: content.grayscale,
                  onTap: () {
                    content.applyFilter(ImageFilter.grayscale);
                    onUpdate();
                  },
                ),
                _FilterPreview(
                  name: 'Sepia',
                  isActive: content.sepia,
                  onTap: () {
                    content.applyFilter(ImageFilter.sepia);
                    onUpdate();
                  },
                ),
                _FilterPreview(
                  name: 'Vivid',
                  isActive: _isVivid(),
                  onTap: () {
                    _applyVivid();
                    onUpdate();
                  },
                ),
              ],
            ),
          ),

          if (context
                  .findAncestorStateOfType<_AdvancedImagePanelState>()
                  ?._isExpanded ??
              false) ...[
            const SizedBox(height: 12),
            // Advanced Filter Controls
            Row(
              children: [
                Expanded(
                  child: _CompactSlider(
                    icon: Icons.vignette,
                    value: content.vignette,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (v) {
                      content.vignette = v;
                      onUpdate();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactSlider(
                    icon: Icons.grain,
                    value: content.noiseIntensity,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (v) {
                      content.noiseIntensity = v;
                      onUpdate();
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _isOriginal() {
    return !content.grayscale &&
        !content.sepia &&
        !content.vintage &&
        content.brightness == 0.0 &&
        content.contrast == 1.0 &&
        content.saturation == 1.0;
  }

  bool _isVivid() {
    return content.saturation > 1.2 && content.contrast > 1.0;
  }

  void _applyVintage() {
    content.resetFilters();
    content.sepia = true;
    content.adjustContrast(1.2);
    content.adjustBrightness(0.1);
    content.vignette = 0.3;
  }

  void _applyVivid() {
    content.resetFilters();
    content.adjustSaturation(1.4);
    content.adjustContrast(1.1);
  }
}

// Effects Page - Mask shapes and overlays
class _EffectsPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;

  const _EffectsPage({required this.content, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Mask Shapes
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ImageMaskShape.values.map((shape) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _MaskButton(
                    shape: shape,
                    isActive: content.maskShape == shape,
                    onTap: () {
                      content.maskShape = shape;
                      onUpdate();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          if (context
                  .findAncestorStateOfType<_AdvancedImagePanelState>()
                  ?._isExpanded ??
              false) ...[
            const SizedBox(height: 16),
            // Color Overlay
            Text(
              'Overlay',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ColorChip(
                    color: null,
                    isActive: content.overlayColor == null,
                    onTap: () {
                      content.overlayColor = null;
                      onUpdate();
                    },
                  ),
                  ...Colors.primaries.take(8).map((color) {
                    return _ColorChip(
                      color: color.withOpacity(0.3),
                      isActive:
                          content.overlayColor?.value ==
                          color.withOpacity(0.3).value,
                      onTap: () {
                        content.overlayColor = color.withOpacity(0.3);
                        content.overlayBlendMode = BlendMode.overlay;
                        onUpdate();
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Border Page - Compact border controls
class _BorderPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;

  const _BorderPage({required this.content, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CompactSlider(
                  icon: Icons.border_outer,
                  value: content.borderWidth,
                  min: 0.0,
                  max: 20.0,
                  onChanged: (v) {
                    content.borderWidth = v;
                    content.borderColor ??= Colors.white;
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactSlider(
                  icon: Icons.rounded_corner,
                  value: content.borderRadius,
                  min: 0.0,
                  max: 50.0,
                  onChanged: (v) {
                    content.borderRadius = v;
                    onUpdate();
                  },
                ),
              ),
            ],
          ),

          if (context
                  .findAncestorStateOfType<_AdvancedImagePanelState>()
                  ?._isExpanded ??
              false) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CompactSlider(
                    icon: Icons.blur_on,
                    value: content.shadowBlur,
                    min: 0.0,
                    max: 20.0,
                    onChanged: (v) {
                      content.shadowBlur = v;
                      content.shadowColor ??= Colors.black.withOpacity(0.3);
                      onUpdate();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Color selectors for border and shadow
                Column(
                  children: [
                    _MiniColorButton(
                      color: content.borderColor,
                      onTap: () => _showColorPicker(
                        context,
                        'Border',
                        content.borderColor,
                        (color) {
                          content.borderColor = color;
                          onUpdate();
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    _MiniColorButton(
                      color: content.shadowColor,
                      onTap: () => _showColorPicker(
                        context,
                        'Shadow',
                        content.shadowColor,
                        (color) {
                          content.shadowColor = color;
                          onUpdate();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    String title,
    Color? currentColor,
    Function(Color?) onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      builder: (context) => _QuickColorPicker(
        title: title,
        currentColor: currentColor,
        onChanged: onChanged,
      ),
    );
  }
}

// Transform Page
class _TransformPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;

  const _TransformPage({required this.content, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _CompactSlider(
            icon: Icons.rotate_right,
            value: content.rotationAngle,
            min: -180.0,
            max: 180.0,
            onChanged: (v) {
              content.rotationAngle = v;
              onUpdate();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TransformButton(
                  icon: Icons.flip,
                  label: 'Flip H',
                  isActive: content.flipHorizontal,
                  onTap: () {
                    content.flipHorizontal = !content.flipHorizontal;
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TransformButton(
                  icon: Icons.flip,
                  label: 'Flip V',
                  isActive: content.flipVertical,
                  onTap: () {
                    content.flipVertical = !content.flipVertical;
                    onUpdate();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Compact Widgets

class _CompactButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CompactButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactSlider extends StatelessWidget {
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final double? defaultValue;
  final ValueChanged<double> onChanged;

  const _CompactSlider({
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    this.defaultValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDefault =
        defaultValue != null && (value - defaultValue!).abs() < 0.01;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDefault
                    ? Colors.white.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                size: 14,
                color: isDefault ? Colors.white.withOpacity(0.6) : Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  activeTrackColor: Colors.blue,
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                  thumbColor: Colors.blue,
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                _formatValue(value, defaultValue),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatValue(double value, double? defaultValue) {
    if (defaultValue != null && (value - defaultValue).abs() < 0.01) {
      return '0';
    }
    if (value >= 10) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}

class _FilterPreview extends StatelessWidget {
  final String name;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPreview({
    required this.name,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.blue : Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MaskButton extends StatelessWidget {
  final ImageMaskShape shape;
  final bool isActive;
  final VoidCallback onTap;

  const _MaskButton({
    required this.shape,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          _getMaskIcon(shape),
          size: 18,
          color: isActive ? Colors.blue : Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  IconData _getMaskIcon(ImageMaskShape shape) {
    switch (shape) {
      case ImageMaskShape.none:
        return Icons.crop_free;
      case ImageMaskShape.circle:
        return Icons.circle_outlined;
      case ImageMaskShape.roundedRectangle:
        return Icons.rounded_corner;
      case ImageMaskShape.star:
        return Icons.star_outline;
      case ImageMaskShape.heart:
        return Icons.favorite_outline;
      case ImageMaskShape.hexagon:
        return Icons.hexagon_outlined;
    }
  }
}

class _ColorChip extends StatelessWidget {
  final Color? color;
  final bool isActive;
  final VoidCallback onTap;

  const _ColorChip({
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.white.withOpacity(0.3),
            width: isActive ? 2 : 1,
          ),
        ),
        child: color == null
            ? Icon(Icons.close, size: 14, color: Colors.white.withOpacity(0.6))
            : null,
      ),
    );
  }
}

class _TransformButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TransformButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.blue : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.blue : Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniColorButton extends StatelessWidget {
  final Color? color;
  final VoidCallback onTap;

  const _MiniColorButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: color == null
            ? Icon(
                Icons.colorize,
                size: 12,
                color: Colors.white.withOpacity(0.6),
              )
            : null,
      ),
    );
  }
}

// Quick Color Picker Modal
class _QuickColorPicker extends StatelessWidget {
  final String title;
  final Color? currentColor;
  final Function(Color?) onChanged;

  const _QuickColorPicker({
    required this.title,
    required this.currentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$title Color',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Color Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _getColorPalette().length,
              itemBuilder: (context, index) {
                final color = _getColorPalette()[index];
                final isSelected = color?.value == currentColor?.value;

                return GestureDetector(
                  onTap: () {
                    onChanged(color);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: color ?? Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : Colors.white.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: color == null
                        ? Icon(
                            Icons.not_interested,
                            color: Colors.white.withOpacity(0.6),
                            size: 16,
                          )
                        : isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Color?> _getColorPalette() {
    return [
      null, // No color option
      Colors.white,
      Colors.black,
      Colors.grey,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
      // Additional shades
      Colors.red.shade300,
      Colors.pink.shade300,
      Colors.purple.shade300,
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.red.shade700,
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.purple.shade700,
    ];
  }
}

// Enum definitions (these would typically be in separate files)

// Placeholder classes for the image content system
// These would be replaced with your actual image content classes

/*
// Advanced Image Customization Panel
class AdvancedImagePanel extends StatefulWidget {
  final StackImageItem imageItem;
  final VoidCallback onUpdate;

  const AdvancedImagePanel({
    super.key,
    required this.imageItem,
    required this.onUpdate,
  });

  @override
  State<AdvancedImagePanel> createState() => _AdvancedImagePanelState();
}

class _AdvancedImagePanelState extends State<AdvancedImagePanel>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ImageItemContent get content => widget.imageItem.content!;

  void _updateImage() {
    widget.onUpdate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.photo_filter,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Advanced Image Editor',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                _ResetButton(
                  onReset: () {
                    content.resetFilters();
                    _updateImage();
                  },
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Adjust', icon: Icon(Icons.tune, size: 18)),
                Tab(
                  text: 'Filters',
                  icon: Icon(Icons.filter_vintage, size: 18),
                ),
                Tab(text: 'Border', icon: Icon(Icons.border_outer, size: 18)),
                Tab(text: 'Effects', icon: Icon(Icons.auto_fix_high, size: 18)),
                Tab(text: 'Transform', icon: Icon(Icons.transform, size: 18)),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AdjustmentTab(content: content, onUpdate: _updateImage),
                _FiltersTab(content: content, onUpdate: _updateImage),
                _BorderTab(content: content, onUpdate: _updateImage),
                _EffectsTab(content: content, onUpdate: _updateImage),
                _TransformTab(content: content, onUpdate: _updateImage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Adjustment Tab - Color corrections and basic adjustments
class _AdjustmentTab extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;

  const _AdjustmentTab({required this.content, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SliderControl(
            label: 'Brightness',
            value: content.brightness,
            min: -1.0,
            max: 1.0,
            divisions: 200,
            icon: Icons.brightness_6,
            onChanged: (value) {
              content.adjustBrightness(value);
              onUpdate();
            },
          ),
          const SizedBox(height: 16),
          _SliderControl(
            label: 'Contrast',
            value: content.contrast,
            min: 0.0,
            max: 2.0,
            divisions: 200,
            icon: Icons.contrast,
            onChanged: (value) {
              content.adjustContrast(value);
              onUpdate();
            },
          ),
          const SizedBox(height: 16),
          _SliderControl(
            label: 'Saturation',
            value: content.saturation,
            min: 0.0,
            max: 2.0,
            divisions: 200,
            icon: Icons.color_lens,
            onChanged: (value) {
              content.adjustSaturation(value);
              onUpdate();
            },
          ),
          const SizedBox(height: 16),
          _SliderControl(
            label: 'Hue',
            value: content.hue,
            min: 0.0,
            max: 360.0,
            divisions: 360,
            icon: Icons.palette,
            onChanged: (value) {
              content.adjustHue(value);
              onUpdate();
            },
          ),
          const SizedBox(height: 16),
          _SliderControl(
            label: 'Opacity',
            value: content.opacity,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            icon: Icons.opacity,
            onChanged: (value) {
              content.adjustOpacity(value);
              onUpdate();
            },
          ),
        ],
      ),
    );
  }
}

// Filters Tab - Preset filters and effects
class _FiltersTab extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;

  const _FiltersTab({required this.content, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filter Presets
          Row(
            children: [
              Expanded(
                child: _FilterButton(
                  label: 'Grayscale',
                  isActive: content.grayscale,
                  icon: Icons.filter_b_and_w,
                  onTap: () {
                    content.applyFilter(ImageFilter.grayscale);
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterButton(
                  label: 'Sepia',
                  isActive: content.sepia,
                  icon: Icons.filter_vintage,
                  onTap: () {
                    content.applyFilter(ImageFilter.sepia);
                    onUpdate();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FilterButton(
                  label: 'Vintage',
                  isActive: content.vintage,
                  icon: Icons.camera_alt,
                  onTap: () {
                    content.applyFilter(ImageFilter.vintage);
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterButton(
                  label: 'Emboss',
                  isActive: content.emboss,
                  icon: Icons.texture,
                  onTap: () {
                    content.applyFilter(ImageFilter.emboss);
                    onUpdate();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Advanced Filter Controls
          _SliderControl(
            label: 'Vignette',
            value: content.vignette,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            icon: Icons.vignette,
            onChanged: (value) {
              content.vignette = value;
              onUpdate();
            },
          ),
          const SizedBox(height: 16),
          _SliderControl(
            label: 'Noise',
            value: content.noiseIntensity,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            icon: Icons.grain,
            onChanged: (value) {
              content.noiseIntensity = value;
              onUpdate();
            },
          ),
          const SizedBox(height: 16),
          _SliderControl(
            label: 'Sharpen',
            value: content.sharpen,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            icon: Icons.center_focus_strong,
            onChanged: (value) {
              content.sharpen = value;
              onUpdate();
            },
          ),
        ],
      ),
    );
  }
}

// Border Tab - Border and frame customization
class _BorderTab extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;

  const _BorderTab({required this.content, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SliderControl(
            label: 'Border Width',
            value: content.borderWidth,
            min: 0.0,
            max: 20.0,
            divisions: 200,
            icon: Icons.border_outer,
            onChanged: (value) {
              content.borderWidth = value;
              onUpdate();
            },
          ),
          const SizedBox(height: 16),
          _SliderControl(
            label: 'Border Radius',
            value: content.borderRadius,
            min: 0.0,
            max: 50.0,
            divisions: 100,
            icon: Icons.rounded_corner,
            onChanged: (value) {
              content.borderRadius = value;
              onUpdate();
            },
          ),
          const SizedBox(height: 24),

          // Border Color Picker
          _ColorPickerSection(
            title: 'Border Color',
            currentColor: content.borderColor,
            onColorChanged: (color) {
              content.borderColor = color;
              onUpdate();
            },
          ),

          const SizedBox(height: 24),

          // Shadow Controls
          Text(
            'Shadow',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _SliderControl(
            label: 'Shadow Blur',
            value: content.shadowBlur,
            min: 0.0,
            max: 30.0,
            divisions: 150,
            icon: Icons.blur_on,
            onChanged: (value) {
              content.shadowBlur = value;
              onUpdate();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SliderControl(
                  label: 'Shadow X',
                  value: content.shadowOffset.dx,
                  min: -20.0,
                  max: 20.0,
                  divisions: 80,
                  icon: Icons.arrow_right_alt,
                  onChanged: (value) {
                    content.shadowOffset = Offset(
                      value,
                      content.shadowOffset.dy,
                    );
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SliderControl(
                  label: 'Shadow Y',
                  value: content.shadowOffset.dy,
                  min: -20.0,
                  max: 20.0,
                  divisions: 80,
                  icon: Icons.arrow_downward,
                  onChanged: (value) {
                    content.shadowOffset = Offset(
                      content.shadowOffset.dx,
                      value,
                    );
                    onUpdate();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ColorPickerSection(
            title: 'Shadow Color',
            currentColor: content.shadowColor,
            onColorChanged: (color) {
              content.shadowColor = color;
              onUpdate();
            },
          ),
        ],
      ),
    );
  }
}

// Effects Tab - Overlay effects and masks
class _EffectsTab extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;

  const _EffectsTab({required this.content, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Mask Shapes
          Text(
            'Mask Shape',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ImageMaskShape.values.map((shape) {
              return _MaskShapeButton(
                shape: shape,
                isActive: content.maskShape == shape,
                onTap: () {
                  content.maskShape = shape;
                  onUpdate();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Overlay Color
          _ColorPickerSection(
            title: 'Overlay Color',
            currentColor: content.overlayColor,
            onColorChanged: (color) {
              content.overlayColor = color;
              onUpdate();
            },
          ),
          const SizedBox(height: 16),

          // Blend Mode Selector
          if (content.overlayColor != null) ...[
            Text(
              'Blend Mode',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BlendMode>(
              value: content.overlayBlendMode ?? BlendMode.overlay,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              items:
                  [
                    BlendMode.overlay,
                    BlendMode.multiply,
                    BlendMode.screen,
                    BlendMode.softLight,
                    BlendMode.hardLight,
                    BlendMode.colorDodge,
                    BlendMode.colorBurn,
                  ].map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(_getBlendModeName(mode)),
                    );
                  }).toList(),
              onChanged: (mode) {
                content.overlayBlendMode = mode;
                onUpdate();
              },
            ),
          ],
        ],
      ),
    );
  }

  String _getBlendModeName(BlendMode mode) {
    return mode
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
  }
}

// Transform Tab - Rotation, flip, and transformations
class _TransformTab extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;

  const _TransformTab({required this.content, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SliderControl(
            label: 'Rotation',
            value: content.rotationAngle,
            min: -180.0,
            max: 180.0,
            divisions: 360,
            icon: Icons.rotate_right,
            onChanged: (value) {
              content.rotationAngle = value;
              onUpdate();
            },
          ),
          const SizedBox(height: 24),

          // Flip Controls
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Flip Horizontal',
                  icon: Icons.flip,
                  isActive: content.flipHorizontal,
                  onTap: () {
                    content.flipHorizontal = !content.flipHorizontal;
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Flip Vertical',
                  icon: Icons.flip,
                  isActive: content.flipVertical,
                  onTap: () {
                    content.flipVertical = !content.flipVertical;
                    onUpdate();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Rotation Buttons
          Text(
            'Quick Rotation',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickRotationButton(
                  label: '90°',
                  onTap: () {
                    content.rotationAngle = (content.rotationAngle + 90) % 360;
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickRotationButton(
                  label: '180°',
                  onTap: () {
                    content.rotationAngle = (content.rotationAngle + 180) % 360;
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickRotationButton(
                  label: '270°',
                  onTap: () {
                    content.rotationAngle = (content.rotationAngle + 270) % 360;
                    onUpdate();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickRotationButton(
                  label: 'Reset',
                  onTap: () {
                    content.rotationAngle = 0;
                    onUpdate();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Widgets

class _SliderControl extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final IconData icon;
  final ValueChanged<double> onChanged;

  const _SliderControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).primaryColor,
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withOpacity(0.1),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isActive,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[50],
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaskShapeButton extends StatelessWidget {
  final ImageMaskShape shape;
  final bool isActive;
  final VoidCallback onTap;

  const _MaskShapeButton({
    required this.shape,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[50],
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            _getMaskShapeIcon(shape),
            color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
            size: 24,
          ),
        ),
      ),
    );
  }

  IconData _getMaskShapeIcon(ImageMaskShape shape) {
    switch (shape) {
      case ImageMaskShape.none:
        return Icons.crop_free;
      case ImageMaskShape.circle:
        return Icons.circle;
      case ImageMaskShape.roundedRectangle:
        return Icons.rounded_corner;
      case ImageMaskShape.star:
        return Icons.star;
      case ImageMaskShape.heart:
        return Icons.favorite;
      case ImageMaskShape.hexagon:
        return Icons.hexagon;
    }
  }
}

class _ColorPickerSection extends StatelessWidget {
  final String title;
  final Color? currentColor;
  final ValueChanged<Color?> onColorChanged;

  const _ColorPickerSection({
    required this.title,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () => onColorChanged(null),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: currentColor == null
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : const Icon(Icons.clear, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      Colors.black,
                      Colors.white,
                      Colors.grey,
                      Colors.red,
                      Colors.pink,
                      Colors.purple,
                      Colors.blue,
                      Colors.cyan,
                      Colors.teal,
                      Colors.green,
                      Colors.yellow,
                      Colors.orange,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () => onColorChanged(color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: currentColor == color
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                              width: currentColor == color ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[50],
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickRotationButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickRotationButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  final VoidCallback onReset;

  const _ResetButton({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReset,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              'Reset',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
class _PresetSelector extends StatelessWidget {
  final StackImageItem imageItem;
  final VoidCallback onUpdate;

  const _PresetSelector({required this.imageItem, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ImagePreset.values.map((preset) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    _applyPreset(preset);
                    onUpdate();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      _getPresetName(preset),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _applyPreset(ImagePreset preset) {
    final content = imageItem.content!;

    // Reset first
    content.resetFilters();

    switch (preset) {
      case ImagePreset.vintage:
        content.sepia = true;
        content.contrast = 1.2;
        content.brightness = 0.1;
        content.vignette = 0.3;
        content.vignetteColor = Colors.brown.shade800;
        break;

      case ImagePreset.blackAndWhite:
        content.grayscale = true;
        content.contrast = 1.3;
        content.brightness = 0.05;
        break;

      case ImagePreset.vibrant:
        content.saturation = 1.4;
        content.contrast = 1.1;
        content.brightness = 0.05;
        break;

      case ImagePreset.soft:
        content.contrast = 0.9;
        content.brightness = 0.1;
        content.saturation = 0.9;
        break;

      case ImagePreset.dramatic:
        content.contrast = 1.5;
        content.brightness = -0.1;
        content.vignette = 0.4;
        content.vignetteColor = Colors.black;
        break;
    }
  }

  String _getPresetName(ImagePreset preset) {
    switch (preset) {
      case ImagePreset.vintage:
        return 'Vintage';
      case ImagePreset.blackAndWhite:
        return 'B&W';
      case ImagePreset.vibrant:
        return 'Vibrant';
      case ImagePreset.soft:
        return 'Soft';
      case ImagePreset.dramatic:
        return 'Dramatic';
    }
  }
}

extension EditorControllerImageExtension on EditorController {
  // Method to add a new image with advanced features
  void addAdvancedImage(String assetName, {Size? size, Offset? offset}) {
    final imageContent = ImageItemContent(
      assetName: assetName,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      // Initialize with default advanced properties
      brightness: 0.0,
      contrast: 1.0,
      saturation: 1.0,
      hue: 0.0,
      opacity: 1.0,
      borderRadius: 0.0,
      borderWidth: 0.0,
      shadowBlur: 0.0,
      shadowOffset: const Offset(0, 0),
      rotationAngle: 0.0,
      flipHorizontal: false,
      flipVertical: false,
      grayscale: false,
      sepia: false,
      vintage: false,
      vignette: 0.0,
      maskShape: ImageMaskShape.none,
      noiseIntensity: 0.0,
      sharpen: 0.0,
      emboss: false,
    );

    final imageItem = StackImageItem(
      content: imageContent,
      size: size ?? const Size(200, 200),
      offset: offset ?? const Offset(100, 100),
      status: StackItemStatus.idle,
    );

    boardController.addItem(imageItem);
    activeItem.value = imageItem;
  }

  // Method to duplicate an image with all its advanced properties
  void duplicateAdvancedImage(StackImageItem original) {
    final newContent = ImageItemContent(
      assetName: original.content?.assetName,
      url: original.content?.url,
      fit: original.content?.fit ?? BoxFit.cover,
      filterQuality: original.content?.filterQuality ?? FilterQuality.high,
      // Copy all advanced properties
      brightness: original.content?.brightness ?? 0.0,
      contrast: original.content?.contrast ?? 1.0,
      saturation: original.content?.saturation ?? 1.0,
      hue: original.content?.hue ?? 0.0,
      opacity: original.content?.opacity ?? 1.0,
      borderRadius: original.content?.borderRadius ?? 0.0,
      borderWidth: original.content?.borderWidth ?? 0.0,
      borderColor: original.content?.borderColor,
      shadowBlur: original.content?.shadowBlur ?? 0.0,
      shadowOffset: original.content?.shadowOffset ?? const Offset(0, 0),
      shadowColor: original.content?.shadowColor,
      rotationAngle: original.content?.rotationAngle ?? 0.0,
      flipHorizontal: original.content?.flipHorizontal ?? false,
      flipVertical: original.content?.flipVertical ?? false,
      grayscale: original.content?.grayscale ?? false,
      sepia: original.content?.sepia ?? false,
      vintage: original.content?.vintage ?? false,
      vignette: original.content?.vignette ?? 0.0,
      vignetteColor: original.content?.vignetteColor,
      overlayColor: original.content?.overlayColor,
      overlayBlendMode: original.content?.overlayBlendMode,
      maskShape: original.content?.maskShape ?? ImageMaskShape.none,
      noiseIntensity: original.content?.noiseIntensity ?? 0.0,
      sharpen: original.content?.sharpen ?? 0.0,
      emboss: original.content?.emboss ?? false,
    );

    final duplicateItem = StackImageItem(
      content: newContent,
      size: original.size,
      offset: Offset(original.offset.dx + 20, original.offset.dy + 20),
      status: StackItemStatus.idle,
    );

    boardController.addItem(duplicateItem);
    activeItem.value = duplicateItem;
  }

  // Method to apply preset image styles
  void applyImagePreset(StackImageItem imageItem, ImagePreset preset) {
    if (imageItem.content == null) return;

    switch (preset) {
      case ImagePreset.vintage:
        imageItem.content!.sepia = true;
        imageItem.content!.contrast = 1.2;
        imageItem.content!.brightness = 0.1;
        imageItem.content!.vignette = 0.3;
        imageItem.content!.vignetteColor = Colors.brown.shade800;
        break;

      case ImagePreset.blackAndWhite:
        imageItem.content!.grayscale = true;
        imageItem.content!.contrast = 1.3;
        imageItem.content!.brightness = 0.05;
        break;

      case ImagePreset.vibrant:
        imageItem.content!.saturation = 1.4;
        imageItem.content!.contrast = 1.1;
        imageItem.content!.brightness = 0.05;
        break;

      case ImagePreset.soft:
        imageItem.content!.contrast = 0.9;
        imageItem.content!.brightness = 0.1;
        imageItem.content!.saturation = 0.9;
        break;

      case ImagePreset.dramatic:
        imageItem.content!.contrast = 1.5;
        imageItem.content!.brightness = -0.1;
        imageItem.content!.vignette = 0.4;
        imageItem.content!.vignetteColor = Colors.black;
        break;
    }

    update();
  }
}

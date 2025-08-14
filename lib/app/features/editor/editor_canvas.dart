import 'dart:io';
import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/text_editor.dart';
import 'package:cardmaker/app/features/editor/video_editor/view.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_case.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
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

class EditorPage extends GetView<EditorController> {
  bool isExporting = false;

  EditorPage({super.key});

  final ScreenshotController screenshotController = ScreenshotController();
  final RxBool allowTouch = false.obs;
  final Rx<StackImageItem?> activePhotoItem = Rx<StackImageItem?>(null);
  final Rx<PanelType> activePanel = PanelType.none.obs;
  RxBool isShowEditIcon = false.obs;

  StackItem deserializeItem(Map<String, dynamic> itemJson) {
    final type = itemJson['type'];
    if (type == 'StackTextItem') {
      return StackTextItem.fromJson(itemJson);
    } else if (type == 'StackImageItem') {
      return StackImageItem.fromJson(itemJson);
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
    return GetBuilder<EditorController>(
      id: 'canvas_stack',
      builder: (controller) {
        print("Built");
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background image
            // IgnorePointer(
            //   ignoring: true,
            //   child: SizedBox(
            //     width: scaledCanvasWidth.value,
            //     height: scaledCanvasHeight.value,
            //     child: controller.selectedBackground.value.isNotEmpty
            //         ? ColorFiltered(
            //             colorFilter: ColorFilter.matrix(
            //               _hueMatrix(controller.backgroundHue.value),
            //             ),
            //             child: Image.asset(
            //               controller.selectedBackground.value,
            //               width: scaledCanvasWidth.value,
            //               height: scaledCanvasHeight.value,
            //               fit: BoxFit.contain,
            //             ),
            //           )
            //         : Container(color: Colors.grey[200]),
            //   ),
            // ),

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
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      _hueMatrix(controller.backgroundHue.value),
                    ),
                    child: Image.asset(
                      controller.initialTemplate?.backgroundImage ?? "",
                      fit: BoxFit.contain,
                    ),
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
                        StackImageItem? tappedItem = controller
                            .profileImageItems
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
                          allowTouch.value = true;
                          controller.update(['stack_board']);
                        } else {
                          if (allowTouch.value != false) {
                            //to overcome unncessary rebuilds
                            allowTouch.value = false;
                            activePhotoItem.value = null;
                          }
                          controller.activeItem.value = null;
                          activePanel.value = PanelType.none;
                          controller.update(['stack_board']);
                        }
                      }
                    : null,
                child: GetBuilder<EditorController>(
                  id: 'stack_board',
                  builder: (controller) => IgnorePointer(
                    ignoring: allowTouch.value,
                    child: StackBoard(
                      key: stackBoardKey,
                      controller: controller.boardController,
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
                      onStatusChanged: (item, status) {
                        if (status == StackItemStatus.selected) {
                          controller.activeItem.value = controller
                              .boardController
                              .getById(item.id);
                          if (item is StackTextItem) {
                            activePanel.value = PanelType.text;
                          } else if (item is StackImageItem) {
                            activePanel.value = PanelType.advancedImage;
                          } else {
                            activePanel.value = PanelType.none;
                          }
                          controller.draggedItem.value = null;
                        } else if (status == StackItemStatus.moving) {
                          activePanel.value = PanelType.none;
                          controller.draggedItem.value = item;
                        } else if (status == StackItemStatus.idle) {
                          activePanel.value = PanelType.none;
                          if (controller.draggedItem.value?.id == item.id) {
                            controller.draggedItem.value = null;
                          }
                        }
                        controller.update(['canvas_stack', 'bottom_sheet']);
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
        );
      },
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
      return GetBuilder<EditorController>(
        id: 'bottom_sheet',
        builder: (controller) {
          final item = controller.activeItem.value;

          final panels = <Widget>[
            _StickerPanel(controller: controller), // PanelType.stickers
            _HueAdjustmentPanel(controller: controller), // PanelType.color
            (item is StackTextItem)
                ? _TextEditorPanel(
                    key: ValueKey(item.id),
                    controller: controller,
                    textItem: item,
                  )
                : const SizedBox.shrink(), // PanelType.text
            _ShapePanel(controller: controller), // PanelType.shapes
            (item is StackImageItem)
                ? AdvancedImagePanel(
                    key: ValueKey(item.id),
                    imageItem: item,
                    onUpdate: () {
                      // Enhanced update callback for real-time changes
                      // controller.update([
                      //   'canvas_stack',
                      //   'stack_board',
                      //   'advanced_image_panel_${item.id}',
                      // ]);
                    },
                  )
                : const SizedBox.shrink(), // PanelType.advancedImage
          ];

          return IndexedStack(
            index: activePanel.value.index - 1,
            alignment: Alignment.bottomCenter,
            children: panels,
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          GetBuilder<EditorController>(
            id: 'export_button',
            builder: (controller) => _ModernExportButton(
              onExportPDF: exportAsPDF,
              onExportImage: exportAsImage,
              onSave: () => controller.exportDesign(),
              isExporting: isExporting,
            ),
          ),
          SizedBox(width: 16),
        ],
      ),

      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    elevation: 10,
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                            controller.update(['bottom_sheet']);
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
                            controller.update(['bottom_sheet']);
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
                                  controller.activeItem.value
                                      is! StackTextItem) {
                                controller.addText("Tap to edit text");
                              }
                              activePanel.value = PanelType.text;
                            }
                            controller.update(['bottom_sheet']);
                          },
                        ),
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
                              if (controller.activeItem.value != null &&
                                  controller.activeItem.value
                                      is StackImageItem) {
                                activePanel.value = PanelType.advancedImage;
                              } else {
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
                            controller.update(['bottom_sheet']);
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
                            controller.update(['bottom_sheet']);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Obx(
            () => activePanel.value == PanelType.none
                ? SizedBox()
                : buildPanelContent(),
          ),
        ],
      ),
    );
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
                // unselectedLabelColor: Colors.grey[600],
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
  final Size stackBoardSize;
  final bool showGrid;
  final double gridSize;
  final Color guideColor;
  final Color criticalGuideColor;
  final Color centerGuideColor;

  AlignmentGuidePainter({
    required this.draggedItem,
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
  }

  @override
  bool shouldRepaint(covariant AlignmentGuidePainter oldDelegate) {
    return oldDelegate.draggedItem?.id != draggedItem?.id ||
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
            child: Icon(Icons.edit),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

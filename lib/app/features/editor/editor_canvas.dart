import 'dart:io';
import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/text_editor.dart';
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
      builder: (controller) => Stack(
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
                        allowTouch.value = true;
                        controller.update(['stack_board']);
                      } else {
                        activePhotoItem.value = null;
                        allowTouch.value = false;
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
                        controller.activeItem.value = controller.boardController
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
                      controller.update([
                        'canvas_stack',
                        'stack_board',
                        'advanced_image_panel_${item.id}',
                      ]);
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
/*
// Professional Compact Image Editor Panel with Real-time Updates
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
  bool _isExpanded = false;
  String _updateId = 'advanced_image_panel';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _updateId = 'advanced_image_panel_${widget.imageItem.id}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ImageItemContent get content => widget.imageItem.content!;

  void _updateImage() {
    // Trigger both local update and parent update for real-time changes
    setState(() {});
    widget.onUpdate();

    // Force update in the controller if available
    try {
      final controller = Get.find<EditorController>();
      controller.update(['canvas_stack', 'stack_board']);
    } catch (e) {
      // Controller might not be available in all contexts
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: _updateId,
      builder: (controller) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: _isExpanded ? 320 : 160,
        color: Get.theme.colorScheme.surfaceContainerHigh,
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

            // Tab Bar
            SizedBox(
              height: 50,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.blue,
                indicatorWeight: 2,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.tune, size: 18), text: 'Adjust'),
                  Tab(
                    icon: Icon(Icons.filter_vintage, size: 18),
                    text: 'Filters',
                  ),
                  Tab(
                    icon: Icon(Icons.auto_fix_high, size: 18),
                    text: 'Effects',
                  ),
                  Tab(icon: Icon(Icons.border_outer, size: 18), text: 'Border'),
                  Tab(icon: Icon(Icons.transform, size: 18), text: 'Transform'),
                ],
              ),
            ),

            // Content Area with TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AdjustPage(
                    content: content,
                    onUpdate: _updateImage,
                    isExpanded: _isExpanded,
                    updateId: _updateId,
                  ),
                  _FiltersPage(
                    content: content,
                    onUpdate: _updateImage,
                    isExpanded: _isExpanded,
                    updateId: _updateId,
                  ),
                  _EffectsPage(
                    content: content,
                    onUpdate: _updateImage,
                    isExpanded: _isExpanded,
                    updateId: _updateId,
                  ),
                  _BorderPage(
                    content: content,
                    onUpdate: _updateImage,
                    isExpanded: _isExpanded,
                    updateId: _updateId,
                  ),
                  _TransformPage(
                    content: content,
                    onUpdate: _updateImage,
                    isExpanded: _isExpanded,
                    updateId: _updateId,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

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
  bool _isExpanded = false;
  String _updateId = 'advanced_image_panel';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _updateId = 'advanced_image_panel_${widget.imageItem.id}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ImageItemContent get content => widget.imageItem.content!;

  void _updateImage() {
    // Trigger both local update and parent update for real-time changes
    setState(() {});
    widget.onUpdate();

    // Force update in the controller if available
    try {
      final controller = Get.find<EditorController>();
      controller.update(['canvas_stack', 'stack_board']);
    } catch (e) {
      // Controller might not be available in all contexts
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: _updateId,
      builder: (controller) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: _isExpanded ? 320 : 160,
        color: Get.theme.colorScheme.surfaceContainerHigh,
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

            // Tab Bar
            SizedBox(
              height: 50,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.blue,
                indicatorWeight: 2,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.tune, size: 18), text: 'Adjust'),
                  Tab(
                    icon: Icon(Icons.filter_vintage, size: 18),
                    text: 'Filters',
                  ),
                  Tab(
                    icon: Icon(Icons.auto_fix_high, size: 18),
                    text: 'Effects',
                  ),
                  Tab(icon: Icon(Icons.border_outer, size: 18), text: 'Border'),
                  Tab(icon: Icon(Icons.transform, size: 18), text: 'Transform'),
                ],
              ),
            ),

            // Content Area with TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AdjustPage(
                    content: content,
                    onUpdate: _updateImage,
                    isExpanded: _isExpanded,
                    updateId: _updateId,
                  ),
                  _FiltersPage(
                    content: content,
                    onUpdate: _updateImage,
                    isExpanded: _isExpanded,
                    updateId: _updateId,
                  ),
                  _EffectsPage(
                    content: content,
                    onUpdate: _updateImage,
                    isExpanded: _isExpanded,
                    updateId: _updateId,
                  ),
                  _BorderPage(
                    content: content,
                    onUpdate: _updateImage,
                    isExpanded: _isExpanded,
                    updateId: _updateId,
                  ),
                  _TransformPage(
                    content: content,
                    onUpdate: _updateImage,
                    isExpanded: _isExpanded,
                    updateId: _updateId,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final String updateId;

  const _AdjustPage({
    required this.content,
    required this.onUpdate,
    required this.isExpanded,
    required this.updateId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: updateId,
      builder: (controller) {
        String selectedAdjustment = controller.selectedAdjustment;

        return Container(
          color: Colors.black,
          child: Column(
            children: [
              // Main slider area
              Container(
                height: 80,
                width: double.infinity,
                color: Colors.black,
                child: Center(
                  child: _ProfessionalSlider(
                    selectedAdjustment: selectedAdjustment,
                    content: content,
                    onUpdate: onUpdate,
                    updateId: updateId,
                  ),
                ),
              ),

              // Adjustment tools
              Container(
                height: 88,
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _AdjustmentToolsRow(
                  selectedAdjustment: selectedAdjustment,
                  content: content,
                  isExpanded: isExpanded,
                  updateId: updateId,
                  onSelectionChanged: (String adjustment) {
                    controller.setSelectedAdjustment(adjustment);
                    controller.update([updateId]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdjustmentToolsRow extends StatelessWidget {
  final String selectedAdjustment;
  final ImageItemContent content;
  final bool isExpanded;
  final String updateId;
  final Function(String) onSelectionChanged;

  const _AdjustmentToolsRow({
    required this.selectedAdjustment,
    required this.content,
    required this.isExpanded,
    required this.updateId,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final adjustments = _ImageAdjustmentConfig.getAdjustments(
      content,
      isExpanded,
    );

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: adjustments.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final tool = adjustments[index];
        final isSelected = selectedAdjustment == tool.key;

        return GestureDetector(
          onTap: () => onSelectionChanged(tool.key),
          child: _AdjustmentToolButton(tool: tool, isSelected: isSelected),
        );
      },
    );
  }
}

class _AdjustmentToolButton extends StatelessWidget {
  final _AdjustmentTool tool;
  final bool isSelected;

  const _AdjustmentToolButton({required this.tool, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFFA500)
                  : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              tool.icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tool.label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFA500) : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfessionalSlider extends StatelessWidget {
  final String selectedAdjustment;
  final ImageItemContent content;
  final VoidCallback onUpdate;
  final String updateId;

  const _ProfessionalSlider({
    required this.selectedAdjustment,
    required this.content,
    required this.onUpdate,
    required this.updateId,
  });

  @override
  Widget build(BuildContext context) {
    final config = _ImageAdjustmentConfig.getConfig(selectedAdjustment);
    final currentValue = config.getValue(content);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Value display
          Text(
            config.formatValue(currentValue),
            style: const TextStyle(
              color: Color(0xFFFFA500),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Professional slider
          SizedBox(
            height: 24,
            child: Stack(
              children: [
                // Background track
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Center indicator for bidirectional sliders
                if (config.isBidirectional)
                  Positioned(
                    top: 8,
                    left: (MediaQuery.of(context).size.width - 48) / 2 - 1,
                    child: Container(
                      width: 2,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF666666),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),

                // Active track
                Positioned(
                  top: 10,
                  left: config.getTrackLeft(
                    currentValue,
                    MediaQuery.of(context).size.width - 48,
                  ),
                  width: config.getTrackWidth(
                    currentValue,
                    MediaQuery.of(context).size.width - 48,
                  ),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA500),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 0,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: const Color(0xFFFFA500),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                      elevation: 2,
                    ),
                    overlayColor: const Color(0xFFFFA500).withOpacity(0.1),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 18,
                    ),
                  ),
                  child: Slider(
                    value: currentValue.clamp(config.min, config.max),
                    min: config.min,
                    max: config.max,
                    onChanged: (value) {
                      config.updateValue(content, value);
                      onUpdate();
                      Get.find<EditorController>().update([updateId]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdjustmentTool {
  final String key;
  final IconData icon;
  final String label;
  final double value;

  const _AdjustmentTool({
    required this.key,
    required this.icon,
    required this.label,
    required this.value,
  });
}

// Configuration class for different adjustment types
class _ImageAdjustmentConfig {
  final String key;
  final double min;
  final double max;
  final double defaultValue;
  final bool isBidirectional;
  final String suffix;
  final double Function(ImageItemContent) getValue;
  final void Function(ImageItemContent, double) updateValue;

  const _ImageAdjustmentConfig({
    required this.key,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.isBidirectional,
    required this.suffix,
    required this.getValue,
    required this.updateValue,
  });

  String formatValue(double value) {
    return '${value.round()}$suffix';
  }

  double getTrackLeft(double value, double trackWidth) {
    if (!isBidirectional) return 0.0;

    final center = trackWidth / 2;
    if (value >= defaultValue) {
      return center;
    } else {
      final range = max - min;
      final relativeValue = (value - defaultValue) / range;
      return center + (relativeValue * trackWidth);
    }
  }

  double getTrackWidth(double value, double trackWidth) {
    if (!isBidirectional) {
      // For unidirectional sliders (0 to max)
      return (value / max) * trackWidth;
    }

    // For bidirectional sliders (-x to +x)
    final range = max - min;
    final relativeValue = (value - defaultValue).abs() / range;
    return relativeValue * trackWidth;
  }

  static _ImageAdjustmentConfig getConfig(String adjustment) {
    return _configs[adjustment] ?? _configs['brightness']!;
  }

  static List<_AdjustmentTool> getAdjustments(
    ImageItemContent content,
    bool isExpanded,
  ) {
    final basic = [
      // _AdjustmentTool(
      //   key: 'exposure',
      //   icon: Icons.exposure,
      //   label: 'Exposure',
      //   value: _configs['exposure']!.getValue(content),
      // ),
      _AdjustmentTool(
        key: 'brightness',
        icon: Icons.brightness_6,
        label: 'Brightness',
        value: _configs['brightness']!.getValue(content),
      ),
      _AdjustmentTool(
        key: 'contrast',
        icon: Icons.contrast,
        label: 'Contrast',
        value: _configs['contrast']!.getValue(content),
      ),
      _AdjustmentTool(
        key: 'saturation',
        icon: Icons.water_drop,
        label: 'Saturation',
        value: _configs['saturation']!.getValue(content),
      ),
    ];

    if (isExpanded) {
      basic.addAll([
        _AdjustmentTool(
          key: 'hue',
          icon: Icons.palette,
          label: 'Hue',
          value: _configs['hue']!.getValue(content),
        ),
        _AdjustmentTool(
          key: 'opacity',
          icon: Icons.opacity,
          label: 'Opacity',
          value: _configs['opacity']!.getValue(content),
        ),
      ]);
    }

    return basic;
  }

  static final Map<String, _ImageAdjustmentConfig> _configs = {
    // 'exposure': _ImageAdjustmentConfig(
    //   key: 'exposure',
    //   min: -100.0,
    //   max: 100.0,
    //   defaultValue: 0.0,
    //   isBidirectional: true,
    //   suffix: '',
    //   getValue: (content) => content.brightness * 100,
    //   updateValue: (content, value) {
    //     // Exposure affects overall luminance
    //     final exposureValue = value / 100;
    //     content.adjustBrightness(exposureValue * 0.8); // Softer exposure effect
    //   },
    // ),
    'brightness': _ImageAdjustmentConfig(
      key: 'brightness',
      min: -100.0,
      max: 100.0,
      defaultValue: 0.0,
      isBidirectional: true,
      suffix: '',
      getValue: (content) => content.brightness * 100,
      updateValue: (content, value) => content.adjustBrightness(value / 100),
    ),
    'contrast': _ImageAdjustmentConfig(
      key: 'contrast',
      min: -100.0,
      max: 100.0,
      defaultValue: 0.0,
      isBidirectional: true,
      suffix: '',
      getValue: (content) => (content.contrast - 1.0) * 100,
      updateValue: (content, value) =>
          content.adjustContrast((value / 100) + 1.0),
    ),
    'saturation': _ImageAdjustmentConfig(
      key: 'saturation',
      min: -100.0,
      max: 100.0,
      defaultValue: 0.0,
      isBidirectional: true,
      suffix: '',
      getValue: (content) => (content.saturation - 1.0) * 100,
      updateValue: (content, value) =>
          content.adjustSaturation((value / 100) + 1.0),
    ),
    'hue': _ImageAdjustmentConfig(
      key: 'hue',
      min: 0.0,
      max: 360.0,
      defaultValue: 0.0,
      isBidirectional: false,
      suffix: '°',
      getValue: (content) => content.hue,
      updateValue: (content, value) => content.adjustHue(value),
    ),
    'opacity': _ImageAdjustmentConfig(
      key: 'opacity',
      min: 0.0,
      max: 100.0,
      defaultValue: 100.0,
      isBidirectional: false,
      suffix: '%',
      getValue: (content) => content.opacity * 100,
      updateValue: (content, value) => content.adjustOpacity(value / 100),
    ),
  };
}
/*
// Filters Page - Grid of filter thumbnails with GetBuilder
class _FiltersPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final String updateId;

  const _FiltersPage({
    required this.content,
    required this.onUpdate,
    required this.isExpanded,
    required this.updateId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: updateId,
      builder: (controller) => Padding(
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

            if (isExpanded) ...[
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
*/

class _FiltersPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final String updateId;

  const _FiltersPage({
    required this.content,
    required this.onUpdate,
    required this.isExpanded,
    required this.updateId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: updateId,
      builder: (controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Filter Grid
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _getAvailableFilters().length,
                itemBuilder: (context, index) {
                  final filter = _getAvailableFilters()[index];
                  final isActive = content.activeFilter == filter.key;

                  return GestureDetector(
                    onTap: () {
                      content.applyFilter(filter.key);
                      onUpdate();
                    },
                    child: _FilterThumbnail(filter: filter, isActive: isActive),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 12),
              ),
            ),

            if (isExpanded) ...[
              const SizedBox(height: 12),
              // Advanced Filter Controls
              Row(
                children: [
                  Expanded(
                    child: _CompactSlider(
                      icon: Icons.vignette,
                      label: 'Vignette',
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

              // const SizedBox(height: 12),

              // Border color picker
              // Text(
              //   'Border Color',
              //   style: TextStyle(
              //     color: Colors.white.withOpacity(0.7),
              //     fontSize: 12,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // SizedBox(
              //   height: 32,
              //   child: ListView(
              //     scrollDirection: Axis.horizontal,
              //     children: [
              //       _ColorChip(
              //         color: null,
              //         isActive: content.borderColor == null,
              //         onTap: () {
              //           content.borderColor = null;
              //           onUpdate();
              //         },
              //       ),
              //       ...Colors.primaries.map((color) {
              //         return _ColorChip(
              //           color: color,
              //           isActive: content.borderColor?.value == color.value,
              //           onTap: () {
              //             content.borderColor = color;
              //             onUpdate();
              //           },
              //         );
              //       }),
              //     ],
              //   ),
              // ),
              // if (isExpanded) ...[
              //   const SizedBox(height: 16),

              //   // Shadow controls
              //   Text(
              //     'Shadow',
              //     style: TextStyle(
              //       color: Colors.white.withOpacity(0.7),
              //       fontSize: 12,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              //   const SizedBox(height: 8),

              //   Row(
              //     children: [
              //       Expanded(
              //         child: _CompactSlider(
              //           icon: Icons.blur_on,
              //           label: 'Blur',
              //           value: content.shadowBlur,
              //           min: 0.0,
              //           max: 20.0,
              //           onChanged: (v) {
              //             content.shadowBlur = v;
              //             onUpdate();
              //           },
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: _CompactSlider(
              //           icon: Icons.open_with,
              //           label: 'Offset X',
              //           value: content.shadowOffset.dx,
              //           min: -20.0,
              //           max: 20.0,
              //           onChanged: (v) {
              //             content.shadowOffset = Offset(
              //               v,
              //               content.shadowOffset.dy,
              //             );
              //             onUpdate();
              //           },
              //         ),
              //       ),
              //     ],
              //   ),

              //   const SizedBox(height: 8),

              //   Row(
              //     children: [
              //       Expanded(
              //         child: _CompactSlider(
              //           icon: Icons.open_with,
              //           label: 'Offset Y',
              //           value: content.shadowOffset.dy,
              //           min: -20.0,
              //           max: 20.0,
              //           onChanged: (v) {
              //             content.shadowOffset = Offset(
              //               content.shadowOffset.dx,
              //               v,
              //             );
              //             onUpdate();
              //           },
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: Container(
              //           height: 40,
              //           decoration: BoxDecoration(
              //             color: const Color(0xFF2A2A2A),
              //             borderRadius: BorderRadius.circular(8),
              //           ),
              //           child: Center(
              //             child: Text(
              //               'Shadow Color',
              //               style: TextStyle(
              //                 color: Colors.white70,
              //                 fontSize: 10,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),

              //   const SizedBox(height: 8),

              //   // Shadow color picker
              //   SizedBox(
              //     height: 32,
              //     child: ListView(
              //       scrollDirection: Axis.horizontal,
              //       children: [
              //         _ColorChip(
              //           color: null,
              //           isActive: content.shadowColor == null,
              //           onTap: () {
              //             content.shadowColor = null;
              //             onUpdate();
              //           },
              //         ),
              //         ...Colors.primaries.map((color) {
              //           return _ColorChip(
              //             color: color.withOpacity(0.5),
              //             isActive:
              //                 content.shadowColor?.value ==
              //                 color.withOpacity(0.5).value,
              //             onTap: () {
              //               content.shadowColor = color.withOpacity(0.5);
              //               onUpdate();
              //             },
              //           );
              //         }),
              //       ],
              //     ),
              //   ),
              // ],
            ],
          ],
        ),
      ),
    );
  }

  List<_FilterData> _getAvailableFilters() {
    final basicFilters = [
      _FilterData(key: 'none', name: 'Original', icon: Icons.refresh),
      _FilterData(key: 'grayscale', name: 'B&W', icon: Icons.filter_b_and_w),
      _FilterData(key: 'sepia', name: 'Sepia', icon: Icons.filter_1),
      _FilterData(key: 'vintage', name: 'Vintage', icon: Icons.filter_vintage),
      _FilterData(key: 'mood', name: 'Mood', icon: Icons.mood),
      _FilterData(key: 'crisp', name: 'Crisp', icon: Icons.hd),
      _FilterData(key: 'cool', name: 'Cool', icon: Icons.ac_unit),
      _FilterData(key: 'blush', name: 'Blush', icon: Icons.face),
    ];

    if (isExpanded) {
      basicFilters.addAll([
        _FilterData(key: 'sunkissed', name: 'Sunkissed', icon: Icons.wb_sunny),
        _FilterData(key: 'fresh', name: 'Fresh', icon: Icons.eco),
        _FilterData(key: 'classic', name: 'Classic', icon: Icons.history),
        _FilterData(key: 'lomo', name: 'Lomo', icon: Icons.camera_alt),
        _FilterData(
          key: 'nashville',
          name: 'Nashville',
          icon: Icons.music_note,
        ),
        _FilterData(
          key: 'valencia',
          name: 'Valencia',
          icon: Icons.wb_incandescent,
        ),
        _FilterData(
          key: 'clarendon',
          name: 'Clarendon',
          icon: Icons.brightness_high,
        ),
        _FilterData(key: 'moon', name: 'Moon', icon: Icons.nightlight_round),
        _FilterData(key: 'kodak', name: 'Kodak', icon: Icons.photo_camera),
        _FilterData(key: 'frost', name: 'Frost', icon: Icons.ac_unit),
        _FilterData(key: 'sunset', name: 'Sunset', icon: Icons.wb_twilight),
        _FilterData(key: 'noir', name: 'Noir', icon: Icons.movie_filter),
        _FilterData(key: 'dreamy', name: 'Dreamy', icon: Icons.cloud),
        _FilterData(key: 'radium', name: 'Radium', icon: Icons.flash_on),
        _FilterData(key: 'aqua', name: 'Aqua', icon: Icons.water),
        _FilterData(key: 'purplehaze', name: 'Purple', icon: Icons.color_lens),
        _FilterData(key: 'lemonade', name: 'Lemonade', icon: Icons.local_drink),
        _FilterData(key: 'caramel', name: 'Caramel', icon: Icons.coffee),
        _FilterData(key: 'peachy', name: 'Peachy', icon: Icons.favorite),
        _FilterData(key: 'coolblue', name: 'Cool Blue', icon: Icons.waves),
        _FilterData(key: 'neon', name: 'Neon', icon: Icons.flash_auto),
        _FilterData(key: 'lush', name: 'Lush', icon: Icons.park),
        _FilterData(key: 'urbanneon', name: 'Urban', icon: Icons.location_city),
        _FilterData(
          key: 'moodymonochrome',
          name: 'Moody',
          icon: Icons.sentiment_neutral,
        ),
      ]);
    }

    return basicFilters;
  }
}

class _FilterData {
  final String key;
  final String name;
  final IconData icon;

  const _FilterData({
    required this.key,
    required this.name,
    required this.icon,
  });
}

class _FilterThumbnail extends StatelessWidget {
  final _FilterData filter;
  final bool isActive;

  const _FilterThumbnail({required this.filter, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   color: isActive ? const Color(0xFFFFA500) : const Color(0xFF2A2A2A),
      //   borderRadius: BorderRadius.circular(12),
      //   border: isActive
      //       ? Border.all(color: const Color(0xFFFFA500), width: 2)
      //       : null,
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFFFA500)
                  : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? Border.all(color: const Color(0xFFFFA500), width: 2)
                  : null,
            ),
            child: Icon(
              filter.icon,
              color: isActive ? Colors.black : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filter.name,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Effects Page - Mask shapes and overlays with GetBuilder
class _EffectsPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final String updateId;

  const _EffectsPage({
    required this.content,
    required this.onUpdate,
    required this.isExpanded,
    required this.updateId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: updateId,
      builder: (controller) => Padding(
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

            if (isExpanded) ...[
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
      ),
    );
  }
}

// Border Page - Compact border controls with GetBuilder
class _BorderPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final String updateId;

  const _BorderPage({
    required this.content,
    required this.onUpdate,
    required this.isExpanded,
    required this.updateId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: updateId,
      builder: (controller) => Padding(
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
                    max: 50.0,
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
                    max: 100.0,
                    onChanged: (v) {
                      content.borderRadius = v;
                      onUpdate();
                    },
                  ),
                ),
              ],
            ),

            if (isExpanded) ...[
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
                        content.shadowColor ??= Colors.black;
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

// Transform Page with GetBuilder
/*
class _TransformPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final String updateId;

  const _TransformPage({
    required this.content,
    required this.onUpdate,
    required this.isExpanded,
    required this.updateId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: updateId,
      builder: (controller) => Padding(
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
      ),
    );
  }
}



// Custom Compact Widgets (unchanged but optimized)

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

class _CompactSlider extends StatelessWidget {
  final IconData icon;
  final String? label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _CompactSlider({
    required this.icon,
    this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                activeTrackColor: const Color(0xFFFFA500),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFFFFA500),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          Text(
            value.round().toString(),
            style: const TextStyle(
              color: Color(0xFFFFA500),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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


*/

class _TransformPage extends StatelessWidget {
  final ImageItemContent content;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final String updateId;

  const _TransformPage({
    required this.content,
    required this.onUpdate,
    required this.isExpanded,
    required this.updateId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      id: updateId,
      builder: (controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Rotation slider
            _CompactSlider(
              icon: Icons.rotate_right,
              label: 'Rotation',
              value: content.rotationAngle,
              min: -180.0,
              max: 180.0,
              onChanged: (v) {
                content.rotationAngle = v;
                onUpdate();
              },
            ),

            const SizedBox(height: 16),

            // Flip buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: content.flipHorizontal
                          ? const Color(0xFFFFA500)
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          content.flipHorizontal = !content.flipHorizontal;
                          onUpdate();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flip,
                              color: content.flipHorizontal
                                  ? Colors.black
                                  : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Flip H',
                              style: TextStyle(
                                color: content.flipHorizontal
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: content.flipVertical
                          ? const Color(0xFFFFA500)
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          content.flipVertical = !content.flipVertical;
                          onUpdate();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: 1.5708, // 90 degrees
                              child: Icon(
                                Icons.flip,
                                color: content.flipVertical
                                    ? Colors.black
                                    : Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Flip V',
                              style: TextStyle(
                                color: content.flipVertical
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (isExpanded) ...[
              const SizedBox(height: 16),

              // Quick rotation buttons
              Text(
                'Quick Rotate',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RotationButton(
                    angle: -90,
                    onTap: () {
                      content.rotationAngle =
                          (content.rotationAngle - 90) % 360;
                      onUpdate();
                    },
                  ),
                  _RotationButton(
                    angle: 0,
                    onTap: () {
                      content.rotationAngle = 0;
                      onUpdate();
                    },
                  ),
                  _RotationButton(
                    angle: 90,
                    onTap: () {
                      content.rotationAngle =
                          (content.rotationAngle + 90) % 360;
                      onUpdate();
                    },
                  ),
                  _RotationButton(
                    angle: 180,
                    onTap: () {
                      content.rotationAngle = 180;
                      onUpdate();
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RotationButton extends StatelessWidget {
  final double angle;
  final VoidCallback onTap;

  const _RotationButton({required this.angle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: angle * (3.14159 / 180),
                child: const Icon(
                  Icons.crop_rotate,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              Text(
                '${angle.round()}°',
                style: const TextStyle(color: Colors.white70, fontSize: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widgets
class _CompactButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CompactButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _CompactSlider extends StatelessWidget {
  final IconData icon;
  final String? label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _CompactSlider({
    required this.icon,
    this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                activeTrackColor: const Color(0xFFFFA500),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFFFFA500),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          Text(
            value.round().toString(),
            style: const TextStyle(
              color: Color(0xFFFFA500),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color ?? Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? const Color(0xFFFFA500) : Colors.white24,
              width: isActive ? 2 : 1,
            ),
          ),
          child: color == null
              ? const Icon(Icons.clear, color: Colors.white70, size: 16)
              : null,
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
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFA500) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getShapeIcon(shape),
          color: isActive ? Colors.black : Colors.white70,
          size: 24,
        ),
      ),
    );
  }

  IconData _getShapeIcon(ImageMaskShape shape) {
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
          border: Border.all(color: Get.theme.colorScheme.outline, width: 1),
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

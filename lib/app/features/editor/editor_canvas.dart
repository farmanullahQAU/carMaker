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
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_view/photo_view.dart';
import 'package:screenshot/screenshot.dart';

// Define panel types as an enum
enum PanelType { none, stickers, color, text, shapes }

class EditorPage extends GetView<EditorController> {
  EditorPage({super.key});

  final ScreenshotController screenshotController = ScreenshotController();
  final RxBool allowTouch =
      false.obs; // Default to false, enable for active PhotoView
  final Rx<StackImageItem?> activePhotoItem = Rx<StackImageItem?>(
    null,
  ); // Track active PhotoView

  // Single state to manage active panel
  final Rx<PanelType> activePanel = PanelType.none.obs;

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
                    customBuilder: (StackItem<StackItemContent> item) {
                      print(
                        "Rendering item: ${item.id}, type: ${item.runtimeType}",
                      );
                      return (item is StackTextItem && item.content != null)
                          ? StackTextCase(item: item)
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
                                    painter: _BorderPainter(
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
                      print(
                        "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv $status",
                      );
                      print("Item ${item.id} status changed to $status");
                      if (status == StackItemStatus.selected) {
                        controller.activeItem.value = item;
                        if (item is StackTextItem) {
                          print("Selected StackTextItem: ${item.id}");
                          activePanel.value = PanelType.text;
                        } else {
                          activePanel.value = PanelType.none;
                        }
                        controller.draggedItem.value =
                            null; // Clear dragged item
                        controller.alignmentPoints.value =
                            []; // Clear alignment points
                      } else if (status == StackItemStatus.moving) {
                        activePanel.value = PanelType.none;
                        controller.draggedItem.value = item; // Set dragged item
                      } else if (status == StackItemStatus.idle) {
                        print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                        activePanel.value = PanelType.none;
                        if (controller.draggedItem.value?.id == item.id) {
                          controller.draggedItem.value =
                              null; // Clear dragged item
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
    final GlobalKey stackBoardKey = GlobalKey();
    final RxBool isTemplateLoaded = false.obs;
    final RxDouble canvasScale = 1.0.obs;
    final RxDouble scaledCanvasWidth = 0.0.obs;
    final RxDouble scaledCanvasHeight = 0.0.obs;

    void updateCanvasAndLoadTemplate(BoxConstraints constraints) {
      if (isTemplateLoaded.value) return;

      final double availableWidth = constraints.maxWidth * 0.9;
      final double availableHeight = constraints.maxHeight;
      final double aspectRatio =
          controller.initialTemplate!.width /
          controller.initialTemplate!.height;

      if (availableWidth / aspectRatio <= availableHeight) {
        scaledCanvasWidth.value = availableWidth;
        scaledCanvasHeight.value = availableWidth / aspectRatio;
      } else {
        scaledCanvasHeight.value = availableHeight;
        scaledCanvasWidth.value = availableHeight * aspectRatio;
      }

      canvasScale.value =
          scaledCanvasWidth.value / controller.initialTemplate!.width;

      controller.updateStackBoardRenderSize(
        Size(scaledCanvasWidth.value, scaledCanvasHeight.value),
      );
      debugPrint(
        'Updated StackBoard size: ${scaledCanvasWidth.value} x ${scaledCanvasHeight.value}, Canvas Scale: $canvasScale',
      );

      controller.loadExportedTemplate(
        controller.initialTemplate!,
        context,
        scaledCanvasWidth.value,
        scaledCanvasHeight.value,
      );

      isTemplateLoaded.value = true;
    }

    Future<void> exportAsPDF() async {
      try {
        controller.boardController.unSelectAll();
        final exportKey = GlobalKey();
        final image = await screenshotController.captureFromWidget(
          Material(
            child: SizedBox(
              width: scaledCanvasWidth.value,
              height: scaledCanvasHeight.value,
              key: exportKey,
              child: _buildCanvasStack(
                showGrid: false,
                showBorders: false,
                stackBoardKey: GlobalKey(),
                canvasScale: canvasScale,
                scaledCanvasWidth: scaledCanvasWidth,
                scaledCanvasHeight: scaledCanvasHeight,
              ),
            ),
          ),
          targetSize: Size(scaledCanvasWidth.value, scaledCanvasHeight.value),
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
              scaledCanvasWidth.value,
              scaledCanvasHeight.value,
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
          );
        }
      } catch (e, s) {
        debugPrint('Export PDF failed: $e\n$s');
        Get.snackbar(
          'Error',
          'Failed to export PDF due to widget issue',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    Future<void> exportAsImage() async {
      try {
        final exportKey = GlobalKey();
        final image = await screenshotController.captureFromWidget(
          SizedBox(
            width: scaledCanvasWidth.value,
            height: scaledCanvasHeight.value,
            key: exportKey,
            child: _buildCanvasStack(
              showGrid: false,
              showBorders: false,
              stackBoardKey: GlobalKey(),
              canvasScale: canvasScale,
              scaledCanvasWidth: scaledCanvasWidth,
              scaledCanvasHeight: scaledCanvasHeight,
            ),
          ),
          targetSize: Size(scaledCanvasWidth.value, scaledCanvasHeight.value),
          pixelRatio: 2,
        );

        final output = await getTemporaryDirectory();
        final file = File("${output.path}/invitation_card.png");
        await file.writeAsBytes(image);
        Get.snackbar(
          'Success',
          'Image exported to ${file.path}',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.to(() => ExportPreviewPage(imagePath: file.path, pdfPath: ''));
      } catch (e, s) {
        debugPrint('Export Image failed: $e\n$s');
        Get.snackbar(
          'Error',
          'Failed to export image due to widget issue',
          snackPosition: SnackPosition.BOTTOM,
        );
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
      }
      return const SizedBox.shrink();
    }

    return Scaffold(
      bottomSheet: Obx(() {
        if (activePanel.value == PanelType.none) return SizedBox.shrink();

        return AnimatedSize(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: buildPanelContent(),
        );
      }),

      appBar: AppBar(
        title: Obx(() => Text("Active Panel: ${activePanel.value}")),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => controller.exportDesign(),
            tooltip: 'Export',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: controller.redo,
            tooltip: 'Redo',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => exportAsPDF(),
            tooltip: 'Export as PDF',
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () => exportAsImage(),
            tooltip: 'Export as Image',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          activePanel.value = PanelType.none;
        },

        child: Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            updateCanvasAndLoadTemplate(constraints);
                          });
                          return _buildCanvasStack(
                            showGrid: true,
                            showBorders: true,
                            stackBoardKey: stackBoardKey,
                            canvasScale: canvasScale,
                            scaledCanvasWidth: scaledCanvasWidth,
                            scaledCanvasHeight: scaledCanvasHeight,
                          );
                        },
                  ),
                ),
              ),
              SafeArea(
                bottom: true,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ToolbarButton(
                        icon: Icons.emoji_emotions_outlined,
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
                      _ToolbarButton(
                        icon: Icons.palette_outlined,
                        label: 'Color',
                        panelType: PanelType.color,
                        activePanel: activePanel,
                        onPressed: () {
                          activePanel.value =
                              activePanel.value == PanelType.color
                              ? PanelType.none
                              : PanelType.color;
                        },
                      ),
                      _ToolbarButton(
                        icon: Icons.text_fields,
                        label: 'Text',
                        panelType: PanelType.text,
                        activePanel: activePanel,
                        onPressed: () {
                          activePanel.value =
                              activePanel.value == PanelType.text
                              ? PanelType.none
                              : PanelType.text;
                          if (controller.activeItem.value == null ||
                              controller.activeItem.value is! StackTextItem) {
                            controller.addText(
                              "New Text",
                              size: const Size(100, 50),
                            );
                          }
                        },
                      ),
                      _ToolbarButton(
                        icon: Icons.shape_line_outlined,
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
            ],
          ),
        ),
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

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final PanelType panelType;
  final Rx<PanelType> activePanel;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.panelType,
    required this.activePanel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(icon),
            color: activePanel.value == panelType
                ? AppColors.branding
                : AppColors.highlight,
            onPressed: onPressed,
            tooltip: label,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: activePanel.value == panelType
                  ? AppColors.branding
                  : AppColors.highlight,
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for ShapePanel (implement as needed)
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
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      child: DefaultTabController(
        length: categories.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              // indicatorPadding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
              tabs: categories.keys.map((category) {
                return Tab(text: category);
              }).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: categories.values.map((stickers) {
                  return GridView.count(
                    padding: EdgeInsets.all(12),
                    crossAxisCount: 8,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: stickers.map((sticker) {
                      return SafeArea(
                        bottom: true,
                        child: GestureDetector(
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
                        ),
                      );
                    }).toList(),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Row(
              children: [
                Icon(Icons.color_lens, size: 20, color: Colors.grey[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: controller.backgroundHue.value,
                    min: 0.0,
                    max: 360.0,
                    // divisions: 360,
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
          ),
        ],
      ),
    );
  }
}

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
    return TextStylingEditor(
      key: ValueKey(textItem.id), // Force rebuild on item change
      textItem: textItem,
      onClose: () {
        // controller.activeItem.value = null;
        // showTextPanel.value = false; // Update visibility
      },
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

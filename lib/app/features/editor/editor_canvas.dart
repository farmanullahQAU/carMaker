import 'dart:io';
import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/edit_item/view.dart';
import 'package:cardmaker/app/features/editor/image_editor/view.dart';
import 'package:cardmaker/app/features/editor/text_editor/view.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_case.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';

class EditorPage extends GetView<CanvasController> {
  const EditorPage({super.key});

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

  Widget buildPanelContent() {
    return GetBuilder<CanvasController>(
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
          index: controller.activePanel.value.index - 1,
          alignment: Alignment.bottomCenter,
          children: panels,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          GetBuilder<CanvasController>(
            id: 'export_button',
            builder: (controller) => _ModernExportButton(
              onExportPDF: controller.exportAsPDF,
              onExportImage: controller.exportAsImage,
              onSave: () async {
                try {
                  final file = await controller.exportAsImage();
                  await controller.addTemplate(file);
                  // controller.saveDesign();
                  controller.isExporting = false;
                } catch (err) {
                  controller.isExporting = false;
                }
              },
              isExporting: controller.isExporting,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,

                      boxShadow: [
                        BoxShadow(
                          color: Get.theme.shadowColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),

                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              controller.updateCanvasAndLoadTemplate(
                                constraints,
                                context,
                              );
                            });
                            return CanvasStack(
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ProfessionalToolbarButton(
                        icon: Icons.emoji_emotions_outlined,
                        activeIcon: Icons.emoji_emotions,
                        label: 'Stickers',
                        panelType: PanelType.stickers,
                        activePanel: controller.activePanel,
                        onPressed: () {
                          controller.activePanel.value =
                              controller.activePanel.value == PanelType.stickers
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
                        activePanel: controller.activePanel,
                        onPressed: () {
                          controller.activePanel.value =
                              controller.activePanel.value == PanelType.color
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
                        activePanel: controller.activePanel,
                        onPressed: () {
                          if (controller.activePanel.value == PanelType.text) {
                            controller.activePanel.value = PanelType.none;
                          } else {
                            if (controller.activeItem.value == null ||
                                controller.activeItem.value is StackTextItem) {
                              // controller.addText("Tap to edit text");

                              Get.to(() => UpdateTextView());
                            }
                            controller.activePanel.value = PanelType.text;
                          }
                          controller.update(['bottom_sheet']);
                        },
                      ),
                      _ProfessionalToolbarButton(
                        icon: Icons.photo_filter_outlined,
                        activeIcon: Icons.photo_filter,
                        label: 'Image',
                        panelType: PanelType.advancedImage,
                        activePanel: controller.activePanel,
                        onPressed: () {
                          if (controller.activePanel.value ==
                              PanelType.advancedImage) {
                            controller.activePanel.value = PanelType.none;
                          } else {
                            if (controller.activeItem.value != null &&
                                controller.activeItem.value is StackImageItem) {
                              controller.activePanel.value =
                                  PanelType.advancedImage;
                            } else {
                              // controller.pickAndAddImage();

                              // Show bottom sheet with options
                              showModalBottomSheet<Widget>(
                                context: context,
                                builder: (_) => BottomSheet(
                                  onClosing: () {},
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: Icon(
                                            Icons.add_photo_alternate_outlined,
                                          ),
                                          title: Text('Add Image to Canvas'),
                                          onTap: () {
                                            Get.back(); // Close bottom sheet
                                            controller.pickAndAddImage();
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.image_outlined),
                                          title: Text(
                                            'Change Background Image',
                                          ),
                                          onTap: () {
                                            Get.back(); // Close bottom sheet
                                            controller
                                                .pickAndUpdateBackground();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                barrierColor: Colors.transparent,
                              );
                            }
                          }
                          controller.update(['bottom_sheet']);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Obx(
            () => controller.activePanel.value == PanelType.none
                ? SizedBox()
                : buildPanelContent(),
          ),
        ],
      ),
    );
  }
}

class _StickerPanel extends StatelessWidget {
  final CanvasController controller;

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
                          controller.addSticker(sticker);
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
  final CanvasController controller;

  const _HueAdjustmentPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.colorize, size: 20, color: AppColors.branding),
              const SizedBox(width: 8),
              Text(
                'Hue Adjustment',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: [
                // Compact Hue Slider
                CompactSlider(
                  icon: Icons.palette,
                  label: 'Hue',
                  value: controller.backgroundHue.value,
                  min: 0.0,
                  max: 360.0,
                  onChanged: (value) {
                    controller.updateBackgroundHue(value);
                  },
                ),
                // Current Hue Preview
                Container(
                  height: 24,
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: controller.backgroundHue.value != 0.0
                        ? LinearGradient(
                            colors: [
                              HSLColor.fromAHSL(
                                1,
                                controller.backgroundHue.value,
                                1,
                                0.5,
                              ).toColor(),
                              HSLColor.fromAHSL(
                                1,
                                controller.backgroundHue.value,
                                0.8,
                                0.7,
                              ).toColor(),
                            ],
                          )
                        : const LinearGradient(
                            colors: [Colors.transparent, Colors.transparent],
                          ),
                  ),
                  child: Center(
                    child: Text(
                      '${controller.backgroundHue.value.round()}°',
                      style: TextStyle(
                        color: controller.backgroundHue.value != 0.0
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        shadows: controller.backgroundHue.value != 0.0
                            ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : [],
                      ),
                    ),
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
    return GetBuilder<CanvasController>(
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
  final CanvasController controller;
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
      ],
    );
  }
}

class CanvasStack extends StatelessWidget {
  final bool showGrid;
  final bool showBorders;
  final GlobalKey stackBoardKey;
  final RxDouble canvasScale;
  final RxDouble scaledCanvasWidth;
  final RxDouble scaledCanvasHeight;

  const CanvasStack({
    super.key,
    required this.showGrid,
    required this.showBorders,
    required this.stackBoardKey,
    required this.canvasScale,
    required this.scaledCanvasWidth,
    required this.scaledCanvasHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CanvasController>(
      id: 'canvas_stack',
      builder: (controller) {
        print("Built");
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background container with hue color when no background image
            if (controller.selectedBackground.value == null)
              IgnorePointer(
                ignoring: true,
                child: SizedBox(
                  width: scaledCanvasWidth.value,
                  height: scaledCanvasHeight.value,
                  child: Container(
                    color: controller.backgroundHue.value == 0.0
                        ? Colors
                              .transparent // Transparent when hue is 0
                        : HSLColor.fromAHSL(
                            1,
                            controller.backgroundHue.value,
                            1,
                            0.5,
                          ).toColor(),
                  ),
                ),
              ),

            // Profile images
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
            // Foreground image with transparent hole (only if background image exists)
            if (controller.selectedBackground.value != null)
              IgnorePointer(
                ignoring: true,
                child: SizedBox(
                  width: scaledCanvasWidth.value,
                  height: scaledCanvasHeight.value,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      _hueMatrix(controller.backgroundHue.value),
                    ),
                    child:
                        (controller.selectedBackground.value!.startsWith(
                              'http',
                            ) ||
                            controller.selectedBackground.value!.startsWith(
                              'https',
                            ))
                        ? Image.network(controller.selectedBackground.value!)
                        : Image.file(
                            File(controller.selectedBackground.value!),
                            fit: BoxFit.cover,
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
                          controller.activePhotoItem.value = tappedItem;
                          controller.allowTouch.value = true;
                          controller.update(['stack_board']);
                        } else {
                          if (controller.allowTouch.value != false) {
                            //to overcome unncessary rebuilds
                            controller.allowTouch.value = false;
                            controller.activePhotoItem.value = null;
                          }
                          controller.activeItem.value = null;
                          controller.activePanel.value = PanelType.none;
                          controller.update(['stack_board']);
                        }
                      }
                    : null,
                child: GetBuilder<CanvasController>(
                  id: 'stack_board',
                  builder: (controller) => IgnorePointer(
                    ignoring: controller.allowTouch.value,
                    child: StackBoard(
                      key: stackBoardKey,
                      controller: controller.boardController,
                      customBuilder: (StackItem<StackItemContent> item) {
                        return (item is StackTextItem && item.content != null)
                            ? StackTextCase(item: item, isFitted: true)
                            : (item is StackImageItem && item.content != null)
                            ? StackImageCase(item: item)
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
                      onEdit: (item) async {
                        if (item is StackTextItem) {
                          await Get.to(() => UpdateTextView(item: item));
                        }
                      },
                      onStatusChanged: (item, status) {
                        if (status == StackItemStatus.selected) {
                          controller.activeItem.value = controller
                              .boardController
                              .getById(item.id);
                          if (item is StackTextItem) {
                            controller.activePanel.value = PanelType.text;
                          } else if (item is StackImageItem) {
                            controller.activePanel.value =
                                PanelType.advancedImage;
                          } else {
                            controller.activePanel.value = PanelType.none;
                          }
                          controller.draggedItem.value = null;
                        } else if (status == StackItemStatus.moving) {
                          controller.activePanel.value = PanelType.none;
                          controller.draggedItem.value = item;
                        } else if (status == StackItemStatus.idle) {
                          controller.activePanel.value = PanelType.none;
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

class BorderPainter extends CustomPainter {
  final bool dotted;
  final double stroke = 0.2; // Made thinner
  final double dash = 2; // Smaller dash
  final double dash2 = 2; // Smaller gap

  const BorderPainter({required this.dotted});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Get.find<CanvasController>().draggedItem.value == null
          ? AppColors.accent.withOpacity(0.5) // More subtle color
          : AppColors.accent.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke; // Thin stroke

    final Rect rect = Offset.zero & size;

    if (!dotted) {
      canvas.drawRect(rect, paint);
      return;
    }
    if (Get.find<CanvasController>().draggedItem.value != null) {
      final Path path = Path()..addRect(rect);
      final Path dashedPath = Path();
      for (final pm in path.computeMetrics()) {
        double d = 0;
        while (d < pm.length) {
          final double len = math.min(dash, pm.length - d);
          dashedPath.addPath(pm.extractPath(d, d + len), Offset.zero);
          d += dash + dash2; // Adjusted dash pattern
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
      ..color = guideColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    // Fixed: Both center guides now use the same thin, professional stroke width
    final Paint centerPaint = Paint()
      ..color = centerGuideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5; // Made thin and professional

    if (draggedItem != null) {
      // Draw center guides only when dragging - both using same paint
      _drawDashedLine(
        canvas,
        Offset(stackBoardSize.width / 2, 0),
        Offset(stackBoardSize.width / 2, stackBoardSize.height),
        centerPaint, // Using same paint for consistency
      );
      _drawDashedLine(
        canvas,
        Offset(0, stackBoardSize.height / 2),
        Offset(stackBoardSize.width, stackBoardSize.height / 2),
        centerPaint, // Using same paint for consistency
      );
    }

    if (showGrid) {
      // Calculate optimal grid division based on canvas dimensions
      // Find the greatest common divisor-like approach for clean divisions
      final double aspectRatio = stackBoardSize.width / stackBoardSize.height;

      // Choose grid division based on aspect ratio for better visual results
      int horizontalDivisions;
      int verticalDivisions;

      if (aspectRatio > 1.5) {
        // Wide format (e.g., 2:1, 16:9)
        horizontalDivisions = 16;
        verticalDivisions = (horizontalDivisions / aspectRatio).round();
      } else if (aspectRatio < 0.67) {
        // Tall format (e.g., 9:16, 1:2)
        verticalDivisions = 16;
        horizontalDivisions = (verticalDivisions * aspectRatio).round();
      } else {
        // Square-ish format (e.g., 1:1, 4:3, 3:4)
        horizontalDivisions = 12;
        verticalDivisions = (horizontalDivisions / aspectRatio).round();
      }

      // Ensure we have at least 4 divisions in each direction
      horizontalDivisions = math.max(4, horizontalDivisions);
      verticalDivisions = math.max(4, verticalDivisions);

      // Calculate actual grid cell sizes
      final double cellWidth = stackBoardSize.width / horizontalDivisions;
      final double cellHeight = stackBoardSize.height / verticalDivisions;

      // Draw vertical lines
      for (int i = 0; i <= horizontalDivisions; i++) {
        final double x = i * cellWidth;
        _drawDashedLine(
          canvas,
          Offset(x, 0),
          Offset(x, stackBoardSize.height),
          gridPaint,
        );
      }

      // Draw horizontal lines
      for (int i = 0; i <= verticalDivisions; i++) {
        final double y = i * cellHeight;
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
        oldDelegate.gridSize != gridSize;
  }
}

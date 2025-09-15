import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/edit_item/view.dart';
import 'package:cardmaker/app/features/editor/image_editor/view.dart';
import 'package:cardmaker/app/features/editor/shape_editor/view.dart';
import 'package:cardmaker/app/features/editor/text_editor/view.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/item_case/shape_stack_case.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/shack_shape_item.dart';
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

  // In your EditorPage, update the buildPanelContent method
  Widget buildPanelContent() {
    return GetBuilder<CanvasController>(
      id: 'bottom_sheet',
      builder: (controller) {
        final item = controller.activeItem.value;
        final activePanel = controller.activePanel.value;

        final panels = <Widget>[
          // Show ShapeEditorPanel directly when shapes panel is active
          (activePanel == PanelType.shapes)
              ? GestureDetector(
                  onTap: () {
                    // Allow taps to pass through to the canvas
                  },
                  behavior: HitTestBehavior.translucent,
                  child: ShapeEditorPanel(
                    onClose: () {
                      controller.activePanel.value = PanelType.none;
                    },
                  ),
                )
              : const SizedBox.shrink(),

          // Show shape editor when a shape item is selected
          (activePanel == PanelType.shapeEditor && item is StackShapeItem)
              ? GestureDetector(
                  onTap: () {
                    // Allow taps to pass through to the canvas
                  },
                  behavior: HitTestBehavior.translucent,
                  child: ShapeEditorPanel(
                    shapeItem: item,
                    onClose: () {
                      controller.activePanel.value = PanelType.none;
                    },
                  ),
                )
              : const SizedBox.shrink(),

          _StickerPanel(controller: controller),
          _HueAdjustmentPanel(controller: controller),
          (item is StackTextItem)
              ? _TextEditorPanel(
                  key: ValueKey(item.id),
                  controller: controller,
                  textItem: item,
                )
              : const SizedBox.shrink(),
          (item is StackImageItem)
              ? AdvancedImagePanel(key: ValueKey(item.id), imageItem: item)
              : const SizedBox.shrink(),
        ];

        // Map PanelType to the correct index
        int getPanelIndex(PanelType type) {
          switch (type) {
            case PanelType.shapes:
              return 0;
            case PanelType.shapeEditor:
              return 1;
            case PanelType.stickers:
              return 2;
            case PanelType.color:
              return 3;
            case PanelType.text:
              return 4;
            case PanelType.advancedImage:
              return 5;
            case PanelType.none:
              return -1;
          }
        }

        final panelIndex = getPanelIndex(activePanel);

        return IgnorePointer(
          // Only ignore pointers when the panel is not active
          ignoring: activePanel == PanelType.none,
          child: IndexedStack(
            index: panelIndex >= 0 ? panelIndex : 0,
            alignment: Alignment.bottomCenter,
            children: panels,
          ),
        );
      },
    );
  }
  // Widget buildPanelContent() {
  //   return GetBuilder<CanvasController>(
  //     id: 'bottom_sheet',
  //     builder: (controller) {
  //       final item = controller.activeItem.value;
  //       final activePanel = controller.activePanel.value;

  //       final panels = <Widget>[
  //         // Show ShapeEditorPanel directly when shapes panel is active
  //         (activePanel == PanelType.shapes)
  //             ? ShapeEditorPanel(
  //                 // onApply: (shape) {
  //                 //   controller.addShapeItem(shape);
  //                 // },
  //                 onClose: () {
  //                   controller.activePanel.value = PanelType.none;
  //                 },
  //               )
  //             : const SizedBox.shrink(),

  //         // Show shape editor when a shape item is selected
  //         (activePanel == PanelType.shapeEditor && item is StackShapeItem)
  //             ? ShapeEditorPanel(
  //                 shapeItem: item,
  //                 // onApply: (shape) {
  //                 //   controller.updateItem(shape);
  //                 // },
  //                 onClose: () {
  //                   controller.activePanel.value = PanelType.none;
  //                 },
  //               )
  //             : const SizedBox.shrink(),

  //         _StickerPanel(controller: controller),
  //         _HueAdjustmentPanel(controller: controller),
  //         (item is StackTextItem)
  //             ? _TextEditorPanel(
  //                 key: ValueKey(item.id),
  //                 controller: controller,
  //                 textItem: item,
  //               )
  //             : const SizedBox.shrink(),
  //         (item is StackImageItem)
  //             ? AdvancedImagePanel(key: ValueKey(item.id), imageItem: item)
  //             : const SizedBox.shrink(),
  //       ];

  //       // Map PanelType to the correct index
  //       int getPanelIndex(PanelType type) {
  //         switch (type) {
  //           case PanelType.shapes:
  //             return 0;
  //           case PanelType.shapeEditor:
  //             return 1;
  //           case PanelType.stickers:
  //             return 2;
  //           case PanelType.color:
  //             return 3;
  //           case PanelType.text:
  //             return 4;
  //           case PanelType.advancedImage:
  //             return 5;
  //           case PanelType.none:
  //             return -1;
  //         }
  //       }

  //       final panelIndex = getPanelIndex(activePanel);

  //       return IndexedStack(
  //         index: panelIndex >= 0 ? panelIndex : 0,
  //         alignment: Alignment.bottomCenter,
  //         children: panels,
  //       );
  //     },
  //   );
  // }

  // Update your StackBoard customBuilder in the CanvasStack widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          Text(controller.backgroundHue.toString()),
          GetBuilder<CanvasController>(
            id: 'export_button',
            builder: (controller) => _ModernExportButton(
              onExportPDF: controller.exportAsPDF,
              onExportImage: controller.exportAsImage,
              onSaveDraft: controller.saveDraft,
              onSave: () async {
                try {
                  await controller.saveAsPublicProject();
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

              ProfessionalBottomToolbar(controller: controller),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
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
        '😍',
        '🥳',
        '💝',
        '🌈',
        '💎',
        '👑',
        '😎',
        '🎀',
        '🥰',
        '🙌',
        '💯',
        '🚀',
        '🎯',
        '🏆',
        '🎖️',
        '🥇',
        '🎗️',
        '😻',
        '🤩',
        '🔥',
      ],
      'Emojis': [
        '😀',
        '😂',
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
        '😢',
        '😉',
        '🤓',
        '😣',
        '😝',
        '😗',
        '😙',
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
        '💟',
        '❣️',
        '💌',
        '💑',
        '💋',
      ],
      'Party': [
        '🎉',
        '🎊',
        '🎈',
        '🎁',
        '🎂',
        '🍰',
        '🪅',
        '🎆',
        '🎇',
        '🍾',
        '🥂',
        '🎤',
        '🕺',
        '💃',
        '🎸',
        '🥁',
        '🎺',
        '🎻',
        '🎵',
        '🎶',
      ],
      'Birthdays': [
        '🧁',
        '🕯️',
        '🎠',
        '🎡',
        '🎈',
        '🎁',
        '🎂',
        '🥳',
        '🎊',
        '🎉',
        '🎀',
        '🥂',
        '🎶',
        '🧁',
        '🕯️',
        '🎠',
        '🎡',
        '🎈',
        '🎁',
        '🎂',
      ],
      'Weddings': [
        '💍',
        '👰',
        '🤵',
        '💒',
        '💐',
        '👰‍♀️',
        '🤵‍♂️',
        '🎩',
        '🌸',
        '💏',
        '👩‍❤️‍👨',
        '👩‍❤️‍👩',
        '👨‍❤️‍👨',
        '💐',
        '💍',
        '💒',
        '👰',
        '🤵',
        '🎩',
        '🌸',
      ],
      'Holidays': [
        '🎄',
        '🎅',
        '🦌',
        '❄️',
        '☃️',
        '🎃',
        '👻',
        '🦃',
        '🐰',
        '🥚',
        '🇺🇳',
        '🕎',
        '🎍',
        '🎑',
        '🪔',
        '🎆',
        '🎇',
        '🎁',
        '🧧',
        '🎄',
      ],
      'Leaves': [
        '🍃',
        '🌿',
        '🍂',
        '🍁',
        '🌱',
        '🌾',
        '🍃',
        '🌿',
        '🍂',
        '🍁',
        '🌱',
        '🌾',
        '🍃',
        '🌿',
        '🍂',
        '🍁',
        '🌱',
        '🌾',
        '🍃',
        '🌿',
      ],
      'Alphabet': [
        '🇦',
        '🇧',
        '🇨',
        '🇩',
        '🇪',
        '🇫',
        '🇬',
        '🇭',
        '🇮',
        '🇯',
        '🇰',
        '🇱',
        '🇲',
        '🇳',
        '🇴',
        '🇵',
        '🇶',
        '🇷',
        '🇸',
        '🇹',
      ],
      'Nature': [
        '🌺',
        '🌻',
        '🌷',
        '🌹',
        '🌳',
        '🌲',
        '🌴',
        '🌵',
        '🌊',
        '⛅',
        '☀️',
        '🌙',
        '🌍',
        '🌬️',
        '🌪️',
        '🌼',
        '🌸',
        '🌻',
        '🌷',
        '🌹',
      ],
      'Animals': [
        '🐶',
        '🐱',
        '🐻',
        '🐼',
        '🐨',
        '🦁',
        '🐯',
        '🦒',
        '🦊',
        '🦄',
        '🐘',
        '🦋',
        '🐝',
        '🦉',
        '🐦',
        '🐳',
        '🐬',
        '🦚',
        '🐢',
        '🐙',
      ],
      'Food': [
        '🍎',
        '🍇',
        '🍓',
        '🍒',
        '🍉',
        '🍍',
        '🍔',
        '🍕',
        '🍟',
        '🍣',
        '🍦',
        '🍩',
        '☕',
        '🍵',
        '🥐',
        '🥞',
        '🍜',
        '🥗',
        '🍪',
        '🍫',
      ],
      'Travel': [
        '✈️',
        '🗺️',
        '🏖️',
        '🏝️',
        '⛰️',
        '🏕️',
        '🗽',
        '🗼',
        '🏰',
        '🗻',
        '🚗',
        '🚂',
        '⛵',
        '🛳️',
        '🛸',
        '🎒',
        '🧳',
        '🛫',
        '🛬',
        '🗿',
      ],
      'Motivational': [
        '💪',
        '💡',
        '✨',
        '👊',
        '🌱',
        '💫',
        '🧠',
        '🏅',
        '🌟',
        '🎯',
        '💯',
        '⚡',
        '🌍',
        '🚀',
        '🏆',
        '🎖️',
        '🥇',
        '🙌',
        '🌈',
        '🔥',
      ],
      'Social Media': [
        '📸',
        '📷',
        '📱',
        '💬',
        '🗣️',
        '🔗',
        '📍',
        '🖼️',
        '🎥',
        '🎬',
        '🔄',
        '🔃',
        '👍',
        '👀',
        '📩',
        '📤',
        '🌐',
        '📲',
        '🔔',
        '📧',
      ],
      'Symbols': [
        '⭐',
        '⚡',
        '💥',
        '🎪',
        '⚙️',
        '🛠️',
        '🔮',
        '🔒',
        '🔑',
        '🛡️',
        '💣',
        '🎰',
        '🧩',
        '🎨',
        '🖌️',
        '🖍️',
        '✂️',
        '📏',
        '📐',
        '🧬',
      ],
      'Events': [
        '🎫',
        '🎭',
        '🎤',
        '🎥',
        '🎡',
        '🎢',
        '🎠',
        '🎟️',
        '🏟️',
        '🎲',
        '🎿',
        '🏇',
        '🏀',
        '⚽',
        '🏈',
        '🎾',
        '🏓',
        '🏒',
        '⛳',
        '🏸',
      ],
      'Baby': [
        '👶',
        '🍼',
        '🧸',
        '🚼',
        '👼',
        '🛁',
        '👶',
        '🍼',
        '🧸',
        '🚼',
        '👼',
        '🛁',
        '👶',
        '🍼',
        '🧸',
        '🚼',
        '👼',
        '🛁',
        '👶',
        '🍼',
      ],
      'Fitness': [
        '🏋️',
        '🤸',
        '🏃',
        '🚴',
        '🏊',
        '🧘',
        '🥊',
        '🏋️‍♀️',
        '🏋️‍♂️',
        '🤸‍♀️',
        '🤸‍♂️',
        '🏃‍♀️',
        '🏃‍♂️',
        '🚴‍♀️',
        '🚴‍♂️',
        '🏊‍♀️',
        '🏊‍♂️',
        '🧘‍♀️',
        '🧘‍♂️',
        '🥊',
      ],
      'Daily Used': [
        '📱',
        '📧',
        '📲',
        '💬',
        '📞',
        '📅',
        '⏰',
        '🕒',
        '📍',
        '📝',
        '✉️',
        '📩',
        '📤',
        '📥',
        '🖱️',
        '💻',
        '🖨️',
        '📋',
        '📊',
        '📈',
      ],
    };

    return Container(
      height: 180,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Get.theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -3),
          ),
        ],
        // borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        color: Get.theme.colorScheme.surfaceContainerHighest,
      ),
      child: DefaultTabController(
        length: categories.length,
        child: Column(
          children: [
            Container(
              height: 33,
              padding: EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surfaceContainer,
                // borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                isScrollable: true,
                dividerHeight: 0,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  // color: AppColors.branding.withOpacity(0.1),
                ),
                labelColor: AppColors.branding,
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
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8, // Horizontal spacing between stickers
                      runSpacing: 8, // Vertical spacing between rows
                      alignment:
                          WrapAlignment.start, // Align stickers to the start
                      children: stickers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final sticker = entry.value;
                        return GestureDetector(
                          onTap: () {
                            controller.addSticker(sticker);
                            // Haptic feedback
                            // HapticFeedback.lightImpact();
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 150),
                            width: 48, // Fixed width for each sticker
                            height: 48, // Fixed height for each sticker
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
                      }).toList(),
                    ),
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

final RxBool useAdvancedGradient = false.obs; // Default to simple gradient

// Update the _HueAdjustmentPanel to its original state but with gradient options
class _HueAdjustmentPanel extends StatelessWidget {
  final CanvasController controller;

  const _HueAdjustmentPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasBackgroundImage = controller.selectedBackground.value != null;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasBackgroundImage ? Icons.colorize : Icons.gradient,
                  size: 20,
                  color: AppColors.branding,
                ),
                const SizedBox(width: 8),
                Text(
                  hasBackgroundImage ? 'Hue Adjustment' : 'Gradient Background',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                // Compact Hue/Gradient Slider
                CompactSlider(
                  icon: hasBackgroundImage ? Icons.colorize : Icons.gradient,
                  label: hasBackgroundImage ? 'Hue' : 'Color Theme',
                  value: controller.backgroundHue.value,
                  min: 0.0,
                  max: 360.0,
                  onChanged: (value) {
                    controller.updateBackgroundHue(value);
                  },
                ),
                const SizedBox(height: 8),
                // Preview with gradient
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: _getPreviewGradient(
                      controller.backgroundHue.value,
                      hasBackgroundImage,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hasBackgroundImage
                          ? '${controller.backgroundHue.value.round()}°'
                          : 'Theme ${(controller.backgroundHue.value / 36).round() + 1}',
                      style: TextStyle(
                        color: _getTextColor(controller.backgroundHue.value),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!hasBackgroundImage) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Drag to change gradient colors',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }

  LinearGradient _getPreviewGradient(double hueValue, bool hasBackgroundImage) {
    if (!hasBackgroundImage) {
      if (hueValue == 0.0) {
        return const LinearGradient(colors: [Colors.white, Colors.white]);
      }

      final baseColor = HSLColor.fromAHSL(1, hueValue, 1, 0.5).toColor();
      final lighterColor = HSLColor.fromAHSL(1, hueValue, 0.8, 0.7).toColor();
      final darkerColor = HSLColor.fromAHSL(1, hueValue, 0.8, 0.3).toColor();

      return LinearGradient(colors: [lighterColor, baseColor, darkerColor]);
    } else {
      // For images, show a simple hue preview
      return LinearGradient(
        colors: [
          HSLColor.fromAHSL(1, hueValue, 1, 0.5).toColor(),
          HSLColor.fromAHSL(1, hueValue, 0.8, 0.7).toColor(),
        ],
      );
    }
  }

  Color _getTextColor(double hueValue) {
    // Determine if text should be white or black based on background brightness
    final color = HSLColor.fromAHSL(1, hueValue, 1, 0.5).toColor();
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
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

class ProfessionalBottomToolbar extends StatelessWidget {
  final CanvasController controller;

  const ProfessionalBottomToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfessionalToolbarButton(
                icon: Icons.shape_line_outlined,
                activeIcon: Icons.shape_line,
                label: 'Shapes',
                panelType: PanelType.shapes,
                activePanel: controller.activePanel,
                onPressed: () {
                  if (controller.activePanel.value == PanelType.shapes) {
                    controller.activePanel.value = PanelType.none;
                  } else {
                    controller.activePanel.value = PanelType.shapes;
                    controller.activeItem.value = null;
                  }
                  controller.update(['bottom_sheet']);
                },
              ),
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
                      Get.to(() => UpdateTextView());
                    }
                    controller.activePanel.value = PanelType.none;
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
                  if (controller.activePanel.value == PanelType.advancedImage) {
                    controller.activePanel.value = PanelType.none;
                  } else {
                    if (controller.activeItem.value != null &&
                        controller.activeItem.value is StackImageItem) {
                      controller.activePanel.value = PanelType.advancedImage;
                    } else {
                      _showImageOptions(context);
                    }
                  }
                  controller.update(['bottom_sheet']);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.add_photo_alternate_outlined,
                label: "Add Image to Canvas",
                onTap: () {
                  Navigator.pop(context);
                  controller.pickAndAddImage();
                },
              ),
              const SizedBox(height: 12),
              _ActionButton(
                icon: Icons.image_outlined,
                label: "Change Background Image",
                onTap: () {
                  Navigator.pop(context);
                  controller.pickAndUpdateBackground();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
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
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              child: Column(
                spacing: 6,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary.withOpacity(0.12)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      size: 22,
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 200),
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.7),
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ModernExportButton extends StatelessWidget {
  final VoidCallback onExportPDF;
  final VoidCallback onSaveDraft;

  final VoidCallback onExportImage;
  final VoidCallback onSave;
  final bool isExporting;

  const _ModernExportButton({
    required this.onExportPDF,
    required this.onExportImage,
    required this.onSave,
    required this.isExporting,
    required this.onSaveDraft,
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

          PopupMenuItem<String>(
            value: 'draft',
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
                      'save draft',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'save as a draft',
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

              break;
            case 'pdf':
              onExportPDF();
              break;
            case 'draft':
              onSaveDraft();
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

  // Add this method to the CanvasStack class

  // Replace the _getBackgroundGradient method with this professional version
  // Add this method to the CanvasStack class
  LinearGradient _getBackgroundGradient(double hueValue) {
    // Predefined professional gradients for different hue ranges
    if (hueValue == 0.0) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.transparent, Colors.transparent],
        stops: [0.0, 1.0],
      );
    } else if (hueValue < 60) {
      // Reds and oranges
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HSLColor.fromAHSL(1, hueValue, 1, 0.6).toColor(),
          HSLColor.fromAHSL(1, hueValue + 30, 0.9, 0.4).toColor(),
        ],
      );
    } else if (hueValue < 120) {
      // Yellows and greens
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HSLColor.fromAHSL(1, hueValue, 1, 0.7).toColor(),
          HSLColor.fromAHSL(1, hueValue - 30, 0.9, 0.4).toColor(),
        ],
      );
    } else if (hueValue < 180) {
      // Greens and teals
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HSLColor.fromAHSL(1, hueValue, 0.9, 0.6).toColor(),
          HSLColor.fromAHSL(1, hueValue + 20, 0.8, 0.4).toColor(),
        ],
      );
    } else if (hueValue < 240) {
      // Blues
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HSLColor.fromAHSL(1, hueValue, 0.9, 0.7).toColor(),
          HSLColor.fromAHSL(1, hueValue - 30, 0.8, 0.4).toColor(),
        ],
      );
    } else if (hueValue < 300) {
      // Purples
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HSLColor.fromAHSL(1, hueValue, 0.8, 0.7).toColor(),
          HSLColor.fromAHSL(1, hueValue + 20, 0.9, 0.4).toColor(),
        ],
      );
    } else {
      // Pinks and magentas
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HSLColor.fromAHSL(1, hueValue, 0.9, 0.7).toColor(),
          HSLColor.fromAHSL(1, hueValue - 30, 0.8, 0.4).toColor(),
        ],
      );
    }
  }

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
                    decoration: BoxDecoration(
                      gradient: _getBackgroundGradient(
                        controller.backgroundHue.value,
                      ),
                    ),
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
                        ? CachedNetworkImage(
                            imageUrl: controller.selectedBackground.value!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error, color: Colors.grey[400]),
                          )
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
                        if (item is StackTextItem && item.content != null) {
                          return StackTextCase(item: item, isFitted: true);
                        } else if (item is StackImageItem &&
                            item.content != null) {
                          return StackImageCase(item: item);
                        } else if (item is StackShapeItem &&
                            item.content != null) {
                          return StackShapeCase(item: item);
                        }
                        return const SizedBox.shrink();
                      },
                      // customBuilder: (StackItem<StackItemContent> item) {
                      //   return (item is StackTextItem && item.content != null)
                      //       ? StackTextCase(item: item, isFitted: true)
                      //       : (item is StackImageItem && item.content != null)
                      //       ? StackImageCase(item: item)
                      //       : const SizedBox.shrink();
                      // },
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
                          } else if (item is StackShapeItem) {
                            controller.activePanel.value =
                                PanelType.shapeEditor;
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
                      // onStatusChanged: (item, status) {
                      //   if (status == StackItemStatus.selected) {
                      //     controller.activeItem.value = controller
                      //         .boardController
                      //         .getById(item.id);
                      //     if (item is StackTextItem) {
                      //       controller.activePanel.value = PanelType.text;
                      //     } else if (item is StackImageItem) {
                      //       controller.activePanel.value =
                      //           PanelType.advancedImage;
                      //     } else {
                      //       controller.activePanel.value = PanelType.none;
                      //     }
                      //     controller.draggedItem.value = null;
                      //   } else if (status == StackItemStatus.moving) {
                      //     controller.activePanel.value = PanelType.none;
                      //     controller.draggedItem.value = item;
                      //   } else if (status == StackItemStatus.idle) {
                      //     controller.activePanel.value = PanelType.none;
                      //     if (controller.draggedItem.value?.id == item.id) {
                      //       controller.draggedItem.value = null;
                      //     }
                      //   }
                      //   controller.update(['canvas_stack', 'bottom_sheet']);
                      //   return true;
                      // },
                    ),
                  ),
                ),
              ),
            ),
            // Watermark logo
            Positioned(
              bottom: 10,
              right: 10,
              child: IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: 0.2, // Semi-transparent for watermark effect
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icon.png',
                        width: 33, // Adjust size as needed
                        height: 33,
                        fit: BoxFit.contain,
                      ),
                      Text("Inkkaro", style: TextStyle(fontSize: 11)),
                    ],
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

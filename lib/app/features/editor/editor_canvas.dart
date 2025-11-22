import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardmaker/app/features/editor/chart_editor/chart_editor_panel.dart';
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/edit_item/view.dart';
import 'package:cardmaker/app/features/editor/hue_adjustment/view.dart';
import 'package:cardmaker/app/features/editor/icon_picker/view.dart';
import 'package:cardmaker/app/features/editor/image_editor/view.dart';
import 'package:cardmaker/app/features/editor/shape_editor/controller.dart';
import 'package:cardmaker/app/features/editor/shape_editor/view.dart';
import 'package:cardmaker/app/features/editor/stickers/stickers_panel.dart';
import 'package:cardmaker/app/features/editor/text_editor/view.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/item_case/shape_stack_case.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/item_case/stack_chart_case.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/item_case/stack_icon_case.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/shack_shape_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_chart_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_icon_item.dart';
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

  // In your EditorPage, update the buildPanelContent method
  Widget buildPanelContent() {
    return GetBuilder<CanvasController>(
      id: 'bottom_sheet',
      builder: (controller) {
        final item = controller.activeItem.value;
        final activePanel = controller.activePanel.value;

        Widget currentPanel = const SizedBox.shrink();

        switch (activePanel) {
          case PanelType.shapes:
            currentPanel = ShapeEditorPanel(
              onClose: () => controller.activePanel.value = PanelType.none,

              shapeItem:
                  (controller.activeItem.value != null &&
                      (controller.activeItem.value is StackShapeItem))
                  ? controller.activeItem.value as StackShapeItem
                  : null,
            );
            break;
          case PanelType.shapeEditor when item is StackShapeItem:
            currentPanel = ShapeEditorPanel(
              shapeItem: item,
              onClose: () => controller.activePanel.value = PanelType.none,
            );
            break;
          case PanelType.color:
            currentPanel = HueAdjustmentPanel(controller: controller);
            break;
          case PanelType.text when item is StackTextItem:
            currentPanel = _TextEditorPanel(
              key: ValueKey(item.id),
              controller: controller,
              textItem: item,
            );
            break;
          case PanelType.advancedImage when item is StackImageItem:
            currentPanel = AdvancedImagePanel(
              key: ValueKey(item.id),
              imageItem: item,
            );
            break;
          case PanelType.charts:
            currentPanel = ChartEditorPanel(
              onClose: () => controller.setActiveItem(null),
              chartItem:
                  (controller.activeItem.value != null &&
                      (controller.activeItem.value is StackChartItem))
                  ? controller.activeItem.value as StackChartItem
                  : null,
            );
            break;
          case PanelType.icons:
            currentPanel = IconPickerPanel(
              onClose: () => controller.setActiveItem(null),
              iconItem:
                  (controller.activeItem.value != null &&
                      (controller.activeItem.value is StackIconItem))
                  ? controller.activeItem.value as StackIconItem
                  : null,
            );
            break;
          case PanelType.stickers:
            currentPanel = StickerPanel(controller: controller);
            break;
          default:
            currentPanel = const SizedBox.shrink();
        }

        return IgnorePointer(
          ignoring: activePanel == PanelType.none,
          child: currentPanel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chd = Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          Spacer(flex: 2),

          Obx(
            () =>
                controller.activeItem.value != null &&
                    controller.activeItem.value is StackTextItem
                ? Tooltip(
                    message: 'Edit Text',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: controller.editText,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.edit_note_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
          Spacer(),

          Obx(
            () => controller.activeItem.value == null
                ? SizedBox()
                : Tooltip(
                    message: 'Duplicate',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: controller.duplicateItem,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.control_point_duplicate,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),

          Spacer(),

          // Layer controls - Toggle button for send to back/front
          Obx(() {
            final activeItem = controller.activeItem.value;
            final canToggle = activeItem != null && !activeItem.lockZOrder;

            if (!canToggle) return SizedBox();

            return GetBuilder<CanvasController>(
              id: 'stack_board',
              builder: (ctrl) {
                final isAtFront = ctrl.isItemAtFront();

                return Tooltip(
                  message: isAtFront ? 'Send to Back' : 'Bring to Front',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: ctrl.toggleItemZOrder,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          isAtFront
                              ? Icons.flip_to_back_rounded
                              : Icons.flip_to_front_rounded,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          Spacer(),

          _ZLockToggleButton(),
          Spacer(),

          GetBuilder<CanvasController>(
            id: 'export_button',
            builder: (controller) => _ModernExportButton(
              onExportPDF: controller.exportAsPDF,
              onExportImage: () => controller.exportAsImage(
                controller.initialTemplate!.category,
              ),
              onSaveDraft: controller.saveDraft,
              onSaveCopy: controller.saveCopy,
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
          SizedBox(width: 8),
        ],
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,

        onTap: () =>
            controller.setActiveItem(null), //anywhere tap will close the panel
        child: Stack(
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
                              SchedulerBinding.instance.addPostFrameCallback((
                                _,
                              ) {
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
                                scaledCanvasHeight:
                                    controller.scaledCanvasHeight,
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
      ),
    );
    return chd;
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
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Text (First)
                Obx(() {
                  bool isActive = controller.activeItem.value is StackTextItem;
                  return _ProfessionalToolbarButton(
                    isActive: isActive,
                    icon: Icons.text_fields_outlined,
                    activeIcon: Icons.text_fields,
                    label: 'Text',
                    panelType: PanelType.text,
                    activePanel: controller.activePanel,
                    onPressed: () {
                      if (isActive) {
                        controller.editText();
                      } else {
                        //shape or chart is selected but user has pressed text
                        controller.setActiveItem(null);

                        Get.to(() => UpdateTextView());
                      }

                      controller.update(['bottom_sheet']);
                    },
                  );
                }),
                // 2. Shapes (Second)
                Obx(() {
                  bool isShapeActive =
                      controller.activeItem.value is StackShapeItem ||
                      controller.activePanel.value == PanelType.shapes;

                  return _ProfessionalToolbarButton(
                    isActive: isShapeActive,
                    icon: Icons.shape_line_outlined,
                    activeIcon: Icons.shape_line,
                    label: controller.activeItem.value is StackShapeItem
                        ? 'Edit'
                        : 'Shapes',
                    panelType: PanelType.shapes,
                    activePanel: controller.activePanel,
                    onPressed: () {
                      if (controller.activePanel.value == PanelType.shapes) {
                        controller.activePanel.value = PanelType.none;
                      } else {
                        controller.activePanel.value = PanelType.shapes;
                      }
                      controller.update(['bottom_sheet']);
                    },
                  );
                }),
                // 3. Icons
                Obx(() {
                  bool isIconActive =
                      controller.activeItem.value is StackIconItem ||
                      controller.activePanel.value == PanelType.icons;

                  return _ProfessionalToolbarButton(
                    isActive: isIconActive,
                    icon: Icons.emoji_objects_outlined,
                    activeIcon: Icons.emoji_objects,
                    label: controller.activeItem.value is StackIconItem
                        ? 'Edit'
                        : 'Icons',
                    panelType: PanelType.icons,
                    activePanel: controller.activePanel,
                    onPressed: () {
                      if (controller.activePanel.value == PanelType.icons) {
                        controller.activePanel.value = PanelType.none;
                      } else {
                        controller.activePanel.value = PanelType.icons;
                      }
                      controller.update(['bottom_sheet']);
                    },
                  );
                }),
                // 4. Charts
                Obx(() {
                  bool isChartActive =
                      controller.activeItem.value is StackChartItem ||
                      controller.activePanel.value == PanelType.charts;

                  return _ProfessionalToolbarButton(
                    isActive: isChartActive,
                    icon: Icons.bar_chart_rounded,
                    activeIcon: Icons.bar_chart_rounded,
                    label: controller.activeItem.value is StackChartItem
                        ? 'Edit'
                        : 'Charts',
                    panelType: PanelType.charts,
                    activePanel: controller.activePanel,
                    onPressed: () {
                      if (controller.activePanel.value == PanelType.charts) {
                        controller.activePanel.value = PanelType.none;
                      } else {
                        controller.activePanel.value = PanelType.charts;
                      }
                      controller.update(['bottom_sheet']);
                    },
                  );
                }),
                // 5. Background
                Obx(() {
                  bool isBackgroundActive =
                      controller.activePanel.value == PanelType.color;
                  return _ProfessionalToolbarButton(
                    isActive: isBackgroundActive,
                    icon: Icons.format_color_fill_outlined,
                    activeIcon: Icons.format_color_fill,
                    label: 'Background',
                    panelType: PanelType.color,
                    activePanel: controller.activePanel,
                    onPressed: () {
                      controller.activePanel.value =
                          controller.activePanel.value == PanelType.color
                          ? PanelType.none
                          : PanelType.color;
                      controller.update(['bottom_sheet']);
                    },
                  );
                }),
                // 6. Image
                Obx(() {
                  bool isImageActive =
                      controller.activeItem.value is StackImageItem ||
                      controller.activePanel.value == PanelType.advancedImage;
                  return _ProfessionalToolbarButton(
                    isActive: isImageActive,
                    icon: Icons.photo_filter_outlined,
                    activeIcon: Icons.photo_filter,
                    label: controller.activeItem.value is StackImageItem
                        ? 'Edit'
                        : 'Image',
                    panelType: PanelType.advancedImage,
                    activePanel: controller.activePanel,
                    onPressed: () {
                      if (controller.activeItem.value != null &&
                          controller.activeItem.value is StackImageItem) {
                        controller.activePanel.value = PanelType.advancedImage;
                      } else {
                        _showImageOptions(context);
                      }
                      controller.update(['bottom_sheet']);
                    },
                  );
                }),
                // 7. Stickers (Last)
                _ProfessionalToolbarButton(
                  isActive: controller.activePanel.value == PanelType.stickers,
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
              ],
            ),
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
                label: "Add img as placeholder",
                onTap: () {
                  Navigator.pop(context);
                  controller.pickAndAddImage(isPlaceholder: true);
                },
              ),

              if (controller.isOwner)
                _ActionButton(
                  icon: Icons.add_photo_alternate_outlined,
                  label: "Add Image to Canvas",
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickAndAddImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// Replace the existing _ProfessionalToolbarButton class with this enhanced version
class _ProfessionalToolbarButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final PanelType panelType;
  final Rx<PanelType> activePanel;
  final VoidCallback onPressed;
  final bool isActive;

  const _ProfessionalToolbarButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.panelType,
    required this.activePanel,
    required this.onPressed,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.all(6),
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
  }
}

class _ModernExportButton extends StatelessWidget {
  final VoidCallback onExportPDF;
  final VoidCallback onSaveDraft;
  final VoidCallback onSaveCopy;

  final VoidCallback onExportImage;
  final VoidCallback onSave;
  final bool isExporting;

  const _ModernExportButton({
    required this.onExportPDF,
    required this.onExportImage,
    required this.onSave,
    required this.isExporting,
    required this.onSaveDraft,
    required this.onSaveCopy,
  });

  Widget _buildVerticalMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  letterSpacing: 0,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CanvasController>(
      id: "export_button",
      builder: (controller) => PopupMenuButton<String>(
        offset: Offset(0, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        enabled: !isExporting,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        itemBuilder: (context) => [
          if (controller.isOwner)
            PopupMenuItem<String>(
              value: 'save',
              height: 52,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _buildVerticalMenuItem(
                icon: Icons.save_rounded,
                title: 'Save Project',
                subtitle: 'Save current design',
                iconColor: AppColors.accent,
                bgColor: AppColors.accent.withOpacity(0.1),
              ),
            ),
          if (controller.isOwner) PopupMenuDivider(height: 6),
          PopupMenuItem<String>(
            value: 'pdf',
            height: 52,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: _buildVerticalMenuItem(
              icon: Icons.picture_as_pdf_rounded,
              title: 'Export as PDF',
              subtitle: 'High-quality PDF format',
              iconColor: Colors.red.shade700,
              bgColor: Colors.red.shade50,
            ),
          ),
          PopupMenuItem<String>(
            value: 'image',
            height: 52,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: _buildVerticalMenuItem(
              icon: Icons.image_rounded,
              title: 'Export as Image',
              subtitle: 'PNG format for sharing',
              iconColor: Colors.purple.shade700,
              bgColor: Colors.purple.shade50,
            ),
          ),
          PopupMenuDivider(height: 6),
          PopupMenuItem<String>(
            value: 'draft',
            height: 52,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: _buildVerticalMenuItem(
              icon: Icons.drafts_rounded,
              title: 'Save Draft',
              subtitle: 'Save as draft for later',
              iconColor: Colors.orange.shade700,
              bgColor: Colors.orange.shade50,
            ),
          ),
          if (controller.showSaveCopyBtn)
            PopupMenuItem<String>(
              value: 'draft_copy',
              height: 52,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _buildVerticalMenuItem(
                icon: Icons.copy_rounded,
                title: 'Save Copy',
                subtitle: 'Duplicate as new project',
                iconColor: Colors.blue.shade700,
                bgColor: Colors.blue.shade50,
              ),
            ),
        ],
        onSelected: (value) {
          switch (value) {
            case 'save':
              onSave();
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
            case 'draft_copy':
              onSaveCopy();
              break;
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),

          decoration: BoxDecoration(
            color: AppColors.branding,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.branding),
          ),
          child: Text(
            "Download",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      // clipBehavior: Clip.none,

      // alignment: Alignment.topRight,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Get.theme.colorScheme.surfaceContainer,
          child: Row(
            children: [
              Text(
                'Text Editor',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    controller.setActiveItem(null);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            // Background container with hue color or solid color when no background image
            if (controller.selectedBackground.value == null)
              IgnorePointer(
                ignoring: true,
                child: SizedBox(
                  width: scaledCanvasWidth.value,
                  height: scaledCanvasHeight.value,
                  child: Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        gradient: controller.isBackgroundGradient.value
                            ? _getBackgroundGradient(
                                controller.backgroundHue.value,
                              )
                            : null,
                        color: controller.isBackgroundGradient.value
                            ? null
                            : controller.backgroundColor.value,
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

                          if (controller.activeItem.value is StackShapeItem) {
                            Get.find<ShapeEditorController>().currentShapeItem =
                                null;
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: StackTextCase(
                              item: item,
                              isFitted: item.content!.data!.length > 20
                                  ? false
                                  : true,
                            ),
                          );
                        } else if (item is StackImageItem &&
                            item.content != null) {
                          return InkWell(
                            onTap: () async {
                              // controller.boardController.updateItem(oldItem);
                              controller.replaceImageItem(item);
                            },

                            child: StackImageCase(item: item),
                          );
                        } else if (item is StackShapeItem &&
                            item.content != null) {
                          return InkWell(
                            onTap: () {
                              controller.activeItem.value = item;
                              controller.boardController.setAllItemStatuses(
                                StackItemStatus.idle,
                              );
                              controller.boardController.setItemStatus(
                                item.id,
                                StackItemStatus.selected,
                              );
                              controller.activePanel.value =
                                  PanelType.shapeEditor;
                            },

                            child: StackShapeCase(item: item),
                          );
                        } else if (item is StackChartItem &&
                            item.content != null) {
                          return GestureDetector(
                            onTap: () {
                              controller.activeItem.value = item;
                              controller.boardController.setAllItemStatuses(
                                StackItemStatus.idle,
                              );
                              controller.boardController.setItemStatus(
                                item.id,
                                StackItemStatus.selected,
                              );
                              controller.activePanel.value = PanelType.charts;
                            },

                            child: StackChartCase(item: item),
                          );
                        } else if (item is StackIconItem &&
                            item.content != null) {
                          return GestureDetector(
                            onTap: () {
                              controller.activeItem.value = item;
                              controller.boardController.setAllItemStatuses(
                                StackItemStatus.idle,
                              );
                              controller.boardController.setItemStatus(
                                item.id,
                                StackItemStatus.selected,
                              );
                              controller.activePanel.value = PanelType.icons;
                            },

                            child: StackIconCase(item: item),
                          );
                        }
                        return const SizedBox.shrink();
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
                        print(item.status);
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
                            // controller.activePanel.value =
                            //     PanelType.shapeEditor;
                          } else if (item is StackChartItem) {
                            // controller.activePanel.value =
                            //     PanelType.chartEditor;
                          } else if (item is StackShapeItem) {
                            // controller.activePanel.value =
                            //     PanelType.chartEditor;
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
                        'assets/water_mark.png',
                        width: 33, // Adjust size as needed
                        height: 33,
                        fit: BoxFit.contain,
                      ),
                      Text("Inkkaro", style: TextStyle(fontSize: 8)),
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
  final bool isLocked; // Add this
  final double stroke = 0.2;
  final double dash = 2;
  final double dash2 = 2;

  const BorderPainter({
    required this.dotted,
    this.isLocked = false, // Add this
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Get.find<CanvasController>().draggedItem.value == null
          ? Get.theme.colorScheme.secondary.withOpacity(
              0.5,
            ) // More subtle color
          : Get.theme.colorScheme.secondary.withOpacity(0.7)
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

// Add this widget class at the bottom of your file:
class _ZLockToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<CanvasController>();
      final activeItem = controller.activeItem.value;
      final isLocked = activeItem?.lockZOrder == true;
      final hasActiveItem = activeItem != null;

      print(
        '🔍 ZLockButton rebuild - hasActiveItem: $hasActiveItem, isLocked: $isLocked, itemId: ${activeItem?.id}',
      );

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: hasActiveItem
            ? Tooltip(
                message: isLocked
                    ? 'Unlock from background'
                    : 'Lock to background',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      print(
                        '👆 ZLock button tapped for item: ${activeItem.id}',
                      );
                      controller.toggleZLock(activeItem.id);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.orange.withOpacity(0.1)
                            : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLocked
                              ? Colors.orange.withOpacity(0.3)
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isLocked ? Icons.lock : Icons.lock_open,
                        size: 20,
                        color: isLocked
                            ? Colors.orange.shade700
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(width: 48),
      );
    });
  }
}

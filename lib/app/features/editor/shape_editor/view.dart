import 'package:cardmaker/app/features/editor/shape_editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:cardmaker/widgets/common/quick_color_picker.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/shack_shape_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:morphable_shape/morphable_shape.dart';

class ShapeEditorPanel extends StatelessWidget {
  final StackShapeItem? shapeItem;
  final VoidCallback onClose;

  const ShapeEditorPanel({super.key, this.shapeItem, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final ShapeEditorController controller = Get.find<ShapeEditorController>();

    // Initialize controller if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shapeItem != null && controller.currentShapeItem != shapeItem) {
        controller.initProperties(shapeItem!);
      } else {
        controller.currentShapeItem = shapeItem;
        // if (controller.canvasController.activeItem.value is StackShapeItem) {
        //   controller.currentShapeItem =
        //       controller.canvasController.activeItem.value as StackShapeItem;
        // }
      }
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
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
                    controller.canvasController.activePanel.value =
                        PanelType.none;
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
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEnhancedTabBar(controller),
                Expanded(
                  child: GetBuilder<ShapeEditorController>(
                    id: 'tab_view',
                    builder: (controller) {
                      return TabBarView(
                        controller: controller.tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildTemplatesTab(controller),
                          _buildCustomizeTab(controller),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTabBar(ShapeEditorController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          // borderRadius: BorderRadius.circular(25),
        ),
        height: 36,
        child: GetBuilder<ShapeEditorController>(
          id: 'tab_bar',
          builder: (controller) {
            return TabBar(
              controller: controller.tabController,
              indicatorSize: TabBarIndicatorSize.label,

              dividerHeight: 0,
              onTap: (index) {
                controller.updateCurrentTab(index);
              },
              // indicator: BoxDecoration(
              //   color: Get.theme.colorScheme.surface,
              //   borderRadius: BorderRadius.only(
              //     topLeft: Radius.circular(25),

              //     topRight: Radius.circular(25),
              //   ),
              // ),
              tabs: [
                _buildProfessionalTab('Templates', 0, Icons.grid_view_rounded),
                _buildProfessionalTab('Customize', 1, Icons.tune_rounded),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfessionalTab(String text, int index, IconData icon) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 14), const SizedBox(width: 4), Text(text)],
      ),
    );
  }

  Widget _buildTemplatesTab(ShapeEditorController controller) {
    return GetBuilder<ShapeEditorController>(
      id: 'templates',
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: controller.professionalTemplates.length,
            itemBuilder: (context, index) {
              return _buildProfessionalTemplateCard(
                controller.professionalTemplates[index],
                controller,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfessionalTemplateCard(
    ShapeTemplate template,
    ShapeEditorController controller,
  ) {
    return GestureDetector(
      onTap: () {
        final shape = template.shape;

        switch (template.type) {
          case 'rectangle':
            final rect = shape as RectangleShapeBorder;
            controller.cornerRadius.value = rect.borderRadius.topLeft.x.toPX();
            controller.cornerStyle.value = rect.cornerStyles.topLeft;
            break;
          case 'polygon':
            final poly = shape as PolygonShapeBorder;
            controller.polygonSides.value = poly.sides;
            controller.cornerRadius.value = poly.cornerRadius.toPX();
            break;
          case 'star':
            final star = shape as StarShapeBorder;
            controller.starPoints.value = star.corners;
            controller.starInset.value = star.inset.toPX();
            break;
          case 'arrow':
            final arrow = shape as ArrowShapeBorder;
            controller.arrowDirection.value = arrow.side;
            controller.arrowHeight.value = arrow.arrowHeight.toPX();
            controller.arrowTailWidth.value = arrow.tailWidth.toPX();
            break;
          case 'bubble':
            final bubble = shape as BubbleShapeBorder;
            controller.bubbleSide.value = bubble.side;
            controller.bubbleArrowHeight.value = bubble.arrowHeight.toPX();
            controller.bubbleArrowWidth.value = bubble.arrowWidth.toPX();
            controller.bubbleCornerRadius.value = bubble.borderRadius.toPX();
            break;
          case 'arc':
            final arc = shape as ArcShapeBorder;
            controller.arcSide.value = arc.side;
            controller.arcHeight.value = arc.arcHeight.toPX();
            controller.arcIsOutward.value = arc.isOutward;
            break;
          case 'trapezoid':
            final trap = shape as TrapezoidShapeBorder;
            controller.trapezoidSide.value = trap.side;
            controller.trapezoidInset.value = trap.inset.toPX();
            break;
          default:
            controller.cornerRadius.value = 20.0;
            controller.cornerStyle.value = CornerStyle.rounded;
        }

        controller.applyTemplate(template);
        print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
        controller.tabController.animateTo(1);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: ShapeDecoration(
              shape: template.shape,
              color: AppColors.branding.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomizeTab(ShapeEditorController controller) {
    return GetBuilder<ShapeEditorController>(
      id: 'customize',
      builder: (controller) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppearanceSection(controller),
              _buildBorderSection(controller),
              _buildShapeSpecificSection(controller),
              _buildEffectsSection(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppearanceSection(ShapeEditorController controller) {
    return _buildProfessionalSection(
      title: 'Fill & Appearance',
      icon: Icons.palette_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildColorPickerRow(
                'Fill Color',
                controller.fillColor.value,
                controller.updateFillColor,
                Icons.format_color_fill,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: CompactSlider(
                icon: Icons.opacity,
                label: 'Opacity',
                value: controller.fillOpacity.value,
                min: 0,
                max: 1,
                onChanged: controller.updateFillOpacity,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBorderSection(ShapeEditorController controller) {
    return _buildProfessionalSection(
      title: 'Border & Stroke',
      icon: Icons.border_all_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: CompactSlider(
                icon: Icons.line_weight,
                label: 'Width',
                value: controller.borderWidth.value,
                min: 0,
                max: 20,
                onChanged: controller.updateBorderWidth,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorPickerRow(
                'Border Color',
                controller.borderColor.value,
                controller.updateBorderColor,
                Icons.border_color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEffectsSection(ShapeEditorController controller) {
    return _buildProfessionalSection(
      title: 'Effects & Shadows',
      icon: Icons.auto_awesome_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: CompactSlider(
                icon: Icons.blur_on,
                label: 'Blur',
                value: controller.shadowBlur.value,
                min: 0,
                max: 50,
                onChanged: controller.updateShadowBlur,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CompactSlider(
                icon: Icons.opacity,
                label: 'Opacity',
                value: controller.shadowOpacity.value,
                min: 0,
                max: 1,
                onChanged: controller.updateShadowOpacity,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildColorPickerRow(
          'Shadow Color',
          controller.shadowColor.value,
          controller.updateShadowColor,
          Icons.gradient,
        ),
      ],
    );
  }

  Widget _buildShapeSpecificSection(ShapeEditorController controller) {
    return GetBuilder<ShapeEditorController>(
      id: 'shape_specific',
      builder: (controller) {
        final shapeControls = controller.getShapeSpecificControls();

        if (shapeControls.isEmpty ||
            (shapeControls.first is SizedBox && shapeControls.length == 1)) {
          return const SizedBox.shrink();
        }

        return _buildProfessionalSection(
          title: 'Shape Properties',
          icon: Icons.settings_outlined,
          children: shapeControls,
        );
      },
    );
  }

  Widget _buildProfessionalSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.branding.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 12, color: AppColors.branding),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildColorPickerRow(
    String label,
    Color color,
    Function(Color) onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showColorPicker(color, onChanged, label),
          child: Container(
            width: 24,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(
    Color currentColor,
    Function(Color) onChanged,
    String title,
  ) {
    showModalBottomSheet(
      context: Get.context!,
      // backgroundColor: Get.theme.colorScheme.surface,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      builder: (context) => QuickColorPicker(
        title: title,
        currentColor: currentColor,
        onChanged: (color) => onChanged(color!),
      ),
    );
  }
}

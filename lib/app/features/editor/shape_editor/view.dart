import 'package:cardmaker/app/features/editor/shape_editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:cardmaker/widgets/common/quick_color_picker.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShapeEditorPanel extends StatefulWidget {
  final StackShapeItem? shapeItem;
  final VoidCallback onClose;

  const ShapeEditorPanel({super.key, this.shapeItem, required this.onClose});

  @override
  State<ShapeEditorPanel> createState() => _ShapeEditorPanelState();
}

class _ShapeEditorPanelState extends State<ShapeEditorPanel> {
  final ShapeEditorController _controller = Get.put(ShapeEditorController());
  final _pageController = PageController();
  final _currentTab = 0.obs; // 0: Templates, 1: Customize
  Offset _offset = const Offset(20, 20);
  final Size _panelSize = const Size(400, 460);

  @override
  void initState() {
    super.initState();
    if (widget.shapeItem != null) {
      _controller.initializeProperties(widget.shapeItem!);
    } else {
      _controller.currentShapeItem = null;
    }
  }

  void _updatePosition(Offset newOffset, BoxConstraints constraints) {
    setState(() {
      _offset = Offset(
        newOffset.dx.clamp(0, constraints.maxWidth - _panelSize.width),
        newOffset.dy.clamp(0, constraints.maxHeight - _panelSize.height),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Positioned(
          left: _offset.dx,
          top: _offset.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              _updatePosition(_offset + details.delta, constraints);
            },
            child: Material(
              elevation: 16,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: _panelSize.width,
                height: _panelSize.height,
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfessionalHeader(),
                    _buildEnhancedTabBar(),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [_buildTemplatesTab(), _buildCustomizeTab()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.branding.withOpacity(0.05), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.branding,
                  AppColors.branding.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.branding.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_mosaic,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Shape Editor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Professional Design Tools',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: Colors.grey.shade700,
              ),
              onPressed: widget.onClose,
              tooltip: 'Close Editor',
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTabBar() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildProfessionalTab(
                  'Templates',
                  0,
                  Icons.grid_view_rounded,
                ),
              ),
              Expanded(
                child: _buildProfessionalTab(
                  'Customize',
                  1,
                  Icons.tune_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalTab(String text, int index, IconData icon) {
    final isActive = _currentTab.value == index;

    return GestureDetector(
      onTap: () {
        _currentTab.value = index;
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.branding : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  color: isActive ? AppColors.branding : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    // Group templates by category
    final Map<String, List<ShapeTemplate>> groupedTemplates = {};
    for (final template in _controller.professionalTemplates) {
      groupedTemplates.putIfAbsent(template.category, () => []).add(template);
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Shape Library',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.branding.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_controller.professionalTemplates.length} shapes',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.branding,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: groupedTemplates.entries.map((entry) {
                return _buildCategorySection(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ShapeTemplate> templates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            return _buildProfessionalTemplateCard(templates[index]);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProfessionalTemplateCard(ShapeTemplate template) {
    return GestureDetector(
      onTap: () {
        _controller.applyTemplate(template);
        _currentTab.value = 1;
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );

        // Haptic feedback
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: ShapeDecoration(
                shape: template.shape,
                color: AppColors.branding.withOpacity(0.8),
                shadows: [
                  BoxShadow(
                    color: AppColors.branding.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              template.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                letterSpacing: -0.1,
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

  Widget _buildCustomizeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GetBuilder<ShapeEditorController>(
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickActions(controller),
              const SizedBox(height: 20),
              _buildProfessionalSection(
                title: 'Fill & Appearance',
                icon: Icons.palette_outlined,
                children: [
                  _buildColorPickerRow(
                    'Fill Color',
                    controller.fillColor.value,
                    controller.updateFillColor,
                    Icons.format_color_fill,
                  ),
                  const SizedBox(height: 16),
                  CompactSlider(
                    icon: Icons.opacity,
                    label: 'Fill Opacity',
                    value: controller.fillOpacity.value,
                    min: 0,
                    max: 1,
                    onChanged: controller.updateFillOpacity,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProfessionalSection(
                title: 'Border & Stroke',
                icon: Icons.border_all_outlined,
                children: [
                  CompactSlider(
                    icon: Icons.line_weight,
                    label: 'Border Width',
                    value: controller.borderWidth.value,
                    min: 0,
                    max: 20,
                    onChanged: controller.updateBorderWidth,
                  ),
                  const SizedBox(height: 16),
                  _buildColorPickerRow(
                    'Border Color',
                    controller.borderColor.value,
                    controller.updateBorderColor,
                    Icons.border_color,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildShapeSpecificSection(controller),
              const SizedBox(height: 16),
              _buildProfessionalSection(
                title: 'Effects & Shadows',
                icon: Icons.auto_awesome_outlined,
                children: [
                  CompactSlider(
                    icon: Icons.blur_on,
                    label: 'Shadow Blur',
                    value: controller.shadowBlur.value,
                    min: 0,
                    max: 50,
                    onChanged: controller.updateShadowBlur,
                  ),
                  const SizedBox(height: 16),
                  CompactSlider(
                    icon: Icons.opacity,
                    label: 'Shadow Opacity',
                    value: controller.shadowOpacity.value,
                    min: 0,
                    max: 1,
                    onChanged: controller.updateShadowOpacity,
                  ),
                  const SizedBox(height: 16),
                  _buildColorPickerRow(
                    'Shadow Color',
                    controller.shadowColor.value,
                    controller.updateShadowColor,
                    Icons.gradient,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildEnhancedActionButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(ShapeEditorController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.branding.withOpacity(0.05),
            AppColors.branding.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.branding.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.flash_on, color: AppColors.branding, size: 16),
          const SizedBox(width: 8),
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.branding,
            ),
          ),
          const Spacer(),
          _buildQuickActionButton('Reset', Icons.refresh_rounded, () {}),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeSpecificSection(ShapeEditorController controller) {
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
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.branding.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: AppColors.branding),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
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
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _showColorPicker(color, onChanged, label),
          child: Container(
            width: 32,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onClose,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_controller.currentShapeItem != null) {
                // Apply changes and close
                widget.onClose();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.branding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Apply',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
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
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
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

// Professional Tune Button Widget for Canvas Items
class ShapeTuneButton extends StatelessWidget {
  final StackShapeItem shapeItem;
  final VoidCallback onTune;

  const ShapeTuneButton({
    super.key,
    required this.shapeItem,
    required this.onTune,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -12,
      right: -12,
      child: GestureDetector(
        onTap: onTune,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.branding, AppColors.branding.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.branding.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.tune_rounded, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

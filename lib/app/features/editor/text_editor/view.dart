import 'package:cardmaker/app/features/editor/text_editor/controller.dart';
import 'package:cardmaker/app/features/editor/text_editor/font_management/view.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/services/urdu_font_service.dart';
import 'package:cardmaker/widgets/common/colors_selector.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:cardmaker/widgets/ruler_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'fonts_search/view.dart';
import 'urdu_font_search/view.dart';

class TextStylingEditor extends StatefulWidget {
  final StackTextItem textItem;
  final VoidCallback onClose;

  const TextStylingEditor({
    super.key,
    required this.textItem,
    required this.onClose,
  });

  @override
  State<TextStylingEditor> createState() => _TextStylingEditorState();
}

class _TextStylingEditorState extends State<TextStylingEditor>
    with TickerProviderStateMixin {
  late final TabController _circularSubTabController;
  final TextStyleController _controller = Get.put(TextStyleController());

  @override
  void dispose() {
    _circularSubTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Get.theme.colorScheme.surface),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildTabBar(), _buildTabView()],
      ),
    );
  }

  // Update the tab controller length and tabs
  @override
  void initState() {
    super.initState();
    _controller.initializeProperties(widget.textItem);

    _circularSubTabController = TabController(length: 8, vsync: this);
    _circularSubTabController.addListener(() {
      _controller.circularSubTabIndex.value = _circularSubTabController.index;
    });
  }

  // Updated tab bar with Format tab
  Widget _buildTabBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.branding, width: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _controller.tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicator: const BoxDecoration(),
              dividerHeight: 0,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              padding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.format_size, size: 16), text: 'Size'),
                Tab(
                  icon: Icon(Icons.text_fields, size: 16),
                  text: 'Format',
                ), // New Format tab
                Tab(icon: Icon(Icons.palette, size: 16), text: 'Color'),
                Tab(icon: Icon(Icons.format_color_fill, size: 16), text: 'BG'),
                Tab(icon: Icon(Icons.font_download, size: 16), text: 'Font'),
                Tab(icon: Icon(Icons.language, size: 16), text: 'Urdu'),
                Tab(icon: Icon(Icons.gradient, size: 16), text: 'Effects'),

                Tab(icon: Icon(Icons.image, size: 16), text: 'Mask'),
                Tab(icon: Icon(Icons.gradient, size: 16), text: 'Dual'),

                Tab(icon: Icon(Icons.circle, size: 16), text: 'Circular'),
                // Consolidated tab
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return GetBuilder<TextStyleController>(
      id: 'tab_view',
      builder: (controller) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            height: _getTabHeight(controller.currentIndex.value),
            child: SafeArea(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller.tabController,
                children: [
                  _SizeTab(controller: controller),
                  _FormatTab(controller: controller), // New Format tab
                  _ColorTab(controller: controller),
                  _BackgroundTab(controller: controller),
                  _FontTab(controller: controller),
                  _UrduFontTab(controller: controller),
                  _EffectsTab(controller: controller), // Consolidated effects

                  _MaskTab(controller: controller),

                  _DualToneTuneTab(controller: controller),
                  _CircularTab(
                    controller: controller,
                    tabController: _circularSubTabController,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Update tab heights
  double _getTabHeight(int index) {
    switch (index) {
      case 0: // size
        return 100; // Professional ruler height
      case 1: // format (new)
        return 280; // Increased height for comprehensive controls
      case 2: // color
        return 80;
      case 3: // bg
        return 80;
      case 4: // font
        return 250;
      case 5: // urdu font
        return 300; // Height for Urdu font tab
      case 6: // effect (consolidated)
        return 120;
      case 7: // mask
        return 80;
      case 8: // dual
        return 120;
      default:
        return 250;
    }
  }
}

// SIZE TAB - Modern with compact design
class _SizeTab extends StatelessWidget {
  final TextStyleController controller;
  const _SizeTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GetBuilder<TextStyleController>(
        id: 'font_size',
        builder: (controller) {
          return RulerSlider(
            rulerHeight: 80.0,
            minValue: 8.0,
            maxValue: 72.0,
            initialValue: controller.fontSize.value,
            selectedBarColor: Theme.of(context).colorScheme.primary,
            unselectedBarColor: Theme.of(
              context,
            ).colorScheme.outline.withOpacity(0.3),
            fixedBarColor: Theme.of(context).colorScheme.primary,
            fixedLabelColor: Theme.of(context).colorScheme.primary,
            labelBuilder: (value) => '${value.round()}px',
            onChanged: (value) {
              controller.fontSize.value = value;
              controller.updateTextItem();
              controller.update(['font_size']);
            },
            majorTickHeight: 12.0,
            minorTickHeight: 6.0,
            majorTickInterval: 10,
            labelInterval: 10,
          );
        },
      ),
    );
  }
}

// ALIGNMENT TAB - Compact grid layout
class _AlignmentTab extends StatelessWidget {
  final TextStyleController controller;
  const _AlignmentTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TextStyleController>(
      id: 'text_align',
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAlignmentButton(
                icon: Icons.format_align_left_rounded,
                alignment: TextAlign.left,
                isSelected: controller.textAlign.value == TextAlign.left,
                controller: controller,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_center_rounded,
                alignment: TextAlign.center,
                isSelected: controller.textAlign.value == TextAlign.center,
                controller: controller,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_right_rounded,
                alignment: TextAlign.right,
                isSelected: controller.textAlign.value == TextAlign.right,
                controller: controller,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_justify_rounded,
                alignment: TextAlign.justify,
                isSelected: controller.textAlign.value == TextAlign.justify,
                controller: controller,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlignmentButton({
    required IconData icon,
    required TextAlign alignment,
    required bool isSelected,
    required TextStyleController controller,
  }) {
    return GestureDetector(
      onTap: () {
        controller.textAlign.value = alignment;
        controller.updateTextItem();
        controller.update(['text_align']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.branding : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: isSelected
                ? AppColors.branding
                : AppColors.highlight.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          size: 20.0,
          color: isSelected ? Colors.white : AppColors.highlight,
        ),
      ),
    );
  }
}

// FORMAT TAB - Consolidated text formatting options
// EFFECTS TAB - Professional Design
class _EffectsTab extends StatelessWidget {
  static const List<EffectTemplate> effectTemplates = [
    EffectTemplate(
      id: 'none',
      name: 'None',
      icon: Icons.format_clear,
      hasShadow: false,
      hasStroke: false,
      fontSize: 16.0,
    ),
    EffectTemplate(
      id: 'basic_stroke',
      name: 'Classic',
      icon: Icons.border_color,
      hasShadow: true,
      hasStroke: true,
      strokeWidth: 2.0,
      strokeColor: Colors.black,
      textColor: Colors.white,
      fontSize: 22.0,
      shadowOffset: Offset(2, 2),
      shadowBlur: 4.0,
      shadowColor: Colors.black54,
    ),
    EffectTemplate(
      id: 'thick_stroke',
      name: 'Bold',
      icon: Icons.format_paint,
      hasShadow: false,
      hasStroke: true,
      strokeWidth: 4.0,
      strokeColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 20.0,
    ),
    EffectTemplate(
      id: 'colored_stroke',
      name: 'Vibrant',
      icon: Icons.palette,
      hasShadow: false,
      hasStroke: true,
      strokeWidth: 3.0,
      strokeColor: Color(0xFFFF5722),
      textColor: Colors.white,
      fontSize: 20.0,
    ),
    EffectTemplate(
      id: 'neon_stroke',
      name: 'Neon',
      icon: Icons.flash_on,
      hasShadow: true,
      shadowOffset: Offset(0, 0),
      shadowBlur: 12.0,
      shadowColor: Color(0xFF00E676),
      hasStroke: true,
      strokeWidth: 1.5,
      strokeColor: Color(0xFF00E676),
      textColor: Color(0xFF0D47A1),
      fontSize: 24.0,
    ),
    EffectTemplate(
      id: 'glow_blue',
      name: 'Glow Blue',
      icon: Icons.auto_awesome,
      hasShadow: true,
      shadowOffset: Offset(0, 0),
      shadowBlur: 15.0,
      shadowColor: Color(0xFF2196F3),
      hasStroke: false,
      textColor: Color(0xFF2196F3),
      fontSize: 22.0,
    ),
    EffectTemplate(
      id: 'glow_pink',
      name: 'Glow Pink',
      icon: Icons.auto_awesome,
      hasShadow: true,
      shadowOffset: Offset(0, 0),
      shadowBlur: 15.0,
      shadowColor: Color(0xFFE91E63),
      hasStroke: false,
      textColor: Color(0xFFE91E63),
      fontSize: 22.0,
    ),
    EffectTemplate(
      id: 'glow_gold',
      name: 'Glow Gold',
      icon: Icons.auto_awesome,
      hasShadow: true,
      shadowOffset: Offset(0, 0),
      shadowBlur: 18.0,
      shadowColor: Color(0xFFFFD700),
      hasStroke: false,
      textColor: Color(0xFFFFD700),
      fontSize: 22.0,
    ),
    EffectTemplate(
      id: 'soft_shadow',
      name: 'Soft',
      icon: Icons.blur_on,
      hasShadow: true,
      shadowOffset: Offset(0, 4),
      shadowBlur: 8.0,
      shadowColor: Colors.black26,
      hasStroke: false,
      textColor: Colors.black87,
      fontSize: 20.0,
    ),
    EffectTemplate(
      id: 'deep_shadow',
      name: 'Deep',
      icon: Icons.layers,
      hasShadow: true,
      shadowOffset: Offset(3, 3),
      shadowBlur: 6.0,
      shadowColor: Colors.black87,
      hasStroke: false,
      textColor: Colors.white,
      fontSize: 20.0,
    ),
    EffectTemplate(
      id: 'outline_white',
      name: 'Outline',
      icon: Icons.border_outer,
      hasShadow: false,
      hasStroke: true,
      strokeWidth: 2.5,
      strokeColor: Colors.white,
      textColor: Color(0xFF1976D2),
      fontSize: 20.0,
    ),
    EffectTemplate(
      id: 'double_stroke',
      name: 'Double',
      icon: Icons.border_all,
      hasShadow: true,
      shadowOffset: Offset(2, 2),
      shadowBlur: 3.0,
      shadowColor: Colors.black45,
      hasStroke: true,
      strokeWidth: 3.5,
      strokeColor: Colors.black,
      textColor: Colors.white,
      fontSize: 20.0,
    ),
    EffectTemplate(
      id: 'metallic',
      name: 'Metallic',
      icon: Icons.diamond,
      hasShadow: true,
      shadowOffset: Offset(2, 2),
      shadowBlur: 8.0,
      shadowColor: Color(0xFF424242),
      hasStroke: true,
      strokeWidth: 1.5,
      strokeColor: Color(0xFF757575),
      textColor: Color(0xFFBDBDBD),
      fontSize: 22.0,
    ),
    EffectTemplate(
      id: 'elegant',
      name: 'Elegant',
      icon: Icons.star,
      hasShadow: true,
      shadowOffset: Offset(0, 2),
      shadowBlur: 6.0,
      shadowColor: Colors.black38,
      hasStroke: true,
      strokeWidth: 1.0,
      strokeColor: Colors.black26,
      textColor: Colors.white,
      fontSize: 20.0,
    ),
  ];

  final TextStyleController controller;
  const _EffectsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildPresetCards()]);
  }

  Widget _buildPresetCards() {
    return Expanded(
      child: GetBuilder<TextStyleController>(
        id: 'effect_templates',
        builder: (controller) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: effectTemplates.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final template = effectTemplates[index];
              final isSelected = _isTemplateSelected(controller, template);

              return _buildTemplateCard(
                template: template,
                isSelected: isSelected,
                onTap: () => _applyTemplate(template),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard({
    required EffectTemplate template,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isNoneTemplate = template.id == 'none';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 88,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.branding.withOpacity(0.12)
              : Get.theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.branding
                : Get.theme.colorScheme.outline.withOpacity(0.15),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.branding.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Preview Container with better styling
            Stack(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Get.theme.colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: isNoneTemplate
                        ? Text(
                            "Aa",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color:
                                  controller.textColorOld ??
                                  Get.theme.colorScheme.onSurface,
                            ),
                          )
                        : (template.hasShadow && !template.hasStroke)
                        ? Text(
                            "Aa",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: template.textColor,
                              shadows: [
                                Shadow(
                                  color: template.shadowColor,
                                  blurRadius: template.shadowBlur,
                                  offset: template.shadowOffset,
                                ),
                              ],
                            ),
                          )
                        : StrokeText(
                            text: "Aa",
                            strokeColor: template.strokeColor,
                            strokeWidth: template.strokeWidth,
                            textStyle: TextStyle(
                              fontSize: 22,
                              color: template.textColor,
                              fontWeight: FontWeight.w700,
                              shadows: template.hasShadow
                                  ? [
                                      Shadow(
                                        color: template.shadowColor,
                                        blurRadius: template.shadowBlur,
                                        offset: template.shadowOffset,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                  ),
                ),

                // Tune overlay for selected effects - 8id design
                if (isSelected && !isNoneTemplate)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        _showTuneBottomSheet(Get.context!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Label with better typography
            Text(
              template.name,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.branding
                    : Get.theme.colorScheme.onSurface.withOpacity(0.75),
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showTuneBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: null,
      elevation: 0,
      builder: (context) => TuneBottomSheet(controller: controller),
    );
  }

  // Keep all existing methods exactly as they were
  void _applyTemplate(EffectTemplate template) {
    if (template.id == "none") {
      controller.resetStrok();
    } else {
      if (template.textColor != null) {
        controller.textColor(template.textColor);
      }
    }

    controller.fontSize.value = template.fontSize;

    controller.hasShadow.value = template.hasShadow;
    if (template.hasShadow) {
      controller.shadowOffset.value = template.shadowOffset;
      controller.shadowBlurRadius.value = template.shadowBlur;
      controller.shadowColor.value = template.shadowColor;
    }

    controller.hasStroke.value = template.hasStroke;
    if (template.hasStroke) {
      controller.strokeWidth.value = template.strokeWidth;
      controller.strokeColor.value = template.strokeColor;
    }
    controller.hasMask = false;
    controller.hasDualTone.value = false;

    controller.updateTextItem();
    controller.selectedTemplateId = template.id;
    controller.update(['effect_templates', 'template_properties']);
  }

  bool _isTemplateSelected(
    TextStyleController controller,
    EffectTemplate template,
  ) {
    if (controller.selectedTemplateId != null) {
      return controller.selectedTemplateId == template.id;
    }

    if (template.id == 'none') {
      return !controller.hasShadow.value && !controller.hasStroke.value;
    }

    return false;
  }
}

// FORMAT TAB - Professional Design (Canva-style)
class _FormatTab extends StatelessWidget {
  final TextStyleController controller;
  const _FormatTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          // Text Alignment Section
          _buildSection(title: 'Alignment', child: _buildAlignmentGrid()),
          const SizedBox(height: 6),

          // Text Style Section
          _buildSection(title: 'Style', child: _buildStyleControls()),
          const SizedBox(height: 8),

          // Spacing Section
          _buildSection(title: 'Spacing', child: _buildSpacingControls()),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Section Content
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAlignmentGrid() {
    return GetBuilder<TextStyleController>(
      id: 'text_align',
      builder: (controller) {
        return Row(
          children: [
            Expanded(
              child: _buildAlignmentButton(
                icon: Icons.format_align_left_rounded,
                alignment: TextAlign.left,
                isSelected: controller.textAlign.value == TextAlign.left,
                controller: controller,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildAlignmentButton(
                icon: Icons.format_align_center_rounded,
                alignment: TextAlign.center,
                isSelected: controller.textAlign.value == TextAlign.center,
                controller: controller,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildAlignmentButton(
                icon: Icons.format_align_right_rounded,
                alignment: TextAlign.right,
                isSelected: controller.textAlign.value == TextAlign.right,
                controller: controller,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildAlignmentButton(
                icon: Icons.format_align_justify_rounded,
                alignment: TextAlign.justify,
                isSelected: controller.textAlign.value == TextAlign.justify,
                controller: controller,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlignmentButton({
    required IconData icon,
    required TextAlign alignment,
    required bool isSelected,
    required TextStyleController controller,
  }) {
    return GestureDetector(
      onTap: () {
        controller.textAlign.value = alignment;
        controller.updateTextItem();
        controller.update(['text_align']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 32,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.branding
              : Get.theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected
              ? Colors.white
              : Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildStyleControls() {
    return GetBuilder<TextStyleController>(
      id: 'text_style',
      builder: (controller) {
        return Column(
          children: [
            // Font Weight Selector
            _buildFontWeightSelector(controller),
            const SizedBox(height: 8),

            // Style Toggles
            Row(
              children: [
                Expanded(
                  child: _buildStyleToggle(
                    icon: Icons.format_italic_rounded,
                    label: 'Italic',
                    isActive: controller.isItalic.value,
                    onTap: () {
                      controller.isItalic.value = !controller.isItalic.value;
                      controller.updateTextItem();
                      controller.update(['text_style']);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildStyleToggle(
                    icon: Icons.format_underline_rounded,
                    label: 'Underline',
                    isActive: controller.isUnderlined.value,
                    onTap: () {
                      controller.isUnderlined.value =
                          !controller.isUnderlined.value;
                      controller.updateTextItem();
                      controller.update(['text_style']);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontWeightSelector(TextStyleController controller) {
    const weights = [
      FontWeight.w300,
      FontWeight.normal,
      FontWeight.w500,
      FontWeight.bold,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: weights.map((weight) {
            final isSelected = weight == controller.fontWeight.value;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.fontWeight.value = weight;
                  controller.updateTextItem();
                  controller.update(['text_style']);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.branding : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _getWeightLabel(weight),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: weight,
                      color: isSelected
                          ? Colors.white
                          : Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStyleToggle({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.branding
              : Get.theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? Colors.white
                  : Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : Get.theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: label == 'Italic' && isActive
                    ? FontStyle.italic
                    : FontStyle.normal,
                decoration: label == 'Underline' && isActive
                    ? TextDecoration.underline
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpacingControls() {
    return Column(
      children: [
        GetBuilder<TextStyleController>(
          id: 'letter_spacing',
          builder: (controller) {
            return CompactSlider(
              icon: Icons.space_bar_rounded,
              label: 'Letter Spacing',
              value: controller.letterSpacing.value,
              min: -3,
              max: 32.0,
              onChanged: (value) {
                controller.letterSpacing.value = value;
                controller.updateTextItem();
                controller.update(['letter_spacing']);
              },
            );
          },
        ),
        const SizedBox(height: 8),
        GetBuilder<TextStyleController>(
          id: 'line_height',
          builder: (controller) {
            return CompactSlider(
              icon: Icons.height_rounded,
              label: 'Line Height',
              value: controller.lineHeight.value,
              min: 0.8,
              max: 3.0,
              onChanged: (value) {
                controller.lineHeight.value = value;
                controller.updateTextItem();
                controller.update(['line_height']);
              },
            );
          },
        ),
      ],
    );
  }

  String _getWeightLabel(FontWeight weight) {
    switch (weight) {
      case FontWeight.w300:
        return 'Light';
      case FontWeight.normal:
        return 'Regular';
      case FontWeight.w500:
        return 'Medium';
      case FontWeight.bold:
        return 'Bold';
      default:
        return '';
    }
  }
}

// COLOR TAB - Optimized spacing
class _ColorTab extends StatelessWidget {
  final TextStyleController controller;
  const _ColorTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GetBuilder<TextStyleController>(
        id: 'text_color',
        builder: (controller) {
          return ColorSelector(
            title: "Text Color",
            showTitle: false,
            paddingx: 16,
            colors: AppColors.predefinedColors,
            currentColor: controller.textColor.value,
            onColorSelected: (color) {
              controller.textColor.value = color;
              controller.textColorOld = color;
              controller.maskImage = null;
              controller.updateTextItem();
              controller.update(['text_color', 'mask']);
            },
          );
        },
      ),
    );
  }
}

// BACKGROUND TAB - Optimized with clear option
class _BackgroundTab extends StatelessWidget {
  final TextStyleController controller;
  const _BackgroundTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GetBuilder<TextStyleController>(
        id: 'background_color',
        builder: (controller) {
          return ColorSelector(
            title: "Bg Color",
            showTitle: false,

            colors: AppColors.predefinedColors,
            currentColor: controller.backgroundColor.value,
            onColorSelected: (color) {
              controller.backgroundColor.value = color;
              controller.updateTextItem();
              controller.update(['background_color']);
            },
            selectedBorderColor: Colors.white,
            itemSize: 35,
          );
          // return GridView.builder(
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 8,
          //     crossAxisSpacing: 6,
          //     mainAxisSpacing: 6,
          //     childAspectRatio: 1,
          //   ),
          //   itemCount:
          //       AppColors.predefinedColors.length +
          //       1, // +1 for clear option
          //   itemBuilder: (context, index) {
          //     if (index == 0) {
          //       // Clear/Transparent option
          //       final isSelected =
          //           controller.backgroundColor.value == Colors.transparent;
          //       return GestureDetector(
          //         onTap: () {
          //           controller.backgroundColor.value = Colors.transparent;
          //           controller.updateTextItem();
          //           controller.update(['background_color']);
          //         },
          //         child: Container(
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             shape: BoxShape.circle,
          //             border: Border.all(
          //               color: isSelected
          //                   ? AppColors.accent
          //                   : AppColors.highlight.withOpacity(0.3),
          //               width: isSelected ? 3 : 1,
          //             ),
          //           ),
          //           child: Icon(
          //             Icons.clear,
          //             color: isSelected
          //                 ? AppColors.accent
          //                 : AppColors.highlight.withOpacity(0.6),
          //             size: 14,
          //           ),
          //         ),
          //       );
          //     }

          //     final color = AppColors.predefinedColors[index - 1];
          //     final isSelected = color == controller.backgroundColor.value;

          //     return GestureDetector(
          //       onTap: () {
          //         controller.backgroundColor.value = color;
          //         controller.updateTextItem();
          //         controller.update(['background_color']);
          //       },
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: color,
          //           shape: BoxShape.circle,
          //           border: Border.all(
          //             color: isSelected
          //                 ? AppColors.accent
          //                 : AppColors.highlight.withOpacity(0.3),
          //             width: isSelected ? 3 : 1,
          //           ),
          //         ),
          //         child: isSelected
          //             ? Icon(
          //                 Icons.check,
          //                 color: color.computeLuminance() > 0.5
          //                     ? Colors.black
          //                     : Colors.white,
          //                 size: 14,
          //               )
          //             : null,
          //       ),
          //     );
          //   },
          // );
        },
      ),
    );
  }
}

// FONT TAB - Compact chip layout
class _FontTab extends StatelessWidget {
  final TextStyleController controller;
  const _FontTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Get.theme.colorScheme.surface,
            Get.theme.colorScheme.surfaceContainer.withOpacity(0.2),
          ],
        ),
      ),
      child: Column(
        children: [
          // Search Header with professional button
          _buildSearchHeader(),

          // Font List with Infinite Scroll
          Expanded(
            child: GetBuilder<TextStyleController>(
              id: 'font_list',
              builder: (controller) {
                return GetBuilder<TextStyleController>(
                  id: 'font_family',
                  builder: (controller) {
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        // Load more when reaching 80% of the scroll
                        if (scrollInfo.metrics.pixels >
                            scrollInfo.metrics.maxScrollExtent * 0.8) {
                          controller.loadMoreFonts();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 6),
                        itemCount:
                            controller.displayedFonts.length +
                            (controller.hasMoreFonts.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Loading indicator at the end
                          if (index == controller.displayedFonts.length) {
                            return _buildLoadingIndicator();
                          }

                          final font = controller.displayedFonts[index];
                          final isSelected =
                              font == controller.selectedFont.value;

                          return _buildFontItem(
                            font: font,
                            isSelected: isSelected,
                            onTap: () {
                              controller.selectedFont.value = font;
                              controller.updateTextItem();
                              controller.update(['font_family']);
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Browse Fonts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Get.theme.colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(elevation: 10),
            onPressed: () => _openFontSearch(),
            label: Text('Search'),
            icon: Icon(Icons.search_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _openFontSearch() {
    Get.to(
      () => FontSearchPage(
        currentSelectedFont: controller.selectedFont.value,
        onFontSelected: (String selectedFont) {
          controller.selectedFont.value = selectedFont;
          controller.updateTextItem();
          controller.update(['font_family']);
        },
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildFontItem({
    required String font,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.branding.withOpacity(0.15),
                    AppColors.branding.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : Get.theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Font Preview Text
                  Text(
                    font,
                    style: GoogleFonts.getFont(
                      font,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),

            // Selection Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.branding : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.branding : Colors.white,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return GetBuilder<TextStyleController>(
      id: 'font_list',
      builder: (controller) {
        if (!controller.isLoadingMoreFonts.value) return SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.branding),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading more fonts...',
                style: TextStyle(
                  fontSize: 13,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// MASK TAB - Fixed implementation with proper organization
class _MaskTab extends StatelessWidget {
  final TextStyleController controller;
  const _MaskTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mask presets in a horizontal list (including "None" option)
        _buildMaskPresets(),
      ],
    );
  }

  Widget _buildMaskPresets() {
    return Expanded(
      child: GetBuilder<TextStyleController>(
        id: 'mask_presets',
        builder: (controller) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: TextStyleController.maskImages.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildNoMaskOption();
              }
              final image = TextStyleController.maskImages[index];
              return _buildMaskOption(image!);
            },
          );
        },
      ),
    );
  }

  Widget _buildNoMaskOption() {
    final isSelected = controller.maskImage == null;
    return GestureDetector(
      onTap: () => _clearMask(controller),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.branding.withOpacity(0.1)
              : Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.branding
                : Get.theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.layers_clear_rounded,
            size: 24,
            color: isSelected
                ? AppColors.branding
                : Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildMaskOption(String image) {
    final isSelected = image == controller.maskImage;
    return GestureDetector(
      onTap: () => _selectImageMask(controller, image),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.branding.withOpacity(0.1)
              : Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.branding
                : Get.theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image container
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Get.theme.colorScheme.surfaceContainerLow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported_rounded,
                        size: 20,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Tune overlay for selected mask
            if (isSelected)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _showMaskTuneBottomSheet(Get.context!);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMaskTuneBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: null,
      elevation: 0,
      builder: (context) => MaskTuneBottomSheet(controller: controller),
    );
  }

  void _clearMask(TextStyleController controller) {
    print('Clearing mask');
    controller.hasMask = false; // Set hasMask to false
    controller.maskImage = null;
    controller.maskBlendMode = BlendMode.srcATop;

    controller.updateTextItem();
    controller.update(['mask_presets', 'mask_settings']);
  }

  void _selectImageMask(TextStyleController controller, String image) {
    controller.hasMask = true; // Set hasMask to true
    controller.hasDualTone.value = false;
    controller.maskImage = image;
    if (controller.backgroundColor.value != Colors.transparent) {
      controller.backgroundColor(Colors.transparent);
    }
    controller.updateTextItem();
    controller.update(['mask_presets', 'mask_settings']);
  }
}

class MaskTuneBottomSheet extends StatelessWidget {
  final TextStyleController controller;

  const MaskTuneBottomSheet({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildMaskProperties()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 5,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildMaskProperties() {
    return GetBuilder<TextStyleController>(
      id: "mask_properties",
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Blend Mode Radio Buttons
              _buildBlendModeSelector(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlendModeSelector() {
    final blendModes = [
      {'mode': BlendMode.srcATop, 'name': 'Src A Top'},
      {'mode': BlendMode.dstATop, 'name': 'Dst A Top'},
    ];

    return GetBuilder<TextStyleController>(
      id: 'mask_blend_mode',
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.layers,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Blend Mode',
                  style: TextStyle(
                    fontSize: 14,
                    color: Get.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: blendModes.map((blendModeData) {
                final mode = blendModeData['mode'] as BlendMode;
                final name = blendModeData['name'] as String;
                final isSelected = controller.maskBlendMode == mode;

                return GestureDetector(
                  onTap: () {
                    controller.maskBlendMode = mode;
                    controller.updateTextItem();
                    controller.update(['mask_properties', 'mask_blend_mode']);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.branding.withOpacity(0.1)
                          : Get.theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.branding
                            : Get.theme.colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.branding
                                  : Get.theme.colorScheme.outline.withOpacity(
                                      0.5,
                                    ),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.branding,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.branding
                                : Get.theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class TuneBottomSheet extends StatelessWidget {
  final TextStyleController controller;

  const TuneBottomSheet({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // height: MediaQuery.of(context).size.height * 0.55,
      width: Get.width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.hasStroke.value) ...[
                  // const SizedBox(height: 12),
                  _buildStrokeProperties(),
                ],
                if (controller.hasShadow.value) ...[
                  const SizedBox(height: 12),
                  _buildShadowProperties(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 5,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildStrokeProperties() {
    return GetBuilder<TextStyleController>(
      id: "stroke_properties",
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CompactSlider(
                icon: Icons.line_weight,
                label: 'Stroke Width',
                value: controller.strokeWidth.value,
                min: 0.0,
                max: 10.0,
                onChanged: (value) {
                  controller.strokeWidth.value = value;

                  controller.updateTextItem();
                  controller.update(['stroke_properties']);
                },
              ),

              ColorSelector(
                title: "Stroke Color",

                colors: AppColors.predefinedColors,
                currentColor: controller.strokeColor.value,
                onColorSelected: (color) {
                  controller.strokeColor.value = color;
                  controller.updateTextItem();
                  controller.update(['stroke_properties']);
                },
                selectedBorderColor: Colors.white,
                itemSize: 25,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShadowProperties() {
    return GetBuilder<TextStyleController>(
      id: 'shadow_properties',
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,

            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.colorScheme.surfaceContainer.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CompactSlider(
                icon: Icons.blur_on,
                label: 'Blur Radius',
                value: controller.shadowBlurRadius.value,
                min: 0.0,
                max: 20.0,
                onChanged: (value) {
                  controller.shadowBlurRadius.value = value;
                  controller.updateTextItem();
                  controller.update(['shadow_properties']);
                },
              ),

              ColorSelector(
                title: "Shadow Color",
                colors: AppColors.predefinedColors,
                currentColor: controller.shadowColor.value,
                onColorSelected: (color) {
                  controller.shadowColor.value = color;
                  controller.updateTextItem();
                  controller.update(['shadow_properties']);
                },
                selectedBorderColor: Colors.white,

                itemSize: 25,
              ),
            ],
          ),
        );
      },
    );
  }
}

class EffectTemplate {
  final String id;
  final String name;
  final IconData icon;
  final bool hasShadow;
  final Offset shadowOffset;
  final double shadowBlur;
  final Color shadowColor;
  final bool hasStroke;
  final double strokeWidth;
  final Color strokeColor;
  final Color? textColor;
  final double fontSize; // Added fontSize property

  const EffectTemplate({
    required this.id,
    required this.name,
    required this.icon,
    this.hasShadow = false,
    this.shadowOffset = const Offset(0, 0),
    this.shadowBlur = 0.0,
    this.shadowColor = Colors.black,
    this.hasStroke = false,
    this.strokeWidth = 1.0,
    this.strokeColor = Colors.black,
    this.textColor,
    this.fontSize = 16.0, // Default font size
  });
}

// Create a new DualToneText widget
class DualToneText extends StatelessWidget {
  final String text;
  final Color color1;
  final Color color2;
  final DualToneDirection direction;
  final double position;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextScaler? textScaler;
  final TextOverflow? overflow;
  final int? maxLines;

  const DualToneText({
    super.key,
    required this.text,
    required this.color1,
    required this.color2,
    this.direction = DualToneDirection.horizontal,
    this.position = 0.5,
    this.textStyle,
    this.textAlign,
    this.textDirection,
    this.textScaler,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return _createGradient().createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: textStyle?.copyWith(color: Colors.white),
        textAlign: textAlign,
        textDirection: textDirection,
        textScaler: textScaler,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }

  Gradient _createGradient() {
    switch (direction) {
      case DualToneDirection.horizontal:
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color1, color2],
          stops: [position, position],
        );
      case DualToneDirection.vertical:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color1, color2],
          stops: [position, position],
        );
      case DualToneDirection.diagonal:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
          stops: [position, position],
        );
      case DualToneDirection.radial:
        return RadialGradient(
          center: Alignment.center,
          colors: [color1, color2],
          stops: [position, position],
        );
    }
  }
}

// Add a new tab for Dual Tone in your TextStylingEditor

class _DualToneTuneTab extends StatelessWidget {
  final TextStyleController controller;
  const _DualToneTuneTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 100,
            child: GetBuilder<TextStyleController>(
              id: 'dual_tone_templates',
              builder: (controller) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: dualToneTemplates.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final template = dualToneTemplates[index];
                    final isSelected = _isDualToneTemplateSelected(
                      controller,
                      template,
                    );

                    return _buildDualToneTemplateCard(
                      template: template,
                      isSelected: isSelected,
                      onTap: () => _applyDualToneTemplate(controller, template),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDualToneTuneBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: null,
      barrierColor: Colors.transparent,
      elevation: 0,
      builder: (context) => DualToneTuneBottomSheet(controller: controller),
    );
  }

  Widget _buildDualToneTemplateCard({
    required DualToneTemplate template,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isNoneTemplate = template.id == 'none';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        height: 92,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.branding.withOpacity(0.12)
              : Get.theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.branding
                : Get.theme.colorScheme.outline.withOpacity(0.15),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.branding.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Get.theme.colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: isNoneTemplate
                        ? Text(
                            "Aa",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: controller.textColor.value,
                            ),
                          )
                        : DualToneText(
                            text: "Aa",
                            color1: template.color1,
                            color2: template.color2,
                            direction: template.direction,
                            position: template.position,
                            textStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                if (isSelected && !isNoneTemplate)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        _showDualToneTuneBottomSheet(Get.context!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              template.name,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.branding
                    : Get.theme.colorScheme.onSurface.withOpacity(0.75),
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _applyDualToneTemplate(
    TextStyleController controller,
    DualToneTemplate template,
  ) {
    if (template.id == 'none') {
      controller.hasDualTone.value = false;
    } else {
      controller.hasDualTone.value = true;
      controller.dualToneColor1 = template.color1;
      controller.dualToneColor2 = template.color2;
      controller.dualToneDirection.value = template.direction;
      controller.dualTonePosition.value = template.position;
    }

    controller.updateTextItem();
    controller.selectedDualToneTemplateId = template.id;
    controller.update(['dual_tone_templates', 'dual_tone_properties']);
  }

  bool _isDualToneTemplateSelected(
    TextStyleController controller,
    DualToneTemplate template,
  ) {
    if (controller.selectedDualToneTemplateId != null) {
      return controller.selectedDualToneTemplateId == template.id;
    }

    // If no template is selected yet, "None" is selected when hasDualTone is false
    if (template.id == 'none') {
      return !controller.hasDualTone.value;
    }

    return false;
  }
}

class DualToneTuneBottomSheet extends StatelessWidget {
  final TextStyleController controller;

  const DualToneTuneBottomSheet({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        // color: Get.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorSection(),
                const SizedBox(height: 8),
                _buildDirectionSection(),
                const SizedBox(height: 8),
                _buildPositionSlider(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildColorSection() {
    return GetBuilder<TextStyleController>(
      id: 'dual_tone_colors',
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.color_lens, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Colors',
                    style: Get.theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ColorSelector(
                          title: "Color 1",
                          colors: AppColors.predefinedColors,
                          currentColor: controller.dualToneColor1 ?? Colors.red,
                          onColorSelected: (color) {
                            controller.dualToneColor1 = color;
                            controller.updateTextItem();
                            controller.update(['dual_tone_colors']);
                          },
                          selectedBorderColor: AppColors.branding,
                          itemSize: 28,
                          spacing: 6,
                          paddingx: 0,
                          showTitle: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ColorSelector(
                          title: "Color 2",

                          colors: AppColors.predefinedColors,
                          currentColor:
                              controller.dualToneColor2 ?? Colors.blue,
                          onColorSelected: (color) {
                            controller.dualToneColor2 = color;
                            controller.updateTextItem();
                            controller.update(['dual_tone_colors']);
                          },
                          selectedBorderColor: AppColors.branding,
                          itemSize: 28,
                          spacing: 6,
                          paddingx: 0,
                          showTitle: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDirectionSection() {
    return GetBuilder<TextStyleController>(
      id: 'dual_tone_direction',
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.directions, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Direction',
                    style: Get.theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: DualToneDirection.values.map((direction) {
                  final isSelected =
                      controller.dualToneDirection.value == direction;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: isSelected
                            ? AppColors.branding.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            controller.dualToneDirection.value = direction;
                            controller.updateTextItem();
                            controller.update(['dual_tone_direction']);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Icon(
                                  _getDirectionIcon(direction),
                                  size: 20,
                                  color: isSelected
                                      ? AppColors.branding
                                      : Get.theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPositionSlider() {
    return GetBuilder<TextStyleController>(
      id: 'dual_tone_position',
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Position',
                    style: Get.theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(controller.dualTonePosition.value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.branding,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CompactSlider(
                icon: Icons.horizontal_rule,
                value: controller.dualTonePosition.value,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  controller.dualTonePosition.value = value;
                  controller.updateTextItem();
                  controller.update(['dual_tone_position']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDirectionName(DualToneDirection direction) {
    switch (direction) {
      case DualToneDirection.horizontal:
        return 'Horizontal';
      case DualToneDirection.vertical:
        return 'Vertical';
      case DualToneDirection.diagonal:
        return 'Diagonal';
      case DualToneDirection.radial:
        return 'Radial';
    }
  }

  IconData _getDirectionIcon(DualToneDirection direction) {
    switch (direction) {
      case DualToneDirection.horizontal:
        return Icons.swap_horiz;
      case DualToneDirection.vertical:
        return Icons.swap_vert;
      case DualToneDirection.diagonal:
        return Icons.trending_up;
      case DualToneDirection.radial:
        return Icons.radio_button_unchecked;
    }
  }
}

class DualToneTemplate {
  final String id;
  final String name;
  final Color color1;
  final Color color2;
  final DualToneDirection direction;
  final double position;

  const DualToneTemplate({
    required this.id,
    required this.name,
    required this.color1,
    required this.color2,
    this.direction = DualToneDirection.horizontal,
    this.position = 0.5,
  });
}

const List<DualToneTemplate> dualToneTemplates = [
  DualToneTemplate(
    id: 'none',
    name: 'None',
    color1: Colors.transparent,
    color2: Colors.transparent,
    direction: DualToneDirection.horizontal,
  ),
  DualToneTemplate(
    id: 'pti',
    name: 'PTI',
    color1: Colors.red,
    color2: Colors.green,
    direction: DualToneDirection.vertical,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'red_blue',
    name: 'Red/Blue',
    color1: Colors.red,
    color2: Colors.blue,
    direction: DualToneDirection.vertical,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'purple_pink',
    name: 'Purple/Pink',
    color1: Colors.purple,
    color2: Colors.pink,
    direction: DualToneDirection.vertical,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'green_yellow',
    name: 'Green/Yellow',
    color1: Colors.green,
    color2: Colors.yellow,
    direction: DualToneDirection.vertical,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'black_white',
    name: 'Black/White',
    color1: Colors.black,
    color2: Colors.white,
    direction: DualToneDirection.vertical,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'orange_teal',
    name: 'Orange/Teal',
    color1: Colors.orange,
    color2: Colors.teal,
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'sunset',
    name: 'Sunset',
    color1: Color(0xFFFF6B6B),
    color2: Color(0xFFFFE66D),
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'ocean',
    name: 'Ocean',
    color1: Color(0xFF4ECDC4),
    color2: Color(0xFF0077BE),
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'lavender',
    name: 'Lavender',
    color1: Color(0xFF9B59B6),
    color2: Color(0xFFE74C3C),
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'forest',
    name: 'Forest',
    color1: Color(0xFF2ECC71),
    color2: Color(0xFF16A085),
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'royal',
    name: 'Royal',
    color1: Color(0xFF6C5CE7),
    color2: Color(0xFFDDA0DD),
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'coral',
    name: 'Coral',
    color1: Color(0xFFFF7675),
    color2: Color(0xFFFFB6C1),
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'mint',
    name: 'Mint',
    color1: Color(0xFF00D2D3),
    color2: Color(0xFF7FFFD4),
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'amber',
    name: 'Amber',
    color1: Color(0xFFFFB800),
    color2: Color(0xFFFFE5B4),
    direction: DualToneDirection.diagonal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'rose',
    name: 'Rose',
    color1: Color(0xFFE84393),
    color2: Color(0xFFFF6B9D),
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'sky',
    name: 'Sky',
    color1: Color(0xFF74B9FF),
    color2: Color(0xFF0984E3),
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'emerald',
    name: 'Emerald',
    color1: Color(0xFF00B894),
    color2: Color(0xFF90EE90),
    direction: DualToneDirection.horizontal,
    position: 0.5,
  ),
  DualToneTemplate(
    id: 'violet',
    name: 'Violet',
    color1: Color(0xFFA29BFE),
    color2: Color(0xFF9370DB),
    direction: DualToneDirection.radial,
    position: 0.6,
  ),
];

class _CircularTab extends StatelessWidget {
  final TextStyleController controller;
  final TabController tabController;

  const _CircularTab({required this.controller, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        children: [
          // Circular text toggle
          GetBuilder<TextStyleController>(
            id: 'circular_toggle',
            builder: (controller) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.highlight.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: controller.isCircular.value
                              ? AppColors.accent.withOpacity(0.15)
                              : AppColors.highlight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.circle_outlined,
                          color: controller.isCircular.value
                              ? AppColors.accent
                              : AppColors.highlight,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Circular Text',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Get.theme.colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Transform text into circular layout',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.highlight.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: controller.isCircular.value,
                          onChanged: (value) {
                            controller.isCircular.value = value;
                            controller.space.value = 15;
                            controller.updateTextItem();
                            controller.update(['circular_toggle']);
                          },
                          activeThumbColor: AppColors.accent,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Circular text controls
          GetBuilder<TextStyleController>(
            id: 'circular_toggle',
            builder: (controller) {
              if (!controller.isCircular.value) return const SizedBox.shrink();

              return Column(
                children: [
                  // Sub-tab bar
                  Container(
                    height: 30,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      controller: tabController,
                      indicator: BoxDecoration(
                        color: AppColors.branding,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      indicatorPadding: const EdgeInsets.symmetric(vertical: 0),
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.highlight,
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Spacing'),
                        Tab(text: 'Radius'),
                        Tab(text: 'Angle'),

                        Tab(text: 'Position'),
                        Tab(text: 'Direction'),
                        Tab(text: 'Style'),
                        Tab(text: 'Stroke'),
                        Tab(text: 'Colors'),
                      ],
                    ),
                  ),

                  // Sub-tab content
                  GetBuilder<TextStyleController>(
                    id: 'circular_tabbar',
                    builder: (context) {
                      return SizedBox(
                        height: tabController.index == 7 ? 250 : 100,
                        child: TabBarView(
                          controller: tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _LetterSpacingSubTab(controller: controller),
                            _RadiusSubTab(controller: controller),
                            _StartAngleSubTab(controller: controller),
                            _TextPositionSubTab(controller: controller),
                            _TextDirectionSubTab(controller: controller),
                            _StyleSubTab(controller: controller),
                            _StrokeWidthSubTab(controller: controller),
                            _ColorsSubTab(controller: controller),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Keep all the existing circular sub-tab implementations
class _RadiusSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _RadiusSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_radius',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Radius',
            subtitle: 'Circular path size',
            icon: Icons.radio_button_unchecked,
            child: _buildCompactSlider(
              value: controller.radius.value,
              min: 50.0,
              max: 200.0,
              label: '${controller.radius.value.toStringAsFixed(0)}px',
              onChanged: (value) {
                controller.radius.value = value;
                controller.updateTextItem();
                controller.update(['circular_radius']);
              },
            ),
          );
        },
      ),
    );
  }
}

class _LetterSpacingSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _LetterSpacingSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_spacing',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Letter Spacing',
            subtitle: 'Space between characters',
            icon: Icons.space_bar,
            child: _buildCompactSlider(
              value: controller.space.value,
              min: 0.0,
              max: 30.0,
              label: controller.space.value.toStringAsFixed(1),
              onChanged: (value) {
                controller.space.value = value;
                controller.updateTextItem();
                controller.update(['circular_spacing']);
              },
            ),
          );
        },
      ),
    );
  }
}

class _StartAngleSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _StartAngleSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_angle',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Start Angle',
            subtitle: 'Rotation of text path',
            icon: Icons.rotate_right,
            child: _buildCompactSlider(
              value: controller.startAngle.value,
              min: 0.0,
              max: 360.0,
              label: '${controller.startAngle.value.toStringAsFixed(0)}°',
              onChanged: (value) {
                controller.startAngle.value = value;
                controller.updateTextItem();
                controller.update(['circular_angle']);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TextPositionSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _TextPositionSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_position',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Text Position',
            subtitle: 'Inside or outside the circle',
            icon: Icons.place,
            child: _buildCompactSegmented<CircularTextPosition>(
              values: CircularTextPosition.values,
              selected: controller.position.value,
              onChanged: (value) {
                controller.position.value = value;
                controller.updateTextItem();
                controller.update(['circular_position']);
              },
              labelBuilder: (value) =>
                  value.toString().split('.').last.capitalize!,
            ),
          );
        },
      ),
    );
  }
}

class _TextDirectionSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _TextDirectionSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_direction',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Text Direction',
            subtitle: 'Clockwise or counterclockwise',
            icon: Icons.trending_flat,
            child: _buildCompactSegmented<CircularTextDirection>(
              values: CircularTextDirection.values,
              selected: controller.direction.value,
              onChanged: (value) {
                controller.direction.value = value;
                controller.updateTextItem();
                controller.update(['circular_direction']);
              },
              labelBuilder: (value) =>
                  value.toString().split('.').last.capitalize!,
            ),
          );
        },
      ),
    );
  }
}

class _StyleSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _StyleSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_style',
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildCompactToggle(
                      title: 'Background',
                      icon: Icons.circle,
                      value: controller.showBackground.value,
                      onChanged: (value) {
                        controller.showBackground.value = value;
                        controller.updateTextItem();
                        controller.update(['circular_style']);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactToggle(
                      title: 'Stroke',
                      icon: Icons.radio_button_unchecked,
                      value: controller.showStroke.value,
                      onChanged: (value) {
                        controller.showStroke.value = value;
                        controller.updateTextItem();
                        controller.update(['circular_style']);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StrokeWidthSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _StrokeWidthSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_stroke',
        builder: (controller) {
          if (!controller.showStroke.value) {
            return const Center(
              child: Text(
                'Enable Stroke in Style tab to adjust width',
                style: TextStyle(fontSize: 12, color: AppColors.highlight),
                textAlign: TextAlign.center,
              ),
            );
          }
          return _buildCompactSection(
            title: 'Stroke Width',
            subtitle: 'Thickness of the outline',
            icon: Icons.line_weight,
            child: _buildCompactSlider(
              value: controller.strokeWidth.value,
              min: 0.0,
              max: 100.0,
              label: '${controller.strokeWidth.value.toStringAsFixed(1)}px',
              onChanged: (value) {
                controller.strokeWidth.value = value;
                controller.updateTextItem();
                controller.update(['circular_stroke']);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ColorsSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _ColorsSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_colors',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Background Color',
            subtitle: 'Choose the background color',
            icon: Icons.color_lens_outlined,
            child: ColorSelector(
              colors: AppColors.predefinedColors,
              title: "colors",
              showTitle: false,
              currentColor: controller.backgroundPaintColor.value,
              onColorSelected: (color) {
                controller.backgroundPaintColor.value = color;
                controller.updateTextItem();
                controller.update(['circular_colors']);
              },
            ),
          );
        },
      ),
    );
  }
}

// New Arc Tab with sub-tabs
// Add this Arc Tab class to your TextStylingEditor file

// ====================== SHARED HELPER METHODS ======================
class StrokeText extends StatelessWidget {
  final String text;
  final Color strokeColor;
  final double strokeWidth;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextScaler? textScaler;
  final TextOverflow? overflow;
  final int? maxLines;

  const StrokeText({
    super.key,
    required this.text,
    this.strokeColor = Colors.amber, // Default stroke color
    this.strokeWidth = 3, // Default stroke width
    this.textStyle,
    this.textAlign,
    this.textDirection,
    this.textScaler,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate proper size constraints for the text
    final defaultTextStyle = TextStyle(
      fontSize: textStyle?.fontSize ?? 24,
      color: textStyle?.color ?? Colors.black,
      fontFamily: textStyle?.fontFamily,
      fontWeight: textStyle?.fontWeight,
      fontStyle: textStyle?.fontStyle,
      letterSpacing: textStyle?.letterSpacing,
      wordSpacing: textStyle?.wordSpacing,
      height: textStyle?.height,
    );

    // Create a TextPainter to measure the text
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: defaultTextStyle),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection ?? TextDirection.ltr,
      textScaler: textScaler ?? TextScaler.noScaling,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '...' : null,
    );

    // Layout the text with constraints to get proper size
    textPainter.layout(minWidth: 0, maxWidth: double.infinity);

    // Add stroke width padding to prevent clipping
    final additionalWidth = strokeWidth * 2;
    final additionalHeight = strokeWidth * 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the actual size needed
        double width = textPainter.width + additionalWidth;
        double height = textPainter.height + additionalHeight;

        // Respect parent constraints
        if (constraints.maxWidth != double.infinity) {
          width = width.clamp(0.0, constraints.maxWidth);
        }
        if (constraints.maxHeight != double.infinity) {
          height = height.clamp(0.0, constraints.maxHeight);
        }

        return SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            size: Size(width, height),
            painter: _TextPainterWithStroke(
              text: text,
              strokeColor: strokeColor,
              strokeWidth: strokeWidth,
              textStyle: textStyle,
              textAlign: textAlign,
              textDirection: textDirection,
              textScaler: textScaler,
              overflow: overflow,
              maxLines: maxLines,
            ),
          ),
        );
      },
    );
  }
}

class _TextPainterWithStroke extends CustomPainter {
  final String text;
  final Color strokeColor;
  final double strokeWidth;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextScaler? textScaler;
  final TextOverflow? overflow;
  final int? maxLines;

  _TextPainterWithStroke({
    required this.text,
    required this.strokeColor,
    required this.strokeWidth,
    this.textStyle,
    this.textAlign,
    this.textDirection,
    this.textScaler,
    this.overflow,
    this.maxLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty || size.width <= 0 || size.height <= 0) return;

    const defaultTextStyle = TextStyle(fontSize: 24, color: Colors.black);

    final mergedTextStyle = defaultTextStyle.merge(textStyle);

    // Create stroke text style
    final strokeTextStyle = mergedTextStyle.copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = strokeColor,
    );

    // Create main text style
    final mainTextStyle = mergedTextStyle.copyWith(
      color: mergedTextStyle.color ?? Colors.black,
    );

    // Create stroke text painter
    final strokePainter = TextPainter(
      text: TextSpan(text: text, style: strokeTextStyle),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection ?? TextDirection.ltr,
      textScaler: textScaler ?? TextScaler.noScaling,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '...' : null,
    );

    // Create main text painter
    final mainTextPainter = TextPainter(
      text: TextSpan(text: text, style: mainTextStyle),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection ?? TextDirection.ltr,
      textScaler: textScaler ?? TextScaler.noScaling,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '...' : null,
    );

    // Layout with available width minus stroke padding
    final maxWidth = (size.width - strokeWidth * 2).clamp(0.0, double.infinity);

    strokePainter.layout(minWidth: 0, maxWidth: maxWidth);
    mainTextPainter.layout(minWidth: 0, maxWidth: maxWidth);

    // Calculate offset based on alignment and available space
    final offset = _calculateOffset(strokePainter, size);

    // Draw the stroke first
    strokePainter.paint(canvas, offset);

    // Then draw the main text
    mainTextPainter.paint(canvas, offset);
  }

  // Helper method to calculate the offset based on text alignment
  Offset _calculateOffset(TextPainter painter, Size size) {
    // Add stroke width as padding
    final paddingX = strokeWidth;
    final paddingY = strokeWidth;

    switch (textAlign ?? TextAlign.start) {
      case TextAlign.center:
        return Offset(
          ((size.width - painter.width) / 2).clamp(
            paddingX,
            size.width - paddingX,
          ),
          ((size.height - painter.height) / 2).clamp(
            paddingY,
            size.height - paddingY,
          ),
        );
      case TextAlign.end:
      case TextAlign.right:
        return Offset(
          (size.width - painter.width - paddingX).clamp(
            paddingX,
            size.width - paddingX,
          ),
          ((size.height - painter.height) / 2).clamp(
            paddingY,
            size.height - paddingY,
          ),
        );
      case TextAlign.left:
      case TextAlign.start:
      case TextAlign.justify:
      default:
        return Offset(
          paddingX,
          ((size.height - painter.height) / 2).clamp(
            paddingY,
            size.height - paddingY,
          ),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _TextPainterWithStroke oldDelegate) {
    return text != oldDelegate.text ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        textStyle != oldDelegate.textStyle ||
        textAlign != oldDelegate.textAlign ||
        textDirection != oldDelegate.textDirection ||
        textScaler != oldDelegate.textScaler ||
        overflow != oldDelegate.overflow ||
        maxLines != oldDelegate.maxLines;
  }
}

Widget _buildCompactSection({
  required String title,
  required String subtitle,
  required IconData icon,
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Get.theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),

      boxShadow: [
        BoxShadow(
          color: Get.theme.shadowColor.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: AppColors.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Get.theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.highlight.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    ),
  );
}

Widget _buildCompactSlider({
  required double value,
  required double min,
  required double max,
  required String label,
  required ValueChanged<double> onChanged,
}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            min.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.highlight.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
          Text(
            max.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.highlight.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      SliderTheme(
        data: SliderTheme.of(Get.context!).copyWith(
          padding: EdgeInsets.zero,
          activeTrackColor: AppColors.accent,
          inactiveTrackColor: AppColors.highlight.withOpacity(0.15),
          thumbColor: AppColors.accent,
          overlayColor: AppColors.accent.withOpacity(0.2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          trackHeight: 3,
        ),
        child: Slider(value: value, min: min, max: max, onChanged: onChanged),
      ),
    ],
  );
}

Widget _buildCompactSegmented<T>({
  required List<T> values,
  required T selected,
  required ValueChanged<T> onChanged,
  required String Function(T) labelBuilder,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.highlight.withOpacity(0.06),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.all(3),
    child: Row(
      children: values.map((value) {
        final isSelected = value == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labelBuilder(value),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.highlight,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

Widget _buildCompactToggle({
  required String title,
  required IconData icon,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value
            ? AppColors.accent.withOpacity(0.1)
            : Get.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.highlight.withOpacity(0.15),
          width: value ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: value ? AppColors.accent : AppColors.highlight,
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: value ? AppColors.accent : AppColors.highlight,
            ),
          ),
        ],
      ),
    ),
  );
}

class _UrduFontTab extends StatefulWidget {
  final TextStyleController controller;
  const _UrduFontTab({required this.controller});

  @override
  State<_UrduFontTab> createState() => _UrduFontTabState();
}

class _UrduFontTabState extends State<_UrduFontTab> {
  @override
  void initState() {
    super.initState();
    _loadRemoteFonts();
  }

  Future<void> _loadRemoteFonts() async {
    // All fonts are now local and compressed
    // No loading needed
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter to show only downloaded fonts
    final downloadedFonts = UrduFontService.allFonts
        .where((font) => font.isLocal)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: downloadedFonts.length + 1, // +1 for manage button
      itemBuilder: (context, index) {
        if (index == 0) {
          // First item is the manage button
          return _buildUrduFontCard(
            downloadedFonts.isNotEmpty ? downloadedFonts[0] : null,
          );
        }
        final font = downloadedFonts[index - 1];
        return _buildUrduFontCardOld(font);
      },
    );
  }

  Widget _buildUrduFontCard(UrduFont? font) {
    // Build the manage button (doesn't need font parameter)
    if (font == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.branding.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.branding.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.font_download_rounded,
              color: AppColors.branding,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download Urdu Fonts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'No fonts downloaded yet',
                    style: TextStyle(
                      fontSize: 12,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.branding,
              size: 20,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        // Open font management page for selection and download
        Get.to(
          () => FontManagementPage(
            onFontSelected: (String selectedFont) {
              widget.controller.updateFont(selectedFont, isRTL: true);
            },
            currentSelectedFont: widget.controller.selectedFont.value,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.branding.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.branding.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.font_download_rounded,
              color: AppColors.branding,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse and download more fonts',

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.branding,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrduFontCardOld(UrduFont font) {
    final isSelected = widget.controller.selectedFont.value == font.family;

    return GestureDetector(
      onTap: () {
        widget.controller.updateFont(font.family, isRTL: true);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.branding.withOpacity(0.1),
                    AppColors.branding.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : Get.theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.branding.withOpacity(0.3), width: 1)
              : Border.all(
                  color: Get.theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                font.previewText,
                style: TextStyle(
                  fontFamily: font.family,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                  letterSpacing: 0.1,
                ),
                textDirection: font.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.branding : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.branding : Colors.white,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          // Handle search functionality
        },
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Get.theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search Urdu fonts...',
          hintStyle: TextStyle(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: () => _openUrduFontSearch(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.branding,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.branding.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.search_rounded, size: 20, color: Colors.white),
      ),
    );
  }

  void _openUrduFontSearch() {
    Get.to(
      () => UrduFontSearchPage(
        currentSelectedFont: widget.controller.selectedFont.value,
        onFontSelected: (String selectedFont) {
          widget.controller.updateFont(selectedFont, isRTL: true);
        },
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildUrduFontCategories() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildLocalFontsSection(),
        const SizedBox(height: 24),
        ...UrduFontCategory.values.map((category) {
          final fonts = UrduFontService.getFontsByCategory(category);
          return Column(
            children: [
              _buildCategorySection(category, fonts),
              const SizedBox(height: 24),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLocalFontsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () {
            Get.to(FontManagementPage());
          },
          child: Text('manage'),
        ),
        _buildCategoryHeader(
          'Available Fonts',
          'All fonts are included and ready to use',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildFontsGrid(),
      ],
    );
  }

  Widget _buildFontsGrid() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: UrduFontService.allFonts.length,
      itemBuilder: (context, index) {
        final font = UrduFontService.allFonts[index];
        return _buildFontCard(font);
      },
    );
  }

  Widget _buildFontCard(UrduFont font) {
    final isSelected = widget.controller.selectedFont.value == font.family;

    return GestureDetector(
      onTap: () {
        widget.controller.updateFont(font.family, isRTL: true);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.branding.withOpacity(0.1),
                    AppColors.branding.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : Get.theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.branding.withOpacity(0.3), width: 1)
              : Border.all(
                  color: Get.theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Font Preview Text
                  Text(
                    font.family,
                    style: UrduFontService.getTextStyle(
                      fontFamily: font.family,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                      letterSpacing: 0.1,
                    ),
                    textDirection: font.isRTL
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Font Name
                  Text(
                    font.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.branding
                          : Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Selection Indicator (Tick Switch)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.branding : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.branding : Colors.white,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(UrduFont font, bool isDownloaded) {
    if (isDownloaded) {
      return Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 12, color: Colors.green),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              'Ready',
              style: TextStyle(
                fontSize: 9,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: () => _downloadFont(font),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.branding,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download_rounded, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                'Download',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _downloadFont(UrduFont font) async {
    if (font.remoteFont == null) return;

    try {
      // Show loading indicator
      Get.dialog(
        AlertDialog(
          backgroundColor: Get.theme.colorScheme.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Downloading ${font.displayName}...',
                style: TextStyle(
                  color: Get.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      final bool success = await UrduFontService.downloadFont(font);

      Get.back(); // Close loading dialog

      if (success) {
        Get.snackbar(
          'Success',
          '${font.displayName} downloaded successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Refresh the UI
        setState(() {});
      } else {
        Get.snackbar(
          'Error',
          'Failed to download ${font.displayName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Download failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildCategorySection(
    UrduFontCategory category,
    List<UrduFont> fonts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeaderFromEnum(category),
        const SizedBox(height: 12),
        ...fonts.map((font) => _buildUrduFontItem(font)),
      ],
    );
  }

  Widget _buildCategoryHeader(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Get.theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeaderFromEnum(UrduFontCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.branding,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Get.theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  category.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrduFontItem(UrduFont font) {
    final isSelected = widget.controller.selectedFont.value == font.family;

    return GestureDetector(
      onTap: () {
        widget.controller.updateFont(font.family, isRTL: true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.branding.withOpacity(0.15),
                    AppColors.branding.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : Get.theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.branding.withOpacity(0.3), width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.branding.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Font Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                font.family,
                style: UrduFontService.getTextStyle(
                  fontFamily: font.family,
                  fontSize: 22,
                  color: Get.theme.colorScheme.onSurface,
                ),
                textDirection: font.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            // Font Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        font.family,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.branding
                              : Get.theme.colorScheme.onSurface,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              font.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Get.theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (!font.isLocal) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.cloud_download_rounded,
                              size: 14,
                              color: Colors.blue.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Selection Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.branding : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.branding
                          : Get.theme.colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check_rounded, size: 18, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

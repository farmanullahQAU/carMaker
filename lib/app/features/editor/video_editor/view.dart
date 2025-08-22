import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/text_editor.dart';
import 'package:cardmaker/app/features/editor/video_editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/widgets/common/colors_selector.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:cardmaker/widgets/common/quick_color_picker.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_case.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  late ImageEditorController _imageEditorController;
  final canvasController = Get.find<CanvasController>();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Initialize or get the ImageEditorController
    try {
      _imageEditorController = Get.find<ImageEditorController>();
    } catch (e) {
      _imageEditorController = Get.put(ImageEditorController());
    }

    // Set the current image item
    _imageEditorController.setSelectedImageItem(widget.imageItem);

    // Listen to tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _imageEditorController.setSelectedTabIndex(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ImageItemContent get content => widget.imageItem.content!;

  void _updateImage() {}

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      id: 'panel_container',
      builder: (controller) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        // curve: Curves.easeOutCubic,
        height: _tabController.index < 4 ? 160 : 180,
        color: Get.theme.colorScheme.surfaceContainerHigh,
        child: Column(
          children: [
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.branding, width: 0.1),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton.small(
                    onPressed: () {
                      canvasController.replaceImageItem();
                    },

                    child: Icon(Icons.add_a_photo_outlined, size: 16),
                  ),
                  Flexible(
                    child: TabBar(
                      controller: _tabController,
                      dividerHeight: 0,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      indicatorWeight: 2,
                      indicator: BoxDecoration(),
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
                        //selepart tab for color overlay
                        Tab(
                          icon: Icon(Icons.color_lens, size: 18),
                          text: 'Overlay',
                        ),

                        Tab(
                          icon: Icon(Icons.border_outer, size: 18),
                          text: 'Border',
                        ),
                        Tab(
                          icon: Icon(Icons.transform, size: 18),
                          text: 'Transform',
                        ),
                      ],
                    ),
                  ),
                  FloatingActionButton.small(
                    onPressed: () {
                      canvasController.duplicateItem();
                    },

                    child: Icon(Icons.control_point_duplicate, size: 16),
                  ),
                ],
              ),
            ),

            // Content Area with TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _AdjustPage(
                    imageEditorController: controller,
                    onUpdate: _updateImage,
                  ),
                  _FiltersPage(
                    imageEditorController: controller,
                    onUpdate: _updateImage,
                  ),
                  _EffectsPage(
                    imageEditorController: controller,
                    onUpdate: _updateImage,
                  ),

                  _ColorOverlayPage(
                    onUpdate: () {},
                    imageEditorController: controller,
                  ),
                  _BorderPage(
                    imageEditorController: controller,
                    onUpdate: _updateImage,
                  ),

                  _TransformPage(
                    imageEditorController: controller,
                    onUpdate: _updateImage,
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
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _AdjustPage({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,

      children: [
        SizedBox(height: 8),

        // Main slider area
        SizedBox(
          width: Get.width * 1.19,
          child: _ProfessionalSlider(
            imageEditorController: imageEditorController,
            onUpdate: onUpdate,
          ),
        ),
        SizedBox(height: 8),

        // Adjustment tools
        Expanded(
          child: _AdjustmentToolsRow(
            imageEditorController: imageEditorController,
            onSelectionChanged: (String adjustment) {
              imageEditorController.setSelectedAdjustment(adjustment);
            },
          ),
        ),
      ],
    );
  }
}

class _AdjustmentToolsRow extends StatelessWidget {
  final ImageEditorController imageEditorController;
  final Function(String) onSelectionChanged;

  const _AdjustmentToolsRow({
    required this.imageEditorController,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      id: 'adjustment_tools',
      builder: (controller) {
        final adjustments = _ImageAdjustmentConfig.getAdjustments(controller);

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: adjustments.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final tool = adjustments[index];
            final isSelected = controller.selectedAdjustment == tool.key;

            return GestureDetector(
              onTap: () => onSelectionChanged(tool.key),
              child: _AdjustmentToolButton(tool: tool, isSelected: isSelected),
            );
          },
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
      // width: 68,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: AppColors.brandingLight, width: 2)
                  : null,
            ),
            child: Icon(
              tool.icon,
              size: 20,
              color: isSelected ? AppColors.branding : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tool.label,
            style: TextStyle(
              // color: isSelected ? const Color(0xFFFFA500) : Colors.white70,
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
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _ProfessionalSlider({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      id: 'adjustment_slider',
      builder: (controller) {
        final config = _ImageAdjustmentConfig.getConfig(
          controller.selectedAdjustment,
        );
        final currentValue = controller.getAdjustmentValue(config.key);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: Get.width * 0.19),
          child: LayoutBuilder(
            builder: (context, constraint) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern slider with built-in label
                  SizedBox(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background track
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        // Active track
                        Positioned(
                          left: config.getTrackLeft(
                            currentValue,
                            constraint.maxWidth,
                          ),
                          width: config.getTrackWidth(
                            currentValue,
                            constraint.maxWidth,
                          ),
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.branding,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),

                        // Slider with custom theme and built-in label
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 0,
                            thumbColor: Get.theme.colorScheme.secondary,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                              // disabledThumbRadius: 6,
                              elevation: 0,
                            ),
                            overlayColor: AppColors.brandingLight,
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 8,
                            ),
                            valueIndicatorTextStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            showValueIndicator: ShowValueIndicator.always,
                          ),
                          child: Slider(
                            value: currentValue.clamp(config.min, config.max),
                            min: config.min,
                            max: config.max,
                            label: config.formatValue(currentValue),
                            onChanged: (value) {
                              controller.updateAdjustment(config.key, value);
                              onUpdate();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
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

  const _ImageAdjustmentConfig({
    required this.key,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.isBidirectional,
    required this.suffix,
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
      return (value / max) * trackWidth;
    }

    final range = max - min;
    final relativeValue = (value - defaultValue).abs() / range;
    return relativeValue * trackWidth;
  }

  static _ImageAdjustmentConfig getConfig(String adjustment) {
    return _configs[adjustment] ?? _configs['brightness']!;
  }

  static List<_AdjustmentTool> getAdjustments(
    ImageEditorController controller,
  ) {
    return [
      _AdjustmentTool(
        key: 'brightness',
        icon: Icons.brightness_6_outlined,
        label: 'Brightness',
        value: controller.getAdjustmentValue('brightness'),
      ),
      _AdjustmentTool(
        key: 'contrast',
        icon: Icons.contrast_outlined,
        label: 'Contrast',
        value: controller.getAdjustmentValue('contrast'),
      ),
      _AdjustmentTool(
        key: 'saturation',
        icon: Icons.water_drop_outlined,
        label: 'Saturation',
        value: controller.getAdjustmentValue('saturation'),
      ),
      _AdjustmentTool(
        key: 'hue',
        icon: Icons.palette_outlined,
        label: 'Hue',
        value: controller.getAdjustmentValue('hue'),
      ),
      _AdjustmentTool(
        key: 'opacity',
        icon: Icons.opacity_outlined,
        label: 'Opacity',
        value: controller.getAdjustmentValue('opacity'),
      ),
    ];
  }

  static final Map<String, _ImageAdjustmentConfig> _configs = {
    'brightness': _ImageAdjustmentConfig(
      key: 'brightness',
      min: -100.0,
      max: 100.0,
      defaultValue: 0.0,
      isBidirectional: true,
      suffix: '',
    ),
    'contrast': _ImageAdjustmentConfig(
      key: 'contrast',
      min: -100.0,
      max: 100.0,
      defaultValue: 0.0,
      isBidirectional: true,
      suffix: '',
    ),
    'saturation': _ImageAdjustmentConfig(
      key: 'saturation',
      min: -100.0,
      max: 100.0,
      defaultValue: 0.0,
      isBidirectional: true,
      suffix: '',
    ),
    'hue': _ImageAdjustmentConfig(
      key: 'hue',
      min: 0.0,
      max: 360.0,
      defaultValue: 0.0,
      isBidirectional: false,
      suffix: '°',
    ),
    'opacity': _ImageAdjustmentConfig(
      key: 'opacity',
      min: 0.0,
      max: 100.0,
      defaultValue: 100.0,
      isBidirectional: false,
      suffix: '%',
    ),
  };
}

class _FiltersPage extends StatelessWidget {
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _FiltersPage({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      id: 'filters_page',
      builder: (controller) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _getAvailableFilters().length,
        itemBuilder: (context, index) {
          final filter = _getAvailableFilters()[index];
          final isActive = controller.activeFilter == filter.key;

          return GestureDetector(
            onTap: () {
              controller.applyFilter(filter.key);
              onUpdate();
            },
            child: _FilterThumbnail(filter: filter, isActive: isActive),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
      ),
    );
  }

  List<_FilterData> _getAvailableFilters() {
    final iconMap = {
      ImageFilters.none: Icons.refresh,
      ImageFilters.grayscale: Icons.filter_b_and_w,
      ImageFilters.sepia: Icons.filter_1,
      ImageFilters.vintage: Icons.filter_vintage,
      ImageFilters.mood: Icons.mood,
      ImageFilters.crisp: Icons.hd,
      ImageFilters.cool: Icons.ac_unit,
      ImageFilters.blush: Icons.face,
      ImageFilters.sunkissed: Icons.wb_sunny,
      ImageFilters.fresh: Icons.eco,
      ImageFilters.classic: Icons.history,
      ImageFilters.lomo: Icons.camera_alt,
      ImageFilters.nashville: Icons.music_note,
      ImageFilters.valencia: Icons.wb_incandescent,
      ImageFilters.clarendon: Icons.brightness_high,
      ImageFilters.moon: Icons.nightlight_round,
      ImageFilters.kodak: Icons.photo_camera,
      ImageFilters.frost: Icons.ac_unit,
      ImageFilters.sunset: Icons.wb_twilight,
      ImageFilters.noir: Icons.movie_filter,
      ImageFilters.dreamy: Icons.cloud,
      ImageFilters.radium: Icons.flash_on,
      ImageFilters.aqua: Icons.water,
      ImageFilters.purplehaze: Icons.color_lens,
      ImageFilters.lemonade: Icons.local_drink,
      ImageFilters.caramel: Icons.coffee,
      ImageFilters.peachy: Icons.favorite,
      ImageFilters.coolblue: Icons.waves,
      ImageFilters.neon: Icons.flash_auto,
      ImageFilters.lush: Icons.park,
      ImageFilters.urbanneon: Icons.location_city,
      ImageFilters.moodymonochrome: Icons.sentiment_neutral,
      // You can add icons for any extra enum values if needed
    };

    return ImageFilters.values.map((filter) {
      final name = filter.name; // Enum name as string
      return _FilterData(
        key: name,
        name: filter.name.toUpperCase(),
        icon: iconMap[filter] ?? Icons.filter, // Default icon
      );
    }).toList();
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
    return SizedBox(
      // width: 66,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? Border.all(color: AppColors.brandingLight, width: 2)
                  : null,
            ),
            child: Icon(
              filter.icon,
              color: isActive ? AppColors.branding : null,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filter.name,
            style: TextStyle(
              color: isActive ? AppColors.branding : null,

              fontSize: 8,
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

class _ShapeBorderPage extends StatelessWidget {
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _ShapeBorderPage({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      id: 'shape_border_controls',
      builder: (controller) {
        // Only show controls when a shape is selected
        if (controller.selectedMaskShape == ImageMaskShape.none) {
          return const Center(
            child: Text(
              'Select a shape to customize its border',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Border Width
                CompactSlider(
                  icon: Icons.border_outer,
                  label: 'Border Width',
                  value: controller.shapeBorderWidth,
                  min: 0.0,
                  max: 20.0,
                  onChanged: (value) {
                    controller.setShapeBorderWidth(value);
                    onUpdate();
                  },
                ),

                const SizedBox(height: 12),

                // Border Color
                Row(
                  children: [
                    const Text(
                      'Border Color',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    _MiniColorButton(
                      color: controller.shapeBorderColor,
                      onTap: () => _showColorPicker(
                        context,
                        'Shape Border',
                        controller.shapeBorderColor,
                        (color) {
                          controller.setShapeBorderColor(color);
                          onUpdate();
                        },
                      ),
                    ),
                  ],
                ),

                // Border Radius (only for rounded rectangle)
                if (controller.selectedMaskShape ==
                    ImageMaskShape.roundedRectangle) ...[
                  const SizedBox(height: 12),
                  CompactSlider(
                    icon: Icons.rounded_corner,
                    label: 'Corner Radius',
                    value: controller.shapeBorderRadius,
                    min: 0.0,
                    max: 100.0,
                    onChanged: (value) {
                      controller.setShapeBorderRadius(value);
                      onUpdate();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
      builder: (context) => QuickColorPicker(
        title: title,
        currentColor: currentColor,
        onChanged: onChanged,
      ),
    );
  }
}

class _EffectsPage extends StatelessWidget {
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _EffectsPage({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        const SizedBox(height: 8),

        // Mask Shapes
        _buildMaskPresets(),

        // Vignette Effect
        const SizedBox(height: 8),
        _buildVignetteSlider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMaskPresets() {
    return Expanded(
      child: GetBuilder<ImageEditorController>(
        id: 'mask_presets',
        builder: (controller) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: ImageMaskShape.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final shape = ImageMaskShape.values[index];
              return _buildShapeOption(shape);
            },
          );
        },
      ),
    );
  }

  Widget _buildShapeOption(ImageMaskShape shape) {
    return GetBuilder<ImageEditorController>(
      id: 'shape_option',
      builder: (controller) {
        final isSelected = controller.selectedMaskShape == shape;
        return Stack(
          alignment: Alignment.center,
          children: [
            InkWell(
              onTap: () {
                controller.setMaskShape(shape);

                if (shape != ImageMaskShape.none &&
                    controller.shapeBorderWidth == 0 &&
                    controller.shapeBorderColor == null) {
                  controller.setShapeBorderWidth(2);
                  controller.setShapeBorderColor(Colors.black);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 55,

                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.branding.withOpacity(0.09)
                      : Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppColors.branding, width: 1)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        // width: 56,
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: _getShapeIcon(shape, isSelected)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isSelected && shape != ImageMaskShape.none)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _showShapeSettingsBottomSheet(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.tune, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showShapeSettingsBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ShapeSettingsBottomSheet(
          controller: imageEditorController,
          onUpdate: onUpdate,
        ),
      ),
    );
  }

  Widget _getShapeIcon(ImageMaskShape shape, bool isSelected) {
    switch (shape) {
      case ImageMaskShape.circle:
        return Icon(
          Icons.circle_outlined,
          size: 30,
          color: isSelected ? AppColors.branding : null,
        );
      case ImageMaskShape.roundedRectangle:
        return Icon(
          Icons.crop_square_rounded,
          size: 30,
          color: isSelected ? AppColors.branding : null,
        );
      case ImageMaskShape.star:
        return Icon(
          Icons.star_border,
          size: 30,
          color: isSelected ? AppColors.branding : null,
        );
      case ImageMaskShape.heart:
        return Icon(
          Icons.favorite_border,
          size: 28,
          color: isSelected ? AppColors.branding : null,
        );
      case ImageMaskShape.hexagon:
        return Icon(
          Icons.hexagon_outlined,
          size: 28,
          color: isSelected ? AppColors.branding : null,
        );
      case ImageMaskShape.none:
        return Icon(
          Icons.layers_clear_outlined,
          size: 28,
          color: isSelected ? AppColors.branding : Colors.grey.shade600,
        );
    }
  }

  Widget _buildVignetteSlider() {
    return GetBuilder<ImageEditorController>(
      id: 'vignette_slider',
      builder: (controller) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: Get.width * 0.19),
          child: CompactSlider(
            icon: Icons.vignette,
            label: "Vignette",
            value: controller.selectedImageItem?.content?.vignette ?? 0.0,
            min: 0.0,
            max: 1.0,
            onChanged: controller.setVignette,
          ),
        );
      },
    );
  }
}

class ShapeSettingsBottomSheet extends StatelessWidget {
  final ImageEditorController controller;
  final VoidCallback onUpdate;

  const ShapeSettingsBottomSheet({
    required this.controller,
    required this.onUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.shadowColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Border Width
                GetBuilder<ImageEditorController>(
                  id: 'shape_border_width',
                  builder: (controller) {
                    return CompactSlider(
                      label: "Border Width",
                      icon: Icons.border_outer,
                      value: controller.shapeBorderWidth,
                      min: 0.0,
                      max: 20.0,
                      onChanged: (value) {
                        controller.setShapeBorderWidth(value);
                      },
                    );
                  },
                ),

                // Border Radius (only for rounded rectangle)
                if (controller.selectedMaskShape ==
                    ImageMaskShape.roundedRectangle) ...[
                  const SizedBox(height: 16),
                  GetBuilder<ImageEditorController>(
                    id: 'shape_border_radius',
                    builder: (controller) {
                      return CompactSlider(
                        label: "Border Radius",
                        icon: Icons.rounded_corner,
                        value: controller.shapeBorderRadius,
                        min: 0.0,
                        max: 100.0,
                        onChanged: (value) {
                          controller.setShapeBorderRadius(value);
                          onUpdate();
                        },
                      );
                    },
                  ),
                ],

                // Border Color
                GetBuilder<ImageEditorController>(
                  id: 'shape_border_color',

                  builder: (controller) {
                    return ColorSelector(
                      title: 'Border Color',
                      colors: TextStyleController.predefinedColors,
                      currentColor:
                          controller.shapeBorderColor ?? Colors.transparent,
                      onColorSelected: (color) {
                        controller.setShapeBorderColor(color);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(2),
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
      builder: (context) => QuickColorPicker(
        title: title,
        currentColor: currentColor,
        onChanged: onChanged,
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color != null
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.7),
            width: 1,
          ),
        ),
        child: color == null
            ? const Center(child: Icon(Icons.colorize, size: 16))
            : null,
      ),
    );
  }
}

class _ColorOverlayPage extends StatelessWidget {
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _ColorOverlayPage({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      null, // For "no color"
      ...Colors.primaries.take(55).map((color) => color.withOpacity(0.3)),
    ];

    return GetBuilder<ImageEditorController>(
      id: 'color_overlay_page',
      builder: (controller) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: colors.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final color = colors[index];
            final isActive = color == null
                ? controller.overlayColor == null
                : controller.overlayColor?.value == color.value;

            return _ColorChip(
              color: color,
              isActive: isActive,
              onTap: () {
                controller.setOverlayColor(color);
                if (color != null) {
                  controller.setOverlayBlendMode(BlendMode.overlay);
                }
                onUpdate();
              },
            );
          },
        );
      },
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 55,
            height: 55,
            // margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? Border.all(color: AppColors.branding, width: 1)
                  : null,
            ),
            child: color == null
                ? Icon(
                    Icons.block,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  )
                : null,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '#${color?.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
          style: TextStyle(
            color: isActive ? AppColors.branding : null,

            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _BorderPage extends StatelessWidget {
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _BorderPage({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      id: 'border_page',
      builder: (controller) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GetBuilder<ImageEditorController>(
                      id: 'border_width',
                      builder: (controller) {
                        return CompactSlider(
                          icon: Icons.border_outer,
                          value: controller.borderWidth,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (v) {
                            controller.setBorderWidth(v);
                            onUpdate();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GetBuilder<ImageEditorController>(
                      id: 'border_radius',

                      builder: (controller) {
                        return CompactSlider(
                          icon: Icons.rounded_corner,
                          value: controller.borderRadius,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (v) {
                            controller.setBorderRadius(v);
                            onUpdate();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GetBuilder<ImageEditorController>(
                      id: 'shadow_blur',
                      builder: (controller) {
                        return CompactSlider(
                          icon: Icons.blur_on,
                          value: controller.shadowBlur,
                          min: 0.0,
                          max: 20.0,
                          onChanged: (v) {
                            controller.setShadowBlur(v);
                            onUpdate();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      GetBuilder<ImageEditorController>(
                        id: 'border_color',
                        builder: (controller) {
                          return _MiniColorButton(
                            color: controller.borderColor,
                            onTap: () => _showColorPicker(
                              context,
                              'Border',
                              controller.borderColor,
                              (color) {
                                controller.setBorderColor(color);
                                onUpdate();
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      GetBuilder<ImageEditorController>(
                        id: 'shadow_color',
                        builder: (controller) {
                          return _MiniColorButton(
                            color: controller.shadowColor,
                            onTap: () => _showColorPicker(
                              context,
                              'Shadow',
                              controller.shadowColor,
                              (color) {
                                controller.setShadowColor(color);
                                onUpdate();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: CompactSlider(
                      icon: Icons.open_with,
                      label: 'Shadow Offset X',
                      value:
                          controller
                              .selectedImageItem
                              ?.content
                              ?.shadowOffset
                              .dx ??
                          0.0,
                      min: -20.0,
                      max: 20.0,
                      onChanged: (v) {
                        controller.setShadowOffset(
                          Offset(
                            v,
                            controller
                                    .selectedImageItem
                                    ?.content
                                    ?.shadowOffset
                                    .dy ??
                                0.0,
                          ),
                        );
                        onUpdate();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CompactSlider(
                      icon: Icons.open_with,
                      label: 'Shadow Offset Y',
                      value:
                          controller
                              .selectedImageItem
                              ?.content
                              ?.shadowOffset
                              .dy ??
                          0.0,
                      min: -20.0,
                      max: 20.0,
                      onChanged: (v) {
                        controller.setShadowOffset(
                          Offset(
                            controller
                                    .selectedImageItem
                                    ?.content
                                    ?.shadowOffset
                                    .dx ??
                                0.0,
                            v,
                          ),
                        );
                        onUpdate();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      // backgroundColor: const Color(0xFF1C1C1E),
      builder: (context) => QuickColorPicker(
        title: title,
        currentColor: currentColor,
        onChanged: onChanged,
      ),
    );
  }
}

class _TransformPage extends StatelessWidget {
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _TransformPage({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rotation slider
          GetBuilder<ImageEditorController>(
            id: 'rotation_slider',

            builder: (controller) {
              return CompactSlider(
                icon: Icons.rotate_right,
                label: 'Rotation',
                value: controller.rotationAngle,
                min: -180.0,
                max: 180.0,
                onChanged: (v) {
                  controller.setRotationAngle(v);
                  onUpdate();
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Flip buttons
          GetBuilder<ImageEditorController>(
            id: "flip_buttons",
            builder: (controller) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: controller.flipHorizontal
                            ? AppColors.branding
                            : Get.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            controller.setFlipHorizontal(
                              !controller.flipHorizontal,
                            );
                            onUpdate();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flip,
                                // color: controller.flipHorizontal
                                //     ? Colors.black
                                //     : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Flip H',
                                style: TextStyle(
                                  // color: controller.flipHorizontal
                                  //     ? Colors.black
                                  //     : Colors.white,
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
                      height: 40,
                      decoration: BoxDecoration(
                        color: controller.flipVertical
                            ? AppColors.branding
                            : Get.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            controller.setFlipVertical(
                              !controller.flipVertical,
                            );
                            onUpdate();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.rotate(
                                angle: 1.5708, // 90 degrees
                                child: Icon(
                                  Icons.flip,
                                  // color: controller.flipVertical
                                  //     ? Colors.black
                                  //     : Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Flip V',
                                style: TextStyle(
                                  // color: controller.flipVertical
                                  //     ? Colors.black
                                  //     : Colors.white,
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
              );
            },
          ),

          // Quick rotation buttons

          /*
          const SizedBox(height: 8),

          GetBuilder<ImageEditorController>(
            id: "rotations",
            builder: (controller) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RotationButton(
                    angle: -90,
                    onTap: () {
                      controller.rotateQuick(-90);
                      onUpdate();
                    },
                  ),
                  _RotationButton(
                    angle: 0,
                    onTap: () {
                      controller.setRotationAngle(0);
                      onUpdate();
                    },
                  ),
                  _RotationButton(
                    angle: 90,
                    onTap: () {
                      controller.rotateQuick(90);
                      onUpdate();
                    },
                  ),
                  _RotationButton(
                    angle: 180,
                    onTap: () {
                      controller.setRotationAngle(180);
                      onUpdate();
                    },
                  ),
                ],
              );
            },
          ),
     
     */
        ],
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
          color: isActive
              ? AppColors.brandingLight.withValues(alpha: 0.05)
              : Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(color: AppColors.brandingLight, width: 2)
              : null,
        ),
        child: Icon(
          _getShapeIcon(shape),
          color: isActive ? AppColors.brandingLight : null,
          size: 24,
        ),
      ),
    );
  }

  IconData _getShapeIcon(ImageMaskShape shape) {
    switch (shape) {
      case ImageMaskShape.none:
        return Icons.crop_free_outlined;
      case ImageMaskShape.circle:
        return Icons.circle_outlined;
      case ImageMaskShape.roundedRectangle:
        return Icons.rounded_corner_outlined;
      case ImageMaskShape.star:
        return Icons.star_outline;
      case ImageMaskShape.heart:
        return Icons.favorite_outline;
      case ImageMaskShape.hexagon:
        return Icons.hexagon_outlined;
    }
  }
}

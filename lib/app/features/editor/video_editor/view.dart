import 'package:cardmaker/app/features/editor/video_editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/stack_board/lib/stack_case.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

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

  void _updateImage() {
    // Trigger local update
    setState(() {});
    widget.onUpdate();

    // The ImageEditorController will handle notifying other controllers
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      id: 'panel_container',
      builder: (controller) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        // curve: Curves.easeOutCubic,
        height: _tabController.index < 2 ? 160 : 250,
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
              height: 50,
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
                  Tab(icon: Icon(Icons.border_outer, size: 18), text: 'Border'),
                  Tab(icon: Icon(Icons.transform, size: 18), text: 'Transform'),
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
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _AdjustmentToolsRow(
              imageEditorController: imageEditorController,
              onSelectionChanged: (String adjustment) {
                imageEditorController.setSelectedAdjustment(adjustment);
              },
            ),
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
      builder: (controller) => Column(
        children: [
          // Filter Grid
          Expanded(
            child: ListView.separated(
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
          ),

          // Row(
          //   children: [
          //     Expanded(
          //       child: _CompactSlider(
          //         icon: Icons.vignette,
          //         label: 'Vignette',
          //         value: controller.borderRadius,
          //         min: 0.0,
          //         max: 50.0,
          //         onChanged: (v) {
          //           controller.setBorderRadius(v);
          //           onUpdate();
          //         },
          //       ),
          //     ),
          //   ],
          // ),
        ],
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

class _EffectsPage extends StatelessWidget {
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _EffectsPage({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      id: 'effects_page',
      builder: (controller) => Column(
        children: [
          const SizedBox(height: 8),
          // Mask Shapes
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ImageMaskShape.values.length,
              itemBuilder: (context, index) {
                final shape = ImageMaskShape.values[index];
                return _MaskButton(
                  shape: shape,
                  isActive: controller.selectedMaskShape == shape,
                  onTap: () {
                    controller.setMaskShape(shape);
                    onUpdate();
                  },
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
            ),
          ),

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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _ColorChip(
                  color: null,
                  isActive: controller.overlayColor == null,
                  onTap: () {
                    controller.setOverlayColor(null);
                    onUpdate();
                  },
                ),
                ...Colors.primaries.take(8).map((color) {
                  return _ColorChip(
                    color: color.withOpacity(0.3),
                    isActive:
                        controller.overlayColor?.value ==
                        color.withOpacity(0.3).value,
                    onTap: () {
                      controller.setOverlayColor(color.withOpacity(0.3));
                      controller.setOverlayBlendMode(BlendMode.overlay);
                      onUpdate();
                    },
                  );
                }),
              ],
            ),
          ),
          /*
          // Noise Effect
          const SizedBox(height: 8),
          Text(
            'Noise',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: controller.selectedImageItem?.content?.noiseIntensity ?? 0.0,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            onChanged: (value) {
              if (controller.selectedImageItem?.content != null) {
                controller.selectedImageItem!.content!.noiseIntensity = value;
                controller.update(['effects_page']);
                onUpdate();
              }
            },
          ),

          */

          // Vignette Effect
          const SizedBox(height: 8),
          Text(
            'Vignette',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: controller.selectedImageItem?.content?.vignette ?? 0.0,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            onChanged: (value) {
              if (controller.selectedImageItem?.content != null) {
                controller.selectedImageItem!.content!.vignette = value;
                controller.update(['effects_page']);
                onUpdate();
              }
            },
          ),
        ],
      ),
    );
  }
}

/*
class _EffectsPage extends StatelessWidget {
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _EffectsPage({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      id: 'effects_page',
      builder: (controller) => Column(
        children: [
          SizedBox(height: 8),
          //covert to Listview.buidler
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ImageMaskShape.values.length,
              itemBuilder: (context, index) {
                final shape = ImageMaskShape.values[index];
                return _MaskButton(
                  shape: shape,
                  isActive: controller.selectedMaskShape == shape,
                  onTap: () {
                    controller.setMaskShape(shape);
                    onUpdate();
                  },
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
            ),
          ),

    

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
                  isActive: controller.overlayColor == null,
                  onTap: () {
                    controller.setOverlayColor(null);
                    onUpdate();
                  },
                ),
                ...Colors.primaries.take(8).map((color) {
                  return _ColorChip(
                    color: color.withOpacity(0.3),
                    isActive:
                        controller.overlayColor?.value ==
                        color.withOpacity(0.3).value,
                    onTap: () {
                      controller.setOverlayColor(color.withOpacity(0.3));
                      controller.setOverlayBlendMode(BlendMode.overlay);
                      onUpdate();
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
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
      builder: (controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _CompactSlider(
                    icon: Icons.border_outer,
                    value: controller.borderWidth,
                    min: 0.0,
                    max: 50.0,
                    onChanged: (v) {
                      controller.setBorderWidth(v);
                      onUpdate();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactSlider(
                    icon: Icons.rounded_corner,
                    value: controller.borderRadius,
                    min: 0.0,
                    max: 100.0,
                    onChanged: (v) {
                      controller.setBorderRadius(v);
                      onUpdate();
                    },
                  ),
                ),
              ],
            ),

            if (controller.isExpanded) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _CompactSlider(
                      icon: Icons.blur_on,
                      value: controller.shadowBlur,
                      min: 0.0,
                      max: 20.0,
                      onChanged: (v) {
                        controller.setShadowBlur(v);
                        onUpdate();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      _MiniColorButton(
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
                      ),
                      const SizedBox(height: 4),
                      _MiniColorButton(
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

class _TransformPage extends StatelessWidget {
  final ImageEditorController imageEditorController;
  final VoidCallback onUpdate;

  const _TransformPage({
    required this.imageEditorController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      id: 'transform_page',
      builder: (controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Rotation slider
            _CompactSlider(
              icon: Icons.rotate_right,
              label: 'Rotation',
              value: controller.rotationAngle,
              min: -180.0,
              max: 180.0,
              onChanged: (v) {
                controller.setRotationAngle(v);
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
                      color: controller.flipHorizontal
                          ? const Color(0xFFFFA500)
                          : const Color(0xFF2A2A2A),
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
                              color: controller.flipHorizontal
                                  ? Colors.black
                                  : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Flip H',
                              style: TextStyle(
                                color: controller.flipHorizontal
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
                      color: controller.flipVertical
                          ? const Color(0xFFFFA500)
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          controller.setFlipVertical(!controller.flipVertical);
                          onUpdate();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: 1.5708, // 90 degrees
                              child: Icon(
                                Icons.flip,
                                color: controller.flipVertical
                                    ? Colors.black
                                    : Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Flip V',
                              style: TextStyle(
                                color: controller.flipVertical
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

            if (controller.isExpanded) ...[
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
          color: Get.theme.colorScheme.surface,
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
          border: Border.all(color: Colors.white24, width: 1),
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

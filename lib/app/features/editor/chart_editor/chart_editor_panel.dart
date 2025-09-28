import 'package:cardmaker/app/features/editor/chart_editor/chart_editor_controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:cardmaker/widgets/common/quick_color_picker.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_chart_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChartEditorPanel extends StatelessWidget {
  final StackChartItem? chartItem;
  final VoidCallback onClose;

  final ChartEditorController controller = Get.put(ChartEditorController());

  ChartEditorPanel({super.key, this.chartItem, required this.onClose});

  @override
  Widget build(BuildContext context) {
    // Initialize controller based on whether we're adding or editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chartItem != null) {
        controller.initWithItem(chartItem!);
      } else {
        controller.resetForNewChart();
      }
    });

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onClose,
      child: Material(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Expanded(
                child: GetBuilder<ChartEditorController>(
                  id: 'chart_editor',
                  builder: (controller) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildChartTypeSection(controller),
                          const SizedBox(height: 10),
                          _buildProgressSection(controller),
                          const SizedBox(height: 10),
                          _buildAppearanceSection(controller),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.branding.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              size: 14,
              color: AppColors.branding,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            chartItem == null ? 'Add Chart' : 'Edit Chart',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSection(ChartEditorController controller) {
    return _buildSection(
      'Type',
      Icons.analytics_outlined,
      child: Row(
        children: ChartType.values.map((type) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Obx(() {
                final isSelected = controller.chartType.value == type;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.updateChartType(type),
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.branding
                            : Get.theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.branding
                              : Get.theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getChartTypeIcon(type),
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : Get.theme.colorScheme.onSurface,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getChartTypeName(type),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Get.theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressSection(ChartEditorController controller) {
    return _buildSection(
      'Settings',
      Icons.tune_rounded,
      child: Column(
        children: [
          Obx(
            () => CompactSlider(
              icon: Icons.percent_rounded,
              value: controller.value.value,
              min: 0,
              max: 100,
              onChanged: controller.updateValue,
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () => CompactSlider(
              icon: Icons.line_weight_rounded,
              value: controller.thickness.value,
              min: 1,
              max: 50,
              onChanged: controller.updateThickness,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(ChartEditorController controller) {
    return _buildSection(
      'Colors',
      Icons.palette_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildColorPicker(
                    'BG',
                    controller.backgroundColor.value,
                    controller.updateBackgroundColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Obx(
                  () => _buildColorPicker(
                    'Progress',
                    controller.progressColor.value,
                    controller.updateProgressColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Obx(
                  () => _buildColorPicker(
                    'Text',
                    controller.textColor.value,
                    controller.updateTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildCompactSwitch(
                    'Text',
                    Icons.text_fields_rounded,
                    controller.showValueText.value,
                    controller.updateShowValueText,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Obx(
                  () => _buildCompactSwitch(
                    'Glow',
                    Icons.auto_awesome_rounded,
                    controller.glowEffect.value,
                    controller.updateGlowEffect,
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            if (controller.chartType.value == ChartType.linearProgress) {
              return Column(
                children: [
                  const SizedBox(height: 6),
                  CompactSlider(
                    icon: Icons.rounded_corner,
                    value: controller.cornerRadius.value,
                    min: 0,
                    max: 50,
                    onChanged: controller.updateCornerRadius,
                  ),
                ],
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
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
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surfaceContainerHighest.withOpacity(
              0.3,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Get.theme.colorScheme.outline.withOpacity(0.08),
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    String label,
    Color color,
    Function(Color) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 3),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showColorPicker(label, color, onChanged),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Get.theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSwitch(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.branding,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(
    String title,
    Color currentColor,
    Function(Color) onChanged,
  ) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickColorPicker(
        title: title,
        currentColor: currentColor,
        onChanged: (color) => onChanged(color!),
      ),
    );
  }

  IconData _getChartTypeIcon(ChartType type) {
    switch (type) {
      case ChartType.linearProgress:
        return Icons.linear_scale_rounded;
      case ChartType.circularProgress:
        return Icons.donut_large_rounded;
      case ChartType.radialProgress:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  String _getChartTypeName(ChartType type) {
    switch (type) {
      case ChartType.linearProgress:
        return 'Linear';
      case ChartType.circularProgress:
        return 'Circular';
      case ChartType.radialProgress:
        return 'Radial';
    }
  }
}
// chart_editor_panel.dart
// import 'package:cardmaker/app/features/editor/chart_editor/chart_editor_controller.dart';
// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:cardmaker/core/values/enums.dart';
// import 'package:cardmaker/widgets/common/compact_slider.dart';
// import 'package:cardmaker/widgets/common/quick_color_picker.dart';
// import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_chart_item.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ChartEditorPanel extends StatelessWidget {
//   final StackChartItem? chartItem;
//   final VoidCallback onClose;

//   final ChartEditorController controller = Get.put(ChartEditorController());

//   ChartEditorPanel({super.key, this.chartItem, required this.onClose});

//   @override
//   Widget build(BuildContext context) {
//     // Initialize controller based on whether we're adding or editing
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (chartItem != null) {
//         controller.initWithItem(chartItem!);
//       } else {
//         controller.resetForNewChart();
//       }
//     });

//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: onClose,
//       child: Material(
//         child: Container(
//           constraints: const BoxConstraints(maxHeight: 300),
//           decoration: BoxDecoration(
//             color: Get.theme.colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHeader(),
//               Expanded(
//                 child: GetBuilder<ChartEditorController>(
//                   id: 'chart_editor',
//                   builder: (controller) {
//                     return ListView(
//                       padding: const EdgeInsets.all(12),
//                       children: [
//                         _buildChartTypeSection(controller),
//                         const SizedBox(height: 8),
//                         _buildProgressSection(controller),
//                         const SizedBox(height: 8),
//                         _buildAppearanceSection(controller),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       height: 44,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Get.theme.colorScheme.surfaceContainer,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.bar_chart, size: 18, color: AppColors.branding),
//           const SizedBox(width: 8),
//           Text(
//             chartItem == null ? 'Add Chart' : 'Edit Chart',
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//           ),
//           const Spacer(),
//           IconButton(
//             icon: const Icon(Icons.close, size: 18),
//             onPressed: onClose,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChartTypeSection(ChartEditorController controller) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Get.theme.colorScheme.surfaceContainer,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: ChartType.values.map((type) {
//           return Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 2),
//               child: Obx(() {
//                 final isSelected = controller.chartType.value == type;
//                 return Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () => controller.updateChartType(type),
//                     borderRadius: BorderRadius.circular(6),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? AppColors.branding
//                             : Get.theme.colorScheme.surface,
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(
//                           color: isSelected
//                               ? AppColors.branding
//                               : Get.theme.colorScheme.outline.withOpacity(0.2),
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           Icon(
//                             _getChartTypeIcon(type),
//                             size: 14,
//                             color: isSelected
//                                 ? Colors.white
//                                 : Get.theme.colorScheme.onSurface,
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             _getChartTypeName(type),
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.w500,
//                               color: isSelected
//                                   ? Colors.white
//                                   : Get.theme.colorScheme.onSurface,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildProgressSection(ChartEditorController controller) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Get.theme.colorScheme.surfaceContainer,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Obx(
//             () => CompactSlider(
//               icon: Icons.speed,
//               value: controller.value.value,
//               min: 0,
//               max: 100,
//               onChanged: controller.updateValue,
//               division: 100,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Obx(
//             () => CompactSlider(
//               icon: Icons.line_weight,
//               value: controller.thickness.value,
//               min: 1,
//               max: 30,
//               onChanged: controller.updateThickness,
//               division: 29,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppearanceSection(ChartEditorController controller) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Get.theme.colorScheme.surfaceContainer,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           // Color Picker Row
//           Row(
//             children: [
//               Expanded(
//                 child: _buildColorChip(
//                   'Background',
//                   controller.backgroundColor.value,
//                   controller.updateBackgroundColor,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: _buildColorChip(
//                   'Progress',
//                   controller.progressColor.value,
//                   controller.updateProgressColor,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: _buildColorChip(
//                   'Text',
//                   controller.textColor.value,
//                   controller.updateTextColor,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           // Toggle Switches
//           Row(
//             children: [
//               Expanded(
//                 child: _buildToggle(
//                   'Show Text',
//                   controller.showValueText.value,
//                   controller.updateShowValueText,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _buildToggle(
//                   'Glow',
//                   controller.glowEffect.value,
//                   controller.updateGlowEffect,
//                 ),
//               ),
//             ],
//           ),
//           // Corner Radius for Linear Progress
//           Obx(() {
//             if (controller.chartType.value == ChartType.linearProgress) {
//               return Column(
//                 children: [
//                   const SizedBox(height: 8),
//                   CompactSlider(
//                     icon: Icons.rounded_corner,
//                     value: controller.cornerRadius.value,
//                     min: 0,
//                     max: 25,
//                     onChanged: controller.updateCornerRadius,
//                     division: 25,
//                   ),
//                 ],
//               );
//             }
//             return const SizedBox();
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildColorChip(String label, Color color, Function(Color) onChanged) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w500,
//             color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
//           ),
//         ),
//         const SizedBox(height: 4),
//         GestureDetector(
//           onTap: () => _showColorPicker(label, color, onChanged),
//           child: Container(
//             width: 28,
//             height: 20,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(4),
//               border: Border.all(
//                 color: Get.theme.colorScheme.outline.withOpacity(0.3),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: Get.theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//                 color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
//               ),
//             ),
//           ),
//           Transform.scale(
//             scale: 0.8,
//             child: Switch(
//               value: value,
//               onChanged: onChanged,
//               activeThumbColor: AppColors.branding,
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showColorPicker(
//     String title,
//     Color currentColor,
//     Function(Color) onChanged,
//   ) {
//     showModalBottomSheet(
//       context: Get.context!,
//       backgroundColor: Colors.transparent,
//       builder: (context) => QuickColorPicker(
//         title: title,
//         currentColor: currentColor,
//         onChanged: (color) => onChanged(color!),
//       ),
//     );
//   }

//   IconData _getChartTypeIcon(ChartType type) {
//     switch (type) {
//       case ChartType.linearProgress:
//         return Icons.linear_scale;
//       case ChartType.circularProgress:
//         return Icons.donut_large;
//       case ChartType.radialProgress:
//         return Icons.radio_button_unchecked;
//     }
//   }

//   String _getChartTypeName(ChartType type) {
//     switch (type) {
//       case ChartType.linearProgress:
//         return 'Linear';
//       case ChartType.circularProgress:
//         return 'Circular';
//       case ChartType.radialProgress:
//         return 'Radial';
//     }
//   }
// }

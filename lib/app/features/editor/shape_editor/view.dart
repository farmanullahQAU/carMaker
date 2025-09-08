// // // advanced_shape_panel.dart
// // import 'package:cardmaker/app/features/editor/shape_editor/controller.dart';
// // import 'package:cardmaker/app/features/editor/text_editor/controller.dart';
// // import 'package:cardmaker/core/values/app_colors.dart';
// // import 'package:cardmaker/widgets/common/colors_selector.dart';
// // import 'package:cardmaker/widgets/common/compact_slider.dart';
// // import 'package:cardmaker/widgets/common/quick_color_picker.dart';
// // import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:morphable_shape/morphable_shape.dart';
// // shape_styling_editor.dart - Advanced Shape Editor
// // shape_editor_panel.dart
// import 'package:cardmaker/app/features/editor/shape_editor/controller.dart';
// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:cardmaker/widgets/common/compact_slider.dart';
// import 'package:cardmaker/widgets/common/quick_color_picker.dart';
// import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:morphable_shape/morphable_shape.dart';

// class ShapeEditorPanel extends StatefulWidget {
//   final StackShapeItem? shapeItem;
//   final VoidCallback onClose;
//   final Function(StackShapeItem) onApply;

//   const ShapeEditorPanel({
//     super.key,
//     this.shapeItem,
//     required this.onClose,
//     required this.onApply,
//   });

//   @override
//   State<ShapeEditorPanel> createState() => _ShapeEditorPanelState();
// }

// class _ShapeEditorPanelState extends State<ShapeEditorPanel> {
//   final ShapeEditorController _controller = Get.put(ShapeEditorController());
//   final _pageController = PageController();
//   final _currentTab = 0.obs; // 0: Templates, 1: Customize

//   @override
//   void initState() {
//     super.initState();

//     if (widget.shapeItem != null) {
//       _controller.initializeProperties(widget.shapeItem!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Get.theme.colorScheme.surface,
//       child: Container(
//         width: 360,
//         decoration: BoxDecoration(
//           color: Get.theme.colorScheme.surface,
//           border: Border(left: BorderSide(color: Colors.grey.shade200)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 12,
//               offset: const Offset(-4, 0),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             _buildHeader(),
//             _buildTabBar(),
//             _buildPreviewSection(),
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [_buildTemplatesTab(), _buildCustomizeTab()],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       height: 56,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Get.theme.colorScheme.surface,
//         border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.auto_awesome_mosaic, color: AppColors.branding, size: 20),
//           const SizedBox(width: 10),
//           const Text(
//             'Shape Editor',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//           const Spacer(),
//           IconButton(
//             icon: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
//             onPressed: widget.onClose,
//             tooltip: 'Close',
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabBar() {
//     return Obx(
//       () => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
//         ),
//         child: Row(
//           children: [
//             _buildTabButton('Templates', 0),
//             const SizedBox(width: 8),
//             _buildTabButton('Customize', 1),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabButton(String text, int index) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           _currentTab.value = index;
//           _pageController.animateToPage(
//             index,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//           );
//         },
//         child: Container(
//           height: 36,
//           decoration: BoxDecoration(
//             color: _currentTab.value == index
//                 ? AppColors.branding.withOpacity(0.1)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Center(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: _currentTab.value == index
//                     ? AppColors.branding
//                     : Colors.grey.shade700,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPreviewSection() {
//     return GetBuilder<ShapeEditorController>(
//       builder: (controller) {
//         return Container(
//           height: 120,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 96,
//                 height: 96,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey.shade200),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Container(
//                     width: 64,
//                     height: 64,
//                     decoration: ShapeDecoration(
//                       shape:
//                           controller.currentShapeItem?.content?.shapeBorder ??
//                           RectangleShapeBorder(),
//                       color: controller.fillColor.value.withOpacity(
//                         controller.fillOpacity.value,
//                       ),
//                       shadows: controller.buildShadows(),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Preview',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Obx(
//                       () => Text(
//                         _getShapeTypeName(controller),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Container(
//                           width: 16,
//                           height: 16,
//                           decoration: BoxDecoration(
//                             color: controller.fillColor.value.withOpacity(
//                               controller.fillOpacity.value,
//                             ),
//                             borderRadius: BorderRadius.circular(4),
//                             border: Border.all(color: Colors.grey.shade300),
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Container(
//                           width: 16,
//                           height: 16,
//                           decoration: BoxDecoration(
//                             color: Colors.transparent,
//                             borderRadius: BorderRadius.circular(4),
//                             border: Border.all(
//                               color: controller.borderColor.value,
//                               width: controller.borderWidth.value,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   String _getShapeTypeName(ShapeEditorController controller) {
//     // Access the shape type through the controller's internal property
//     // This is a workaround since currentShapeType isn't directly accessible
//     final shape = controller.currentShapeItem?.content?.shapeBorder;

//     if (shape is RectangleShapeBorder) {
//       return 'Rectangle';
//     } else if (shape is CircleShapeBorder) {
//       return 'Circle';
//     } else if (shape is PolygonShapeBorder) {
//       return 'Polygon (${controller.polygonSides.value} sides)';
//     } else if (shape is StarShapeBorder) {
//       return 'Star (${controller.starPoints.value} points)';
//     } else if (shape is ArrowShapeBorder) {
//       return 'Arrow';
//     } else if (shape is BubbleShapeBorder) {
//       return 'Speech Bubble';
//     } else {
//       return 'Shape';
//     }
//   }

//   Widget _buildTemplatesTab() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Shape Templates',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade800,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//                 childAspectRatio: 1.0,
//               ),
//               itemCount: _controller.professionalTemplates.length,
//               itemBuilder: (context, index) {
//                 final template = _controller.professionalTemplates[index];
//                 return _buildTemplateCard(template);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTemplateCard(ShapeTemplate template) {
//     return GestureDetector(
//       onTap: () {
//         _controller.applyTemplate(template);
//         _currentTab.value = 1;
//         _pageController.animateToPage(
//           1,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(color: Colors.grey.shade100),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: ShapeDecoration(
//                 shape: template.shape,
//                 color: AppColors.branding,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               template.name,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey.shade800,
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomizeTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: GetBuilder<ShapeEditorController>(
//         builder: (controller) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildFillSection(controller),
//               const SizedBox(height: 16),
//               _buildBorderSection(controller),
//               const SizedBox(height: 16),
//               _buildShapeSpecificSection(controller),
//               const SizedBox(height: 16),
//               _buildEffectsSection(controller),
//               const SizedBox(height: 20),
//               _buildActionButtons(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildShapeSpecificSection(ShapeEditorController controller) {
//     final shapeControls = controller.getShapeSpecificControls();

//     if (shapeControls.isEmpty ||
//         (shapeControls.first is SizedBox && shapeControls.length == 1)) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Shape Properties',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade800,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: Column(children: shapeControls),
//         ),
//       ],
//     );
//   }

//   Widget _buildFillSection(ShapeEditorController controller) {
//     return _buildSection(
//       title: 'Fill',
//       children: [
//         _buildColorPickerRow(
//           'Color',
//           controller.fillColor.value,
//           controller.updateFillColor,
//         ),
//         const SizedBox(height: 12),
//         CompactSlider(
//           icon: Icons.opacity,
//           label: 'Opacity',
//           value: controller.fillOpacity.value,
//           min: 0,
//           max: 1,
//           onChanged: controller.updateFillOpacity,
//         ),
//       ],
//     );
//   }

//   Widget _buildBorderSection(ShapeEditorController controller) {
//     return _buildSection(
//       title: 'Border',
//       children: [
//         CompactSlider(
//           icon: Icons.border_all,
//           label: 'Width',
//           value: controller.borderWidth.value,
//           min: 0,
//           max: 20,
//           onChanged: controller.updateBorderWidth,
//         ),
//         const SizedBox(height: 12),
//         _buildColorPickerRow(
//           'Color',
//           controller.borderColor.value,
//           controller.updateBorderColor,
//         ),
//       ],
//     );
//   }

//   Widget _buildEffectsSection(ShapeEditorController controller) {
//     return _buildSection(
//       title: 'Effects',
//       children: [
//         CompactSlider(
//           icon: Icons.blur_on,
//           label: 'Shadow Blur',
//           value: controller.shadowBlur.value,
//           min: 0,
//           max: 50,
//           onChanged: controller.updateShadowBlur,
//         ),
//         const SizedBox(height: 12),
//         CompactSlider(
//           icon: Icons.opacity,
//           label: 'Shadow Opacity',
//           value: controller.shadowOpacity.value,
//           min: 0,
//           max: 1,
//           onChanged: controller.updateShadowOpacity,
//         ),
//         const SizedBox(height: 12),
//         _buildColorPickerRow(
//           'Shadow Color',
//           controller.shadowColor.value,
//           controller.updateShadowColor,
//         ),
//       ],
//     );
//   }

//   Widget _buildSection({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade800,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: Column(children: children),
//         ),
//       ],
//     );
//   }

//   Widget _buildColorPickerRow(
//     String label,
//     Color color,
//     Function(Color) onChanged,
//   ) {
//     return Row(
//       children: [
//         Text(
//           label,
//           style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
//         ),
//         const Spacer(),
//         GestureDetector(
//           onTap: () => _showColorPicker(color, onChanged, '$label Color'),
//           child: Container(
//             width: 28,
//             height: 28,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: widget.onClose,
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               backgroundColor: Colors.white,
//               side: BorderSide(color: Colors.grey.shade300),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Colors.grey.shade700,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () {
//               if (_controller.currentShapeItem != null) {
//                 widget.onApply(_controller.currentShapeItem!);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               backgroundColor: AppColors.branding,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: 0,
//             ),
//             child: const Text(
//               'Apply',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showColorPicker(
//     Color currentColor,
//     Function(Color) onChanged,
//     String title,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(12),
//           topRight: Radius.circular(12),
//         ),
//       ),
//       builder: (context) => QuickColorPicker(
//         title: title,
//         currentColor: currentColor,
//         onChanged: (color) => onChanged(color!),
//       ),
//     );
//   }
// }
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
  final Function(StackShapeItem) onApply;

  const ShapeEditorPanel({
    super.key,
    this.shapeItem,
    required this.onClose,
    required this.onApply,
  });

  @override
  State<ShapeEditorPanel> createState() => _ShapeEditorPanelState();
}

class _ShapeEditorPanelState extends State<ShapeEditorPanel> {
  final ShapeEditorController _controller = Get.put(ShapeEditorController());
  final _pageController = PageController();
  final _currentTab = 0.obs; // 0: Templates, 1: Customize

  @override
  void initState() {
    super.initState();

    if (widget.shapeItem != null) {
      _controller.initializeProperties(widget.shapeItem!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.colorScheme.surface,
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          border: Border(left: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_mosaic, color: AppColors.branding, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Shape Editor',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
            onPressed: widget.onClose,
            tooltip: 'Close',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            _buildTabButton('Templates', 0),
            const SizedBox(width: 8),
            _buildTabButton('Customize', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _currentTab.value = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: _currentTab.value == index
                ? AppColors.branding.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: _currentTab.value == index
                    ? AppColors.branding
                    : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shape Templates',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: _controller.professionalTemplates.length,
              itemBuilder: (context, index) {
                final template = _controller.professionalTemplates[index];
                return _buildTemplateCard(template);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(ShapeTemplate template) {
    return GestureDetector(
      onTap: () {
        _controller.applyTemplate(template);
        _currentTab.value = 1;
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: ShapeDecoration(
                shape: template.shape,
                color: AppColors.branding,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              template.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
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
      padding: const EdgeInsets.all(16),
      child: GetBuilder<ShapeEditorController>(
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFillSection(controller),
              const SizedBox(height: 16),
              _buildBorderSection(controller),
              const SizedBox(height: 16),
              _buildShapeSpecificSection(controller),
              const SizedBox(height: 16),
              _buildEffectsSection(controller),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShapeSpecificSection(ShapeEditorController controller) {
    final shapeControls = controller.getShapeSpecificControls();

    if (shapeControls.isEmpty ||
        (shapeControls.first is SizedBox && shapeControls.length == 1)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shape Properties',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(children: shapeControls),
        ),
      ],
    );
  }

  Widget _buildFillSection(ShapeEditorController controller) {
    return _buildSection(
      title: 'Fill',
      children: [
        _buildColorPickerRow(
          'Color',
          controller.fillColor.value,
          controller.updateFillColor,
        ),
        const SizedBox(height: 12),
        CompactSlider(
          icon: Icons.opacity,
          label: 'Opacity',
          value: controller.fillOpacity.value,
          min: 0,
          max: 1,
          onChanged: controller.updateFillOpacity,
        ),
      ],
    );
  }

  Widget _buildBorderSection(ShapeEditorController controller) {
    return _buildSection(
      title: 'Border',
      children: [
        CompactSlider(
          icon: Icons.border_all,
          label: 'Width',
          value: controller.borderWidth.value,
          min: 0,
          max: 20,
          onChanged: controller.updateBorderWidth,
        ),
        const SizedBox(height: 12),
        _buildColorPickerRow(
          'Color',
          controller.borderColor.value,
          controller.updateBorderColor,
        ),
      ],
    );
  }

  Widget _buildEffectsSection(ShapeEditorController controller) {
    return _buildSection(
      title: 'Effects',
      children: [
        CompactSlider(
          icon: Icons.blur_on,
          label: 'Shadow Blur',
          value: controller.shadowBlur.value,
          min: 0,
          max: 50,
          onChanged: controller.updateShadowBlur,
        ),
        const SizedBox(height: 12),
        CompactSlider(
          icon: Icons.opacity,
          label: 'Shadow Opacity',
          value: controller.shadowOpacity.value,
          min: 0,
          max: 1,
          onChanged: controller.updateShadowOpacity,
        ),
        const SizedBox(height: 12),
        _buildColorPickerRow(
          'Shadow Color',
          controller.shadowColor.value,
          controller.updateShadowColor,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade100),
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
  ) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _showColorPicker(color, onChanged, '$label Color'),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onClose,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_controller.currentShapeItem != null) {
                widget.onApply(_controller.currentShapeItem!);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.branding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Apply',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
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
      context: context,
      backgroundColor: Colors.white,
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

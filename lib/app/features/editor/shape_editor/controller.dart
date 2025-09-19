import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/shack_shape_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:morphable_shape/morphable_shape.dart';

class ShapeTemplate {
  final String name;
  final String category;
  final String type;
  final MorphableShapeBorder shape;

  ShapeTemplate({
    required this.name,
    required this.category,
    required this.type,
    required this.shape,
  });
}

enum ArcDirection { inward, outward }

class ShapeEditorController extends GetxController
    with GetTickerProviderStateMixin {
  final CanvasController canvasController = Get.find();

  // Common properties
  var fillColor = AppColors.branding.obs;
  var fillOpacity = 1.0.obs;
  var borderColor = Colors.transparent.obs;
  var borderWidth = 0.0.obs;
  var shadowBlur = 0.0.obs;
  var shadowOpacity = 0.3.obs;
  var shadowOffset = const Offset(2, 2).obs;
  var shadowColor = Colors.white.obs;

  // Shape-specific properties
  var cornerRadius = 20.0.obs;
  var cornerStyle = CornerStyle.rounded.obs;

  // Polygon/Star properties
  var polygonSides = 6.obs;
  var starPoints = 5.obs;
  var starInset = 45.0.obs;

  // Arrow properties
  var arrowDirection = ShapeSide.right.obs;
  var arrowHeight = 25.0.obs;
  var arrowTailWidth = 40.0.obs;

  // Bubble properties
  var bubbleSide = ShapeSide.bottom.obs;
  var bubbleArrowHeight = 12.0.obs;
  var bubbleArrowWidth = 20.0.obs;
  var bubbleCornerRadius = 16.0.obs;

  // Arc properties
  var arcSide = ShapeSide.bottom.obs;
  var arcHeight = 20.0.obs;
  var arcIsOutward = false.obs;
  var arcTopLeftRadius = 0.0.obs;
  var arcBottomLeftRadius = 0.0.obs;

  // Trapezoid properties
  var trapezoidSide = ShapeSide.bottom.obs;
  var trapezoidInset = 20.0.obs;

  // Current shape item reference
  StackShapeItem? currentShapeItem;
  String? _currentShapeType;

  // Tab controller
  late TabController tabController;
  final currentTab = 0.obs;

  // Enhanced professional templates with curved shapes
  final List<ShapeTemplate> professionalTemplates = [
    // Basic Shapes
    ShapeTemplate(
      name: 'Rectangle',
      category: 'Basic',
      type: 'rectangle',
      shape: RectangleShapeBorder(),
    ),
    ShapeTemplate(
      name: 'Circle',
      category: 'Basic',
      type: 'circle',
      shape: CircleShapeBorder(),
    ),
    ShapeTemplate(
      name: 'Triangle',
      category: 'Basic',
      type: 'polygon',
      shape: PolygonShapeBorder(sides: 3),
    ),

    // Polygon Shapes
    ShapeTemplate(
      name: 'Diamond',
      category: 'Polygons',
      type: 'polygon',
      shape: PolygonShapeBorder(sides: 4, cornerRadius: 0.toPercentLength),
    ),
    ShapeTemplate(
      name: 'Hexagon',
      category: 'Polygons',
      type: 'polygon',
      shape: PolygonShapeBorder(sides: 6, cornerRadius: 8.toPercentLength),
    ),
    ShapeTemplate(
      name: 'Octagon',
      category: 'Polygons',
      type: 'polygon',
      shape: PolygonShapeBorder(sides: 8, cornerRadius: 10.toPercentLength),
    ),
    ShapeTemplate(
      name: 'Pentagon',
      category: 'Polygons',
      type: 'polygon',
      shape: PolygonShapeBorder(sides: 5, cornerRadius: 5.toPercentLength),
    ),

    // Star Shapes
    ShapeTemplate(
      name: '5-Point Star',
      category: 'Stars',
      type: 'star',
      shape: StarShapeBorder(corners: 5, inset: 45.toPercentLength),
    ),
    ShapeTemplate(
      name: '6-Point Star',
      category: 'Stars',
      type: 'star',
      shape: StarShapeBorder(corners: 6, inset: 40.toPercentLength),
    ),
    ShapeTemplate(
      name: 'Sparkle',
      category: 'Stars',
      type: 'star',
      shape: StarShapeBorder(corners: 8, inset: 60.toPercentLength),
    ),
    ShapeTemplate(
      name: '4-Point Star',
      category: 'Stars',
      type: 'star',
      shape: StarShapeBorder(corners: 4, inset: 50.toPercentLength),
    ),

    // Arrow Shapes
    ShapeTemplate(
      name: 'Arrow Right',
      category: 'Arrows',
      type: 'arrow',
      shape: ArrowShapeBorder(
        side: ShapeSide.right,
        arrowHeight: 25.toPercentLength,
        tailWidth: 40.toPercentLength,
      ),
    ),
    ShapeTemplate(
      name: 'Arrow Left',
      category: 'Arrows',
      type: 'arrow',
      shape: ArrowShapeBorder(
        side: ShapeSide.left,
        arrowHeight: 25.toPercentLength,
        tailWidth: 40.toPercentLength,
      ),
    ),
    ShapeTemplate(
      name: 'Arrow Up',
      category: 'Arrows',
      type: 'arrow',
      shape: ArrowShapeBorder(
        side: ShapeSide.top,
        arrowHeight: 25.toPercentLength,
        tailWidth: 40.toPercentLength,
      ),
    ),
    ShapeTemplate(
      name: 'Arrow Down',
      category: 'Arrows',
      type: 'arrow',
      shape: ArrowShapeBorder(
        side: ShapeSide.bottom,
        arrowHeight: 25.toPercentLength,
        tailWidth: 40.toPercentLength,
      ),
    ),

    // Bubble Shapes
    ShapeTemplate(
      name: 'Speech Bubble',
      category: 'Bubbles',
      type: 'bubble',
      shape: BubbleShapeBorder(
        side: ShapeSide.bottom,
        borderRadius: const Length(16),
        arrowHeight: const Length(12),
        arrowWidth: const Length(20),
      ),
    ),
    ShapeTemplate(
      name: 'Thought Bubble',
      category: 'Bubbles',
      type: 'bubble',
      shape: BubbleShapeBorder(
        side: ShapeSide.top,
        borderRadius: const Length(20),
        arrowHeight: const Length(8),
        arrowWidth: const Length(15),
      ),
    ),

    // Curved/Special Shapes
    ShapeTemplate(
      name: 'Trapezoid',
      category: 'Curved',
      type: 'trapezoid',
      shape: TrapezoidShapeBorder(
        side: ShapeSide.bottom,
        inset: const Length(20, unit: LengthUnit.percent),
      ),
    ),
    ShapeTemplate(
      name: 'Oval',
      category: 'Curved',
      type: 'rectangle',
      shape: RectangleShapeBorder(
        borderRadius: DynamicBorderRadius.all(
          DynamicRadius.circular(50.toPXLength),
        ),
      ),
    ),
    ShapeTemplate(
      name: 'Plus',
      category: 'Curved',
      type: 'star',
      shape: StarShapeBorder(corners: 4, inset: 30.toPercentLength),
    ),
    ShapeTemplate(
      name: 'Top Arc',
      category: 'Curved',
      type: 'arc',
      shape: ArcShapeBorder(side: ShapeSide.top, arcHeight: const Length(20)),
    ),
    ShapeTemplate(
      name: 'Bottom Arc',
      category: 'Curved',
      type: 'arc',
      shape: ArcShapeBorder(
        side: ShapeSide.bottom,
        arcHeight: const Length(20),
      ),
    ),
    ShapeTemplate(
      name: 'Left Arc',
      category: 'Curved',
      type: 'arc',
      shape: ArcShapeBorder(side: ShapeSide.left, arcHeight: const Length(20)),
    ),
    ShapeTemplate(
      name: 'Right Arc',
      category: 'Curved',
      type: 'arc',
      shape: ArcShapeBorder(side: ShapeSide.right, arcHeight: const Length(20)),
    ),
    ShapeTemplate(
      name: 'Outward Arc',
      category: 'Curved',
      type: 'arc',
      shape: ArcShapeBorder(
        side: ShapeSide.bottom,
        arcHeight: const Length(30),
        isOutward: true,
      ),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void updateCurrentTab(int index) {
    currentTab.value = index;
    update(['tab_bar']);
  }

  List<ShapeShadow> buildShapeShadows() {
    if (shadowBlur.value > 0) {
      return [
        ShapeShadow(
          color: shadowColor.value.withOpacity(shadowOpacity.value),
          blurRadius: shadowBlur.value,
          offset: shadowOffset.value,
        ),
      ];
    }
    return [];
  }

  void applyTemplate(ShapeTemplate template) {
    _currentShapeType = template.type;

    // Reset to default values for the new shape type
    // _resetToShapeDefaults(template.type);

    // Create the correct shape based on the template type
    final newShape = StackShapeItem(
      id: currentShapeItem?.id,

      size: currentShapeItem?.size ?? const Size(200, 200),
      offset: currentShapeItem?.offset ?? const Offset(222, 222),
      content: ShapeItemContent(
        shapeBorder: template.shape,
        fillColor: fillColor.value.withValues(alpha: fillOpacity.value),
        border: DynamicBorderSide(
          width: borderWidth.value,
          color: borderColor.value,
        ),
        shadows: buildShapeShadows(),
      ),
    );

    if (newShape.id == currentShapeItem?.id) {
      canvasController.boardController.updateItem(newShape);
      canvasController.boardController.updateBasic(
        newShape.id,
        status: StackItemStatus.moving,
      );
    } else {
      canvasController.boardController.addItem(newShape);
    }

    currentShapeItem = newShape;
    update(['customize', 'shape_specific']);
  }

  MorphableShapeBorder _createCurrentShape() {
    switch (_currentShapeType) {
      case 'rectangle':
        return RectangleShapeBorder(
          borderRadius: DynamicBorderRadius.all(
            DynamicRadius.circular(cornerRadius.value.toPXLength),
          ),
          border: DynamicBorderSide(
            width: borderWidth.value,
            color: borderColor.value,
          ),
          cornerStyles: RectangleCornerStyles.all(cornerStyle.value),
        );
      case 'arc':
        return ArcShapeBorder(
          side: arcSide.value,
          arcHeight: arcHeight.value.toPXLength,
          isOutward: arcIsOutward.value,
          border: DynamicBorderSide(
            width: borderWidth.value,
            color: borderColor.value,
          ),
        );
      case 'polygon':
        return PolygonShapeBorder(
          sides: polygonSides.value,
          cornerRadius: cornerRadius.value.toPercentLength,
          border: DynamicBorderSide(
            width: borderWidth.value,
            color: borderColor.value,
          ),
        );
      case 'star':
        return StarShapeBorder(
          corners: starPoints.value,
          inset: starInset.value.toPercentLength,
          border: DynamicBorderSide(
            width: borderWidth.value,
            color: borderColor.value,
          ),
        );
      case 'arrow':
        return ArrowShapeBorder(
          side: arrowDirection.value,
          arrowHeight: arrowHeight.value.toPercentLength,
          tailWidth: arrowTailWidth.value.toPercentLength,
          border: DynamicBorderSide(
            width: borderWidth.value,
            color: borderColor.value,
          ),
        );
      case 'bubble':
        return BubbleShapeBorder(
          side: bubbleSide.value,
          borderRadius: bubbleCornerRadius.value.toPXLength,
          arrowHeight: bubbleArrowHeight.value.toPXLength,
          arrowWidth: bubbleArrowWidth.value.toPXLength,
          border: DynamicBorderSide(
            width: borderWidth.value,
            color: borderColor.value,
          ),
        );
      case 'circle':
        return CircleShapeBorder(
          border: DynamicBorderSide(
            width: borderWidth.value,
            color: borderColor.value,
          ),
        );
      case 'trapezoid':
        return TrapezoidShapeBorder(
          side: trapezoidSide.value,
          inset: trapezoidInset.value.toPercentLength,
          border: DynamicBorderSide(
            width: borderWidth.value,
            color: borderColor.value,
          ),
        );
      default:
        return RectangleShapeBorder(
          borderRadius: DynamicBorderRadius.all(
            DynamicRadius.circular(cornerRadius.value.toPXLength),
          ),
          border: DynamicBorderSide(
            width: borderWidth.value,
            color: borderColor.value,
          ),
        );
    }
  }

  // Common update methods with real-time updates
  void updateFillColor(Color color) {
    fillColor.value = color;
    _updateCurrentShapeRealTime();
    update(['customize']);
  }

  void updateFillOpacity(double opacity) {
    fillOpacity.value = opacity;
    _updateCurrentShapeRealTime();
    update(['customize']);
  }

  void updateBorderColor(Color color) {
    borderColor.value = color;
    _updateCurrentShapeRealTime();
    update(['customize']);
  }

  void updateBorderWidth(double width) {
    borderWidth.value = width;
    _updateCurrentShapeRealTime();
    update(['customize']);
  }

  void updateShadowBlur(double blur) {
    shadowBlur.value = blur;
    _updateCurrentShapeRealTime();
    update(['customize']);
  }

  void updateShadowOpacity(double opacity) {
    shadowOpacity.value = opacity;
    _updateCurrentShapeRealTime();
    update(['customize']);
  }

  void updateShadowOffset(Offset offset) {
    shadowOffset.value = offset;
    _updateCurrentShapeRealTime();
    update(['customize']);
  }

  void updateShadowColor(Color color) {
    shadowColor.value = color;
    _updateCurrentShapeRealTime();
    update(['customize']);
  }

  // Shape-specific update methods with real-time updates
  void updateCornerRadius(double radius) {
    cornerRadius.value = radius;
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateCornerStyle(CornerStyle style) {
    cornerStyle.value = style;
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updatePolygonSides(int sides) {
    polygonSides.value = sides.clamp(3, 12);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateStarPoints(int points) {
    starPoints.value = points.clamp(3, 12);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateStarInset(double inset) {
    starInset.value = inset.clamp(10.0, 90.0);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateArrowDirection(ShapeSide direction) {
    arrowDirection.value = direction;
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateArrowHeight(double height) {
    arrowHeight.value = height.clamp(5.0, 50.0);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateArrowTailWidth(double width) {
    arrowTailWidth.value = width.clamp(10.0, 80.0);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateBubbleSide(ShapeSide side) {
    bubbleSide.value = side;
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateBubbleArrowHeight(double height) {
    bubbleArrowHeight.value = height.clamp(5.0, 30.0);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateBubbleArrowWidth(double width) {
    bubbleArrowWidth.value = width.clamp(10.0, 40.0);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateBubbleCornerRadius(double radius) {
    bubbleCornerRadius.value = radius.clamp(0.0, 50.0);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateArcSide(ShapeSide side) {
    arcSide.value = side;
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateArcHeight(double height) {
    arcHeight.value = height.clamp(5.0, 100.0);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateArcIsOutward(bool isOutward) {
    arcIsOutward.value = isOutward;
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateArcTopLeftRadius(double radius) {
    arcTopLeftRadius.value = radius.clamp(0.0, 100.0);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateArcBottomLeftRadius(double radius) {
    arcBottomLeftRadius.value = radius.clamp(0.0, 100.0);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateTrapezoidSide(ShapeSide side) {
    trapezoidSide.value = side;
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  void updateTrapezoidInset(double inset) {
    trapezoidInset.value = inset.clamp(0.0, 50.0);
    _updateCurrentShapeRealTime();
    update(['customize', 'shape_specific']);
  }

  // Real-time update method - updates the shape on canvas immediately
  void _updateCurrentShapeRealTime() {
    if (currentShapeItem != null && currentShapeItem!.content != null) {
      final newContent = currentShapeItem!.content!.copyWith(
        shapeBorder: _createCurrentShape(),
        fillColor: fillColor.value.withValues(alpha: fillOpacity.value),
        border: DynamicBorderSide(
          width: borderWidth.value,
          color: borderColor.value,
        ),
        shadows: buildShapeShadows(),
      );

      currentShapeItem = currentShapeItem!.copyWith(content: newContent);

      // Update the shape on the canvas in real-time
      canvasController.updateItem(currentShapeItem!);
    }
  }

  // Get shape-specific controls
  List<Widget> getShapeSpecificControls() {
    switch (_currentShapeType) {
      case 'rectangle':
        return [
          Row(
            children: [
              Expanded(
                child: CompactSlider(
                  icon: Icons.crop_square,
                  label: 'Corner',
                  value: cornerRadius.value,
                  min: 0,
                  max: 100,
                  onChanged: updateCornerRadius,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildCornerStyleSelector()),
            ],
          ),
        ];

      case 'polygon':
        return [
          Row(
            children: [
              Expanded(
                child: CompactSlider(
                  icon: Icons.polyline,
                  label: 'Sides',
                  value: polygonSides.value.toDouble(),
                  min: 3,
                  max: 12,
                  onChanged: (value) => updatePolygonSides(value.toInt()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CompactSlider(
                  icon: Icons.crop_square,
                  label: 'Corner',
                  value: cornerRadius.value,
                  min: 0,
                  max: 50,
                  onChanged: updateCornerRadius,
                ),
              ),
            ],
          ),
        ];

      case 'star':
        return [
          Row(
            children: [
              Expanded(
                child: CompactSlider(
                  icon: Icons.star,
                  label: 'Points',
                  value: starPoints.value.toDouble(),
                  min: 3,
                  max: 12,
                  onChanged: (value) => updateStarPoints(value.toInt()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CompactSlider(
                  icon: Icons.star_half,
                  label: 'Inset',
                  value: starInset.value,
                  min: 10,
                  max: 90,
                  onChanged: updateStarInset,
                ),
              ),
            ],
          ),
        ];

      case 'arrow':
        return [
          _buildDirectionSelector(updateArrowDirection, arrowDirection.value),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CompactSlider(
                  icon: Icons.arrow_upward,
                  label: 'Height',
                  value: arrowHeight.value,
                  min: 5,
                  max: 50,
                  onChanged: updateArrowHeight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CompactSlider(
                  icon: Icons.arrow_right,
                  label: 'Tail Width',
                  value: arrowTailWidth.value,
                  min: 10,
                  max: 80,
                  onChanged: updateArrowTailWidth,
                ),
              ),
            ],
          ),
        ];

      case 'bubble':
        return [
          _buildDirectionSelector(updateBubbleSide, bubbleSide.value),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CompactSlider(
                  icon: Icons.arrow_drop_up,
                  label: 'Arrow Height',
                  value: bubbleArrowHeight.value,
                  min: 5,
                  max: 30,
                  onChanged: updateBubbleArrowHeight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CompactSlider(
                  icon: Icons.arrow_right,
                  label: 'Arrow Width',
                  value: bubbleArrowWidth.value,
                  min: 10,
                  max: 40,
                  onChanged: updateBubbleArrowWidth,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.crop_square,
            label: 'Corner',
            value: bubbleCornerRadius.value,
            min: 0,
            max: 50,
            onChanged: updateBubbleCornerRadius,
          ),
        ];

      case 'arc':
        return [
          _buildDirectionSelector(updateArcSide, arcSide.value),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CompactSlider(
                  icon: Icons.architecture,
                  label: 'Arc Height',
                  value: arcHeight.value,
                  min: 5,
                  max: 100,
                  onChanged: updateArcHeight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildCompactArcToggle()),
            ],
          ),
        ];

      case 'trapezoid':
        return [
          _buildDirectionSelector(updateTrapezoidSide, trapezoidSide.value),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.aspect_ratio,
            label: 'Inset',
            value: trapezoidInset.value,
            min: 0,
            max: 50,
            onChanged: updateTrapezoidInset,
          ),
        ];

      case 'circle':
        return [const SizedBox.shrink()];

      default:
        return [
          CompactSlider(
            label: 'Corner',
            icon: Icons.crop_square,
            value: cornerRadius.value,
            min: 0,
            max: 100,
            onChanged: updateCornerRadius,
          ),
        ];
    }
  }

  Widget _buildCornerStyleSelector() {
    final styles = [
      {
        'style': CornerStyle.rounded,
        'name': 'Rounded',
        'icon': Icons.rounded_corner,
      },
      {
        'style': CornerStyle.cutout,
        'name': 'Cutout',
        'icon': Icons.crop_square,
      },
      {
        'style': CornerStyle.straight,
        'name': 'Straight',
        'icon': Icons.straight,
      },
      {
        'style': CornerStyle.concave,
        'name': 'Concave',
        'icon': Icons.architecture,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Corner Style',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: styles.map((styleData) {
            final style = styleData['style'] as CornerStyle;
            final name = styleData['name'] as String;
            final icon = styleData['icon'] as IconData;
            final isSelected = cornerStyle.value == style;

            return GestureDetector(
              onTap: () => updateCornerStyle(style),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected ? Colors.blue : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.blue : Colors.grey.shade700,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
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
  }

  Widget _buildCompactArcToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Arc Direction:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        ToggleButtons(
          isSelected: [
            !arcIsOutward.value, // Inward
            arcIsOutward.value, // Outward
          ],
          onPressed: (index) {
            if (index == 0) {
              updateArcIsOutward(false);
            } else {
              updateArcIsOutward(true);
            }
          },
          constraints: const BoxConstraints(minWidth: 60, minHeight: 30),
          borderRadius: BorderRadius.circular(6),
          selectedBorderColor: Colors.blue,
          borderColor: Colors.grey.shade300,
          selectedColor: Colors.blue,
          color: Colors.grey.shade700,
          fillColor: Colors.blue.withOpacity(0.1),
          children: const [
            Text('Inward', style: TextStyle(fontSize: 11)),
            Text('Outward', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionSelector(
    Function(ShapeSide) onChanged,
    ShapeSide currentValue,
  ) {
    final directions = [
      {'side': ShapeSide.top, 'name': 'Top', 'icon': Icons.arrow_upward},
      {
        'side': ShapeSide.bottom,
        'name': 'Bottom',
        'icon': Icons.arrow_downward,
      },
      {'side': ShapeSide.left, 'name': 'Left', 'icon': Icons.arrow_back},
      {'side': ShapeSide.right, 'name': 'Right', 'icon': Icons.arrow_forward},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Direction',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: directions.map((directionData) {
            final side = directionData['side'] as ShapeSide;
            final name = directionData['name'] as String;
            final icon = directionData['icon'] as IconData;
            final isSelected = currentValue == side;

            return GestureDetector(
              onTap: () => onChanged(side),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected ? Colors.blue : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.blue : Colors.grey.shade700,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
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
  }

  void initProperties(StackShapeItem shapeItem) {
    currentShapeItem = shapeItem;
    final content = shapeItem.content!;

    // Common properties
    fillColor.value = content.fillColor;
    fillOpacity.value = content.fillColor.a;
    borderColor.value = content.border.color;
    borderWidth.value = content.border.width;

    // Shadow properties
    shadowBlur.value = content.shadows.isNotEmpty
        ? content.shadows.first.blurRadius
        : 0.0;
    shadowOpacity.value = content.shadows.isNotEmpty
        ? content.shadows.first.color.a
        : 0.3;
    shadowOffset.value = content.shadows.isNotEmpty
        ? content.shadows.first.offset
        : const Offset(2, 2);
    shadowColor.value = content.shadows.isNotEmpty
        ? content.shadows.first.color
        : Colors.white;

    // Shape-specific properties
    final shape = content.shapeBorder;
    _currentShapeType = _determineShapeType(shape);

    switch (_currentShapeType) {
      case 'rectangle':
        final rect = shape as RectangleShapeBorder;
        cornerRadius.value = rect.borderRadius.topLeft.x.toPX();
        cornerStyle.value = rect.cornerStyles.topLeft;
        break;
      case 'polygon':
        final poly = shape as PolygonShapeBorder;
        polygonSides.value = poly.sides;
        cornerRadius.value = poly.cornerRadius.toPX();
        break;
      case 'star':
        final star = shape as StarShapeBorder;
        starPoints.value = star.corners;
        starInset.value = star.inset.toPX();
        break;
      case 'arrow':
        final arrow = shape as ArrowShapeBorder;
        arrowDirection.value = arrow.side;
        arrowHeight.value = arrow.arrowHeight.toPX();
        arrowTailWidth.value = arrow.tailWidth.toPX();
        break;
      case 'bubble':
        final bubble = shape as BubbleShapeBorder;
        bubbleSide.value = bubble.side;
        bubbleArrowHeight.value = bubble.arrowHeight.toPX();
        bubbleArrowWidth.value = bubble.arrowWidth.toPX();
        bubbleCornerRadius.value = bubble.borderRadius.toPX();
        break;
      case 'arc':
        final arc = shape as ArcShapeBorder;
        arcSide.value = arc.side;
        arcHeight.value = arc.arcHeight.toPX();
        arcIsOutward.value = arc.isOutward;
        break;
      case 'trapezoid':
        final trap = shape as TrapezoidShapeBorder;
        trapezoidSide.value = trap.side;
        trapezoidInset.value = trap.inset.toPX();
        break;
      default:
        cornerRadius.value = 20.0;
        cornerStyle.value = CornerStyle.rounded;
    }

    update(['customize', 'shape_specific', 'templates']);
  }

  String? _determineShapeType(MorphableShapeBorder? shape) {
    if (shape is RectangleShapeBorder) return 'rectangle';
    if (shape is CircleShapeBorder) return 'circle';
    if (shape is PolygonShapeBorder) return 'polygon';
    if (shape is StarShapeBorder) return 'star';
    if (shape is ArrowShapeBorder) return 'arrow';
    if (shape is BubbleShapeBorder) return 'bubble';
    if (shape is ArcShapeBorder) return 'arc';
    if (shape is TrapezoidShapeBorder) return 'trapezoid';
    return null;
  }
}

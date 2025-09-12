import 'package:cardmaker/app/features/editor/controller.dart';
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

class ShapeEditorController extends GetxController {
  final CanvasController canvasController = Get.find();

  // Common properties
  var fillColor = Colors.white.obs;
  var fillOpacity = 1.0.obs;
  var borderColor = Colors.black.obs;
  var borderWidth = 2.0.obs;
  var shadowBlur = 0.0.obs;
  var shadowOpacity = 0.3.obs;
  var shadowOffset = const Offset(2, 2).obs;
  var shadowColor = Colors.black.obs;

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
  var arcTopLeftRadius = 0.0.obs; // New property
  var arcBottomLeftRadius = 0.0.obs; // New property
  // Trapezoid properties
  var trapezoidSide = ShapeSide.bottom.obs;
  var trapezoidInset = 20.0.obs;
  // Current shape item reference
  StackShapeItem? currentShapeItem;
  MorphableShapeBorder? _originalTemplateShape;
  String? _currentShapeType;

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
      name: 'Rounded',
      category: 'Basic',
      type: 'rectangle',
      shape: RectangleShapeBorder(
        borderRadius: DynamicBorderRadius.all(
          DynamicRadius.circular(16.toPXLength),
        ),
      ),
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

    // Curved/Special Shapes (Custom implementations using existing shapes)
    ShapeTemplate(
      name: 'Trapezoid',
      category: 'Curved',
      type: 'trapezoid', // New type
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
    // Add to your professionalTemplates list in ShapeEditorController
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

  applyTemplate(ShapeTemplate template) {
    _originalTemplateShape = template.shape;
    _currentShapeType = template.type;

    // Reset to default values for the new shape type
    _resetToShapeDefaults(template.type);

    // Extract properties from the template
    _extractPropertiesFromShape(template.shape);

    final newShape = StackShapeItem(
      id:
          currentShapeItem?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      size: currentShapeItem?.size ?? const Size(200, 200),
      offset: currentShapeItem?.offset ?? const Offset(100, 100),
      content: ShapeItemContent(
        shapeBorder: _createCurrentShape(),
        fillColor: fillColor.value.withOpacity(fillOpacity.value),
        border: DynamicBorderSide(
          width: borderWidth.value,
          color: borderColor.value,
        ),
        shadows: buildShapeShadows(),
      ),
    );

    if (currentShapeItem != null && newShape.id == currentShapeItem?.id) {
      canvasController.boardController.updateItem(newShape);
      canvasController.boardController.updateBasic(
        newShape.id,
        status: StackItemStatus.moving,
      );
    } else {
      canvasController.boardController.addItem(newShape);
    }
    print(newShape.toJson());

    currentShapeItem = newShape;
    update();
  }

  void _resetToShapeDefaults(String shapeType) {
    switch (shapeType) {
      case 'arc':
        arcSide.value = ShapeSide.bottom;
        arcHeight.value = 20.0;
        arcIsOutward.value = false;
        arcTopLeftRadius.value = 0.0; // Reset new property
        arcBottomLeftRadius.value = 0.0; // Reset new property
        break;
      case 'rectangle':
        cornerRadius.value = 20.0;
        cornerStyle.value = CornerStyle.rounded;
        break;
      case 'polygon':
        polygonSides.value = 6;
        cornerRadius.value = 10.0;
        break;
      case 'star':
        starPoints.value = 5;
        starInset.value = 45.0;
        break;
      case 'arrow':
        arrowDirection.value = ShapeSide.right;
        arrowHeight.value = 25.0;
        arrowTailWidth.value = 40.0;
        break;
      case 'bubble':
        bubbleSide.value = ShapeSide.bottom;
        bubbleArrowHeight.value = 12.0;
        bubbleArrowWidth.value = 20.0;
        bubbleCornerRadius.value = 16.0;
        break;
      case 'circle':
        // Circles don't need special properties
        break;
    }
  }

  void _extractPropertiesFromShape(MorphableShapeBorder shape) {
    if (shape is RectangleShapeBorder) {
      final borderRadius = shape.borderRadius;
      cornerRadius.value = borderRadius.topLeft.x.toPX();
    } else if (shape is ArcShapeBorder) {
      arcSide.value = shape.side;
      arcHeight.value = shape.arcHeight.toPX() ?? 20.0;
      arcIsOutward.value = shape.isOutward;
      // For templates, set default corner radius values
      arcTopLeftRadius.value = 0.0;
      arcBottomLeftRadius.value = 0.0;
    } else if (shape is PolygonShapeBorder) {
      polygonSides.value = shape.sides;
      cornerRadius.value = shape.cornerRadius.toPX() ?? 10.0;
    } else if (shape is StarShapeBorder) {
      starPoints.value = shape.corners;
      starInset.value = shape.inset.toPX() ?? 45.0;
    } else if (shape is ArrowShapeBorder) {
      arrowDirection.value = shape.side;
      arrowHeight.value = shape.arrowHeight.toPX() ?? 25.0;
      arrowTailWidth.value = shape.tailWidth.toPX() ?? 40.0;
    } else if (shape is BubbleShapeBorder) {
      bubbleSide.value = shape.side;
      bubbleArrowHeight.value = shape.arrowHeight.toPX() ?? 12.0;
      bubbleArrowWidth.value = shape.arrowWidth.toPX() ?? 20.0;
      bubbleCornerRadius.value = shape.borderRadius.toPX() ?? 16.0;
    } else if (shape is TrapezoidShapeBorder) {
      trapezoidSide.value = shape.side;
      trapezoidInset.value = shape.inset.toPX() ?? 20.0;
    }
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
          // borderRadius: DynamicBorderRadius.only(
          //   topLeft: DynamicRadius.circular(arcTopLeftRadius.value.toPXLength),
          //   bottomLeft: DynamicRadius.circular(
          //     arcBottomLeftRadius.value.toPXLength,
          //   ),
          // ),
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
          // arrowCenterPosition:
          // arrowHeadPosition: ,
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

  void initializeProperties(StackShapeItem shapeItem) {
    currentShapeItem = shapeItem;
    _originalTemplateShape = shapeItem.content?.shapeBorder;

    // Detect shape type
    _detectShapeType(shapeItem.content?.shapeBorder);

    if (shapeItem.content != null) {
      final content = shapeItem.content!;
      fillColor.value = content.fillColor;
      borderColor.value = content.border.color;
      borderWidth.value = content.border.width;

      _extractPropertiesFromShape(content.shapeBorder!);

      if (content.shadows.isNotEmpty) {
        final shadow = content.shadows.first;
        shadowBlur.value = shadow.blurRadius;
        shadowOpacity.value = shadow.color.opacity;
        shadowOffset.value = shadow.offset;
        shadowColor.value = shadow.color.withOpacity(1);
      }
    }
    update();
  }

  void _detectShapeType(MorphableShapeBorder? shape) {
    if (shape == null) {
      _currentShapeType = 'rectangle';
      return;
    }

    if (shape is RectangleShapeBorder) {
      _currentShapeType = 'rectangle';
    } else if (shape is CircleShapeBorder) {
      _currentShapeType = 'circle';
    } else if (shape is PolygonShapeBorder) {
      _currentShapeType = 'polygon';
    } else if (shape is StarShapeBorder) {
      _currentShapeType = 'star';
    } else if (shape is ArrowShapeBorder) {
      _currentShapeType = 'arrow';
    } else if (shape is BubbleShapeBorder) {
      _currentShapeType = 'bubble';
    } else if (shape is ArcShapeBorder) {
      _currentShapeType = 'arc';
    }

    if (shape is TrapezoidShapeBorder) {
      _currentShapeType = 'trapezoid';
    } else {
      _currentShapeType = 'rectangle';
    }
  }

  void updateArcSide(ShapeSide side) {
    arcSide.value = side;
    _updateCurrentShapeRealTime();
  }

  void updateArcHeight(double height) {
    arcHeight.value = height.clamp(5.0, 100.0);
    _updateCurrentShapeRealTime();
  }

  void updateArcIsOutward(bool isOutward) {
    arcIsOutward.value = isOutward;
    _updateCurrentShapeRealTime();
  }

  // New methods for arc corner radius
  void updateArcTopLeftRadius(double radius) {
    arcTopLeftRadius.value = radius.clamp(0.0, 100.0);
    _updateCurrentShapeRealTime();
  }

  void updateArcBottomLeftRadius(double radius) {
    arcBottomLeftRadius.value = radius.clamp(0.0, 100.0);
    _updateCurrentShapeRealTime();
  }

  // Common update methods with real-time updates
  void updateFillColor(Color color) {
    fillColor.value = color as MaterialColor;
    _updateCurrentShapeRealTime();
  }

  void updateFillOpacity(double opacity) {
    fillOpacity.value = opacity;
    _updateCurrentShapeRealTime();
  }

  void updateBorderColor(Color color) {
    borderColor.value = color;
    _updateCurrentShapeRealTime();
  }

  void updateBorderWidth(double width) {
    borderWidth.value = width;
    _updateCurrentShapeRealTime();
  }

  void updateShadowBlur(double blur) {
    shadowBlur.value = blur;
    _updateCurrentShapeRealTime();
  }

  void updateShadowOpacity(double opacity) {
    shadowOpacity.value = opacity;
    _updateCurrentShapeRealTime();
  }

  void updateShadowOffset(Offset offset) {
    shadowOffset.value = offset;
    _updateCurrentShapeRealTime();
  }

  void updateShadowColor(Color color) {
    shadowColor.value = color;
    _updateCurrentShapeRealTime();
  }

  // Shape-specific update methods with real-time updates
  void updateCornerRadius(double radius) {
    cornerRadius.value = radius;
    _updateCurrentShapeRealTime();
  }

  void updateCornerStyle(CornerStyle style) {
    cornerStyle.value = style;
    _updateCurrentShapeRealTime();
  }

  void updatePolygonSides(int sides) {
    polygonSides.value = sides.clamp(3, 12);
    _updateCurrentShapeRealTime();
  }

  void updateStarPoints(int points) {
    starPoints.value = points.clamp(3, 12);
    _updateCurrentShapeRealTime();
  }

  void updateStarInset(double inset) {
    starInset.value = inset.clamp(10.0, 90.0);
    _updateCurrentShapeRealTime();
  }

  void updateArrowDirection(ShapeSide direction) {
    arrowDirection.value = direction;
    _updateCurrentShapeRealTime();
  }

  void updateArrowHeight(double height) {
    arrowHeight.value = height.clamp(5.0, 50.0);
    _updateCurrentShapeRealTime();
  }

  void updateArrowTailWidth(double width) {
    arrowTailWidth.value = width.clamp(10.0, 80.0);
    _updateCurrentShapeRealTime();
  }

  void updateBubbleSide(ShapeSide side) {
    bubbleSide.value = side;
    _updateCurrentShapeRealTime();
  }

  void updateBubbleArrowHeight(double height) {
    bubbleArrowHeight.value = height.clamp(5.0, 30.0);
    _updateCurrentShapeRealTime();
  }

  void updateBubbleArrowWidth(double width) {
    bubbleArrowWidth.value = width.clamp(10.0, 40.0);
    _updateCurrentShapeRealTime();
  }

  void updateBubbleCornerRadius(double radius) {
    bubbleCornerRadius.value = radius.clamp(0.0, 50.0);
    _updateCurrentShapeRealTime();
  }

  void updateTrapezoidSide(ShapeSide side) {
    trapezoidSide.value = side;
    _updateCurrentShapeRealTime();
  }

  void updateTrapezoidInset(double inset) {
    trapezoidInset.value = inset.clamp(0.0, 50.0);
    _updateCurrentShapeRealTime();
  }

  // Real-time update method - updates the shape on canvas immediately
  void _updateCurrentShapeRealTime() {
    if (currentShapeItem != null && currentShapeItem!.content != null) {
      final newContent = currentShapeItem!.content!.copyWith(
        shapeBorder: _createCurrentShape(),
        fillColor: fillColor.value.withOpacity(fillOpacity.value),
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
    update();
  }

  // Get shape-specific controls
  List<Widget> getShapeSpecificControls() {
    switch (_currentShapeType) {
      case 'rectangle':
        return [
          CompactSlider(
            icon: Icons.crop_square,
            label: 'Corner Radius',
            value: cornerRadius.value,
            min: 0,
            max: 100,
            onChanged: updateCornerRadius,
          ),
          const SizedBox(height: 8),
          _buildCornerStyleSelector(),
        ];

      case 'arc':
        return [
          _buildDirectionSelector(updateArcSide, arcSide.value),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.architecture,
            label: 'Arc Height',
            value: arcHeight.value,
            min: 5,
            max: 100,
            onChanged: updateArcHeight,
          ),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.abc_outlined,
            label: 'Top-Left Radius',
            value: arcTopLeftRadius.value,
            min: 0,
            max: 100,
            onChanged: updateArcTopLeftRadius,
          ),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.coronavirus,
            label: 'Bottom-Left Radius',
            value: arcBottomLeftRadius.value,
            min: 0,
            max: 100,
            onChanged: updateArcBottomLeftRadius,
          ),
          const SizedBox(height: 8),
          _buildArcDirectionToggle(),
        ];

      case 'polygon':
        return [
          CompactSlider(
            icon: Icons.polyline,
            label: 'Number of Sides',
            value: polygonSides.value.toDouble(),
            min: 3,
            max: 12,
            onChanged: (value) => updatePolygonSides(value.toInt()),
          ),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.crop_square,
            label: 'Corner Radius',
            value: cornerRadius.value,
            min: 0,
            max: 50,
            onChanged: updateCornerRadius,
          ),
        ];

      case 'star':
        return [
          CompactSlider(
            icon: Icons.star,
            label: 'Number of Points',
            value: starPoints.value.toDouble(),
            min: 3,
            max: 12,
            onChanged: (value) => updateStarPoints(value.toInt()),
          ),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.star_half,
            label: 'Star Inset',
            value: starInset.value,
            min: 10,
            max: 90,
            onChanged: updateStarInset,
          ),
        ];

      case 'arrow':
        return [
          _buildDirectionSelector(updateArrowDirection, arrowDirection.value),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.arrow_upward,
            label: 'Arrow Height',
            value: arrowHeight.value,
            min: 5,
            max: 50,
            onChanged: updateArrowHeight,
          ),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.arrow_right,
            label: 'Tail Width',
            value: arrowTailWidth.value,
            min: 10,
            max: 80,
            onChanged: updateArrowTailWidth,
          ),
        ];

      case 'bubble':
        return [
          _buildDirectionSelector(updateBubbleSide, bubbleSide.value),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.arrow_drop_up,
            label: 'Arrow Height',
            value: bubbleArrowHeight.value,
            min: 5,
            max: 30,
            onChanged: updateBubbleArrowHeight,
          ),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.arrow_right,
            label: 'Arrow Width',
            value: bubbleArrowWidth.value,
            min: 10,
            max: 40,
            onChanged: updateBubbleArrowWidth,
          ),
          const SizedBox(height: 8),
          CompactSlider(
            icon: Icons.crop_square,
            label: 'Corner Radius',
            value: bubbleCornerRadius.value,
            min: 0,
            max: 50,
            onChanged: updateBubbleCornerRadius,
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
            label: 'Corner Radius',
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

  // Add helper method for arc direction toggle
  Widget _buildArcDirectionToggle() {
    return Row(
      children: [
        Text(
          'Arc Direction:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => updateArcIsOutward(false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: !arcIsOutward.value
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: !arcIsOutward.value ? Colors.blue : Colors.grey.shade300,
              ),
            ),
            child: Text(
              'Inward',
              style: TextStyle(
                fontSize: 11,
                color: !arcIsOutward.value ? Colors.blue : Colors.grey.shade700,
                fontWeight: !arcIsOutward.value
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => updateArcIsOutward(true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: arcIsOutward.value
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: arcIsOutward.value ? Colors.blue : Colors.grey.shade300,
              ),
            ),
            child: Text(
              'Outward',
              style: TextStyle(
                fontSize: 11,
                color: arcIsOutward.value ? Colors.blue : Colors.grey.shade700,
                fontWeight: arcIsOutward.value
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
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
}

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

class MorphableShapeDemoPage extends StatefulWidget {
  const MorphableShapeDemoPage({super.key});

  @override
  State<MorphableShapeDemoPage> createState() => _MorphableShapeDemoPageState();
}

class _MorphableShapeDemoPageState extends State<MorphableShapeDemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final double _containerSize = 200;

  // Various shapes to demonstrate
  final List<MorphableShapeBorder> shapes = [
    RectangleShapeBorder(
      borderRadius: DynamicBorderRadius.all(
        DynamicRadius.circular(20.toPXLength),
      ),
      border: DynamicBorderSide(width: 3, color: Colors.blue),
    ),
    CircleShapeBorder(
      border: DynamicBorderSide(width: 4, color: Colors.purple),
    ),
    StarShapeBorder(
      corners: 5,
      inset: 50.toPercentLength,
      border: DynamicBorderSide(width: 2, color: Colors.orange),
    ),
    PolygonShapeBorder(
      sides: 6,
      cornerRadius: 15.toPercentLength,
      border: DynamicBorderSide(width: 3, color: Colors.green),
    ),
    RoundedRectangleShapeBorder(
      borderRadius: DynamicBorderRadius.only(
        topLeft: DynamicRadius.circular(40.toPXLength),
        bottomRight: DynamicRadius.elliptical(
          60.toPXLength,
          10.toPercentLength,
        ),
      ),
      borderSides: RectangleBorderSides.only(
        top: DynamicBorderSide(
          width: 4,
          gradient: LinearGradient(colors: [Colors.red, Colors.blue]),
        ),
      ),
    ),
  ];

  int _currentShapeIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Auto-animate between shapes
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextShape() {
    setState(() {
      _currentShapeIndex = (_currentShapeIndex + 1) % shapes.length;
    });
  }

  void _previousShape() {
    setState(() {
      _currentShapeIndex = (_currentShapeIndex - 1) % shapes.length;
      if (_currentShapeIndex < 0) _currentShapeIndex = shapes.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morphable Shape Demo'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to shape editor (you would need to implement this)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShapeEditorPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Exploring morphable_shape v2.0.0',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              _getShapeName(shapes[_currentShapeIndex]),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),
            // Animated shape morphing
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                // Create a tween between current and next shape
                final tween = MorphableShapeBorderTween(
                  begin: shapes[_currentShapeIndex],
                  end: shapes[(_currentShapeIndex + 1) % shapes.length],
                  method: MorphMethod.auto,
                );

                return Container(
                  width: _containerSize,
                  height: _containerSize,
                  decoration: ShapeDecoration(
                    shape:
                        tween.lerp(_animation.value) ??
                        shapes[_currentShapeIndex],
                    // color: Colors.amber.withOpacity(0.7),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Morphing Shapes!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            // Shape gallery
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: shapes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentShapeIndex = index;
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        shape: shapes[index],
                        color: Colors.blue.withOpacity(0.5),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _previousShape,
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _nextShape,
                  child: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'The morphable_shape package allows you to create responsive shapes '
                'that can morph between each other with smooth animations. '
                'It supports various shape types, gradient borders, and serialization.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getShapeName(MorphableShapeBorder shape) {
    if (shape is RectangleShapeBorder) return 'Rectangle Shape';
    if (shape is CircleShapeBorder) return 'Circle Shape';
    if (shape is StarShapeBorder) return 'Star Shape';
    if (shape is PolygonShapeBorder) return 'Polygon Shape';
    if (shape is RoundedRectangleShapeBorder) return 'Rounded Rectangle';
    return 'Custom Shape';
  }
}

class ShapeEditorPage extends StatefulWidget {
  const ShapeEditorPage({super.key});

  @override
  State<ShapeEditorPage> createState() => _ShapeEditorPageState();
}

class _ShapeEditorPageState extends State<ShapeEditorPage> {
  // Shape properties
  ShapeType _selectedShapeType = ShapeType.rectangle;
  double _cornerRadius = 20.0;
  int _sides = 5;
  int _starPoints = 5;
  double _starInset = 35.0;

  // Border properties
  double _borderWidth = 3.0;
  Color _borderColor = Colors.blue;
  bool _gradientBorder = false;

  // Fill properties
  Color _fillColor = Colors.amber;
  bool _gradientFill = false;

  // Size
  double _shapeSize = 200.0;

  // Shape morphing
  bool _isMorphing = false;
  final double _morphValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morphable Shape Editor'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveShape,
            tooltip: 'Save Shape',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shape preview
            Center(
              child: Container(
                width: _shapeSize,
                height: _shapeSize,
                decoration: ShapeDecoration(
                  shape: _buildShape(),
                  color: _fillColor,
                  gradient: _gradientFill
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.amber, Colors.deepOrange],
                        )
                      : null,
                ),
                child: _isMorphing
                    ? TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Container(
                            decoration: ShapeDecoration(
                              shape: _buildMorphingShape(value),
                              color: _fillColor.withOpacity(0.7),
                              gradient: _gradientFill
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Colors.amber, Colors.deepOrange],
                                    )
                                  : null,
                            ),
                          );
                        },
                        onEnd: () {
                          setState(() {
                            _isMorphing = false;
                          });
                        },
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 24),

            // Shape type selector
            _buildSectionTitle('Shape Type'),
            Wrap(
              spacing: 8,
              children: [
                _buildShapeChoiceChip('Rectangle', ShapeType.rectangle),
                _buildShapeChoiceChip('Circle', ShapeType.circle),
                _buildShapeChoiceChip('Polygon', ShapeType.polygon),
                _buildShapeChoiceChip('Star', ShapeType.star),
              ],
            ),

            const SizedBox(height: 16),

            // Shape properties
            _buildSectionTitle('Shape Properties'),
            if (_selectedShapeType == ShapeType.rectangle)
              _buildSlider('Corner Radius', _cornerRadius, 0, 100, (value) {
                setState(() => _cornerRadius = value);
              }),

            if (_selectedShapeType == ShapeType.polygon)
              _buildSlider('Sides', _sides.toDouble(), 3, 10, (value) {
                setState(() => _sides = value.toInt());
              }),

            if (_selectedShapeType == ShapeType.star) ...[
              _buildSlider('Points', _starPoints.toDouble(), 3, 10, (value) {
                setState(() => _starPoints = value.toInt());
              }),
              _buildSlider('Inset', _starInset, 10, 90, (value) {
                setState(() => _starInset = value);
              }),
            ],

            _buildSlider('Size', _shapeSize, 100, 300, (value) {
              setState(() => _shapeSize = value);
            }),

            const SizedBox(height: 16),

            // Border properties
            _buildSectionTitle('Border Properties'),
            _buildSlider('Border Width', _borderWidth, 0, 10, (value) {
              setState(() => _borderWidth = value);
            }),

            Row(
              children: [
                const Text('Border Color: '),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final color = await showDialog<Color>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Pick a border color'),
                        children: [
                          SimpleDialogOption(
                            onPressed: () =>
                                Navigator.pop(context, Colors.blue),
                            child: const Text('Blue'),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, Colors.red),
                            child: const Text('Red'),
                          ),
                          SimpleDialogOption(
                            onPressed: () =>
                                Navigator.pop(context, Colors.green),
                            child: const Text('Green'),
                          ),
                          SimpleDialogOption(
                            onPressed: () =>
                                Navigator.pop(context, Colors.purple),
                            child: const Text('Purple'),
                          ),
                        ],
                      ),
                    );
                    if (color != null) {
                      setState(() => _borderColor = color);
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _borderColor,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Switch(
                  value: _gradientBorder,
                  onChanged: (value) {
                    setState(() => _gradientBorder = value);
                  },
                ),
                const Text('Gradient Border'),
              ],
            ),

            const SizedBox(height: 16),

            // Fill properties
            _buildSectionTitle('Fill Properties'),
            Row(
              children: [
                const Text('Fill Color: '),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final color = await showDialog<Color>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Pick a fill color'),
                        children: [
                          SimpleDialogOption(
                            onPressed: () =>
                                Navigator.pop(context, Colors.amber),
                            child: const Text('Amber'),
                          ),
                          SimpleDialogOption(
                            onPressed: () =>
                                Navigator.pop(context, Colors.blueAccent),
                            child: const Text('Blue Accent'),
                          ),
                          SimpleDialogOption(
                            onPressed: () =>
                                Navigator.pop(context, Colors.greenAccent),
                            child: const Text('Green Accent'),
                          ),
                          SimpleDialogOption(
                            onPressed: () =>
                                Navigator.pop(context, Colors.pinkAccent),
                            child: const Text('Pink Accent'),
                          ),
                        ],
                      ),
                    );
                    if (color != null) {
                      setState(() => _fillColor = color);
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _fillColor,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Switch(
                  value: _gradientFill,
                  onChanged: (value) {
                    setState(() => _gradientFill = value);
                  },
                ),
                const Text('Gradient Fill'),
              ],
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _morphShape,
                  child: const Text('Morph Shape'),
                ),
                ElevatedButton(
                  onPressed: _resetShape,
                  child: const Text('Reset'),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.toStringAsFixed(0)}'),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildShapeChoiceChip(String label, ShapeType shapeType) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedShapeType == shapeType,
      onSelected: (selected) {
        setState(() {
          _selectedShapeType = shapeType;
        });
      },
    );
  }

  MorphableShapeBorder _buildShape() {
    final border = _gradientBorder
        ? DynamicBorderSide(
            width: _borderWidth,
            gradient: LinearGradient(
              colors: [_borderColor, _borderColor.withOpacity(0.5)],
            ),
          )
        : DynamicBorderSide(width: _borderWidth, color: _borderColor);

    switch (_selectedShapeType) {
      case ShapeType.rectangle:
        return RectangleShapeBorder(
          borderRadius: DynamicBorderRadius.all(
            DynamicRadius.circular(_cornerRadius.toPXLength),
          ),
          border: border,
        );
      case ShapeType.circle:
        return CircleShapeBorder(border: border);
      case ShapeType.polygon:
        return PolygonShapeBorder(
          sides: _sides,
          cornerRadius: (_cornerRadius / 2).toPercentLength,
          border: border,
        );
      case ShapeType.star:
        return StarShapeBorder(
          corners: _starPoints,
          inset: _starInset.toPercentLength,
          border: border,
        );
    }
  }

  MorphableShapeBorder _buildMorphingShape(double value) {
    final border = _gradientBorder
        ? DynamicBorderSide(
            width: _borderWidth,
            gradient: LinearGradient(
              colors: [_borderColor, _borderColor.withOpacity(0.5)],
            ),
          )
        : DynamicBorderSide(width: _borderWidth, color: _borderColor);

    // Create a different shape for morphing
    MorphableShapeBorder targetShape;

    switch (_selectedShapeType) {
      case ShapeType.rectangle:
        targetShape = CircleShapeBorder(border: border);
        break;
      case ShapeType.circle:
        targetShape = StarShapeBorder(
          corners: 5,
          inset: 40.toPercentLength,
          border: border,
        );
        break;
      case ShapeType.polygon:
        targetShape = RectangleShapeBorder(
          borderRadius: DynamicBorderRadius.all(
            DynamicRadius.circular(30.toPXLength),
          ),
          border: border,
        );
        break;
      case ShapeType.star:
        targetShape = CircleShapeBorder(border: border);
        break;
    }

    // Create a tween between the current shape and target shape
    final tween = MorphableShapeBorderTween(
      begin: _buildShape(),
      end: targetShape,
      method: MorphMethod.auto,
    );

    return tween.lerp(value)!;
  }

  void _morphShape() {
    setState(() {
      _isMorphing = true;
    });
  }

  void _resetShape() {
    setState(() {
      _selectedShapeType = ShapeType.rectangle;
      _cornerRadius = 20.0;
      _sides = 5;
      _starPoints = 5;
      _starInset = 35.0;
      _borderWidth = 3.0;
      _borderColor = Colors.blue;
      _gradientBorder = false;
      _fillColor = Colors.amber;
      _gradientFill = false;
      _shapeSize = 200.0;
      _isMorphing = false;
    });
  }

  void _saveShape() {
    // In a real app, you would save the shape configuration
    // using the package's serialization capabilities
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shape Saved'),
        content: const Text('Your shape configuration has been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

enum ShapeType { rectangle, circle, polygon, star }

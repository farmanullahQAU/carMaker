library;

import 'package:flutter/material.dart';

/// A customizable ruler slider with optional custom labels, colors, tick spacing,
/// snapping behavior, and a callback that returns the selected value.
///
/// This widget allows users to scroll horizontally and select a value on a ruler-like
/// interface with customizable features such as:
/// - The color of the selected and unselected tick marks.
/// - Spacing between the ticks.
/// - Custom labels for specific tick intervals.
/// - The appearance of the fixed slider and the label.
/// - Snapping behavior for smooth scrolling.
///
/// ## Parameters
///
/// - `minValue`: The minimum value of the slider.
/// - `maxValue`: The maximum value of the slider.
/// - `initialValue`: The initial value of the slider, default is set to the midpoint of the min and max values.
/// - `rulerWidth`: The width of the ruler (slider).
/// - `rulerHeight`: The height of the ruler (slider).
/// - `selectedBarColor`: The color of the tick marks that are active or selected.
/// - `unselectedBarColor`: The color of the tick marks that are unselected or inactive.
/// - `tickSpacing`: The space between each tick on the ruler.
/// - `valueTextStyle`: The text style for the label that displays the current value.
/// - `customLabels`: Optional custom labels for specific intervals on the ruler.
/// - `onChanged`: A callback function that returns the selected value as the user interacts with the ruler.
/// - `showFixedBar`: A boolean indicating whether to show a fixed bar in the center.
/// - `fixedBarColor`: The color of the fixed bar that indicates the current value.
/// - `fixedBarWidth`: The width of the fixed bar.
/// - `fixedBarHeight`: The height of the fixed bar.
/// - `showFixedLabel`: A boolean indicating whether to show the current value as a fixed label.
/// - `fixedLabelColor`: The color of the fixed label that displays the current value.
/// - `scrollSensitivity`: Adjusts how sensitive the ruler is to user scroll/drag.
/// - `enableSnapping`: A boolean to control whether the ruler snaps to specific values after the user stops dragging.
/// - `majorTickInterval`: Controls how often major tick marks appear (e.g., every 5th or 10th tick).
/// - `labelInterval`: Controls how often labels appear (e.g., every 5th or 10th tick).
/// - `labelVerticalOffset`: Controls the vertical position of the labels relative to the ruler.
/// - `showBottomLabels`: A boolean to show or hide bottom labels.
/// - `labelTextStyle`: A custom text style for bottom labels.
/// - `majorTickHeight`: The height of the major ticks.
/// - `minorTickHeight`: The height of the minor ticks.
///
/// ## Example
/// ```dart
/// RulerSlider(
///   minValue: 0.0,
///   maxValue: 100.0,
///   initialValue: 50.0,
///   rulerWidth: 300.0,
///   rulerHeight: 100.0,
///   selectedBarColor: Colors.blue,
///   unselectedBarColor: Colors.grey,
///   tickSpacing: 10.0,
///   valueTextStyle: TextStyle(color: Colors.red, fontSize: 18),
///   labelBuilder: (double value) {
///     return Text(
///       value % 10 == 0 ? "Major $value" : "Minor $value",
///       style: TextStyle(fontSize: 12, color: Colors.blue),
///     );
///   },
///   onChanged: (double value) {
///     print("Current value: ${value.toStringAsFixed(1)}");
///   },
///   showFixedBar: true,
///   fixedBarColor: Colors.red,
///   fixedBarWidth: 3.0,
///   fixedBarHeight: 40.0,
///   showFixedLabel: true,
///   fixedLabelColor: Colors.red,
///   scrollSensitivity: 1.0,  // Adjust scroll sensitivity
///   enableSnapping: true,    // Enable snapping to labels or ticks
///   majorTickInterval: 5,    // Major ticks every 5 ticks
///   labelInterval: 10,       // Show labels every 10 ticks
///   labelVerticalOffset: 30.0,  // Position labels with vertical offset
///   showBottomLabels: true,   // Show or hide bottom labels
///   labelTextStyle: TextStyle(color: Colors.black, fontSize: 12), // Custom label style
///   majorTickHeight: 20.0,    // Custom major tick height
///   minorTickHeight: 10.0,    // Custom minor tick height
/// )
/// ```
///
/// This example shows how to configure the `RulerSlider` with:
/// - A min value of 0 and a max value of 100.
/// - Custom colors for the selected and unselected tick marks.
/// - Custom labels at specific intervals.
/// - Snapping enabled, so the slider snaps to the nearest label or tick.
/// - The ability to customize the appearance of the fixed bar and labels.
///

class RulerSlider extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double initialValue;
  final double rulerHeight;
  final Color selectedBarColor;
  final Color unselectedBarColor;
  final double tickSpacing;
  final TextStyle valueTextStyle;
  final ValueChanged<double>? onChanged;
  final String Function(double value)? labelBuilder;
  final bool showFixedBar;
  final Color fixedBarColor;
  final double fixedBarWidth;
  final double fixedBarHeight;
  final bool showFixedLabel;
  final Color fixedLabelColor;
  final double scrollSensitivity;
  final bool enableSnapping;
  final int majorTickInterval;
  final int labelInterval;
  final double labelVerticalOffset;
  final bool showBottomLabels;
  final TextStyle labelTextStyle;
  final double majorTickHeight;
  final double minorTickHeight;

  const RulerSlider({
    super.key,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.initialValue = 50.0,
    this.rulerHeight = 100.0,
    this.selectedBarColor = Colors.green,
    this.unselectedBarColor = Colors.grey,
    this.tickSpacing = 20.0,
    this.valueTextStyle = const TextStyle(color: Colors.black, fontSize: 18),
    this.labelBuilder,
    this.onChanged,
    this.showFixedBar = true,
    this.fixedBarColor = Colors.red,
    this.fixedBarWidth = 2.0,
    this.fixedBarHeight = 60.0,
    this.showFixedLabel = true,
    this.fixedLabelColor = Colors.red,
    this.scrollSensitivity = 0.5,
    this.enableSnapping = false,
    this.majorTickInterval = 10,
    this.labelInterval = 10,
    this.labelVerticalOffset = 25.0,
    this.showBottomLabels = true,
    this.labelTextStyle = const TextStyle(fontSize: 12),
    this.majorTickHeight = 20.0,
    this.minorTickHeight = 10.0,
  });

  @override
  RulerSliderState createState() => RulerSliderState();
}

class RulerSliderState extends State<RulerSlider>
    with SingleTickerProviderStateMixin {
  late double _value;
  late double _rulerPosition;
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    // Initialize the value and the ruler position based on the initial value
    _value = widget.initialValue;
    double totalScrollableWidth = widget.maxValue * widget.tickSpacing;
    _rulerPosition =
        widget.labelInterval / 2 -
        (_value / widget.maxValue) * totalScrollableWidth;

    // Initialize the AnimationController for snapping animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _rulerPosition += details.delta.dx * widget.scrollSensitivity;
          double totalScrollableWidth = widget.maxValue * widget.tickSpacing;
          _rulerPosition = _rulerPosition.clamp(
            -totalScrollableWidth + widget.labelInterval / 2,
            widget.labelInterval / 2,
          );
          _value =
              (((widget.labelInterval / 2 - _rulerPosition) /
                          totalScrollableWidth) *
                      widget.maxValue)
                  .clamp(widget.minValue, widget.maxValue);

          if (widget.onChanged != null) {
            widget.onChanged!(_value);
          }
        });
      },
      onHorizontalDragEnd: (details) {
        if (widget.enableSnapping) {
          setState(() {
            // Snap to the nearest tick/label with animation if snapping is enabled
            double snappedValue = _getNearestSnapValue(_value);
            double totalScrollableWidth = widget.maxValue * widget.tickSpacing;

            // Animate the snapping
            _animation =
                Tween<double>(
                    begin: _rulerPosition,
                    end:
                        widget.labelInterval / 2 -
                        (snappedValue / widget.maxValue) * totalScrollableWidth,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    ),
                  )
                  ..addListener(() {
                    setState(() {
                      _rulerPosition = _animation.value;
                    });
                  });

            // Start the snapping animation
            _animationController.forward(from: 0.0);

            _value = snappedValue;
            if (widget.onChanged != null) {
              widget.onChanged!(_value);
            }
          });
        }
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: widget.rulerHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.labelInterval.toDouble(), widget.rulerHeight),
              painter: RulerPainter(
                rulerPosition: _rulerPosition,
                maxValue: widget.maxValue,
                value: _value,
                selectedBarColor: widget.selectedBarColor,
                unselectedBarColor: widget.unselectedBarColor,
                tickSpacing: widget.tickSpacing,
                labelBuilder: widget.labelBuilder,
                majorTickInterval: widget.majorTickInterval,
                labelInterval: widget.labelInterval,
                labelVerticalOffset: widget.labelVerticalOffset,
                showBottomLabels: widget.showBottomLabels,
                labelTextStyle: widget.labelTextStyle,
                majorTickHeight: widget.majorTickHeight,
                minorTickHeight: widget.minorTickHeight,
                barWidth: widget.fixedBarWidth,
              ),
            ),
            if (widget.showFixedLabel)
              Positioned(
                top: 0,
                child: Text(
                  _value.toStringAsFixed(1),
                  style: widget.valueTextStyle.copyWith(
                    color: widget.fixedLabelColor,
                  ),
                ),
              ),
            if (widget.showFixedBar)
              Positioned(
                child: Container(
                  height: widget.fixedBarHeight,
                  width: widget.fixedBarWidth,
                  color: widget.fixedBarColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Get the nearest value to snap to based on the current value
  double _getNearestSnapValue(double value) {
    // Snap to the nearest Interval
    double snapInterval = widget.labelInterval.toDouble();
    return (value / snapInterval).round() * snapInterval;
  }
}

class RulerPainter extends CustomPainter {
  final double rulerPosition;
  final double maxValue;
  final double value;
  final Color selectedBarColor;
  final Color unselectedBarColor;
  final double tickSpacing;
  final String Function(double value)? labelBuilder;
  final int majorTickInterval;
  final int labelInterval;
  final double labelVerticalOffset;

  final bool showBottomLabels;
  final TextStyle labelTextStyle;
  final double majorTickHeight;
  final double minorTickHeight;

  final double barWidth;

  RulerPainter({
    required this.rulerPosition,
    required this.maxValue,
    required this.value,
    required this.selectedBarColor,
    required this.unselectedBarColor,
    required this.tickSpacing,
    required this.labelBuilder,
    required this.majorTickInterval,
    required this.labelInterval,
    required this.labelVerticalOffset,
    required this.showBottomLabels,
    required this.labelTextStyle,
    required this.majorTickHeight,
    required this.minorTickHeight,
    required this.barWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint unselectedTickPaint = Paint()
      ..color = unselectedBarColor
      ..strokeWidth = barWidth;
    final Paint selectedTickPaint = Paint()
      ..color = selectedBarColor
      ..strokeWidth = barWidth;
    canvas.translate(rulerPosition, 0);

    for (double i = 0; i <= maxValue; i += 1) {
      double xPos = (i * tickSpacing);
      double tickHeight = (i % majorTickInterval == 0)
          ? majorTickHeight
          : minorTickHeight;

      if (xPos < rulerPosition.abs() + size.width / 2) {
        canvas.drawLine(
          Offset(xPos, size.height / 2 - tickHeight),
          Offset(xPos, size.height / 2 + tickHeight),
          selectedTickPaint,
        );
      } else {
        canvas.drawLine(
          Offset(xPos, size.height / 2 - tickHeight),
          Offset(xPos, size.height / 2 + tickHeight),
          unselectedTickPaint,
        );
      }

      if (showBottomLabels) {
        if (i % labelInterval == 0) {
          String label = labelBuilder != null
              ? labelBuilder!(i)
              : i.toStringAsFixed(0);
          TextPainter textPainter = TextPainter(
            text: TextSpan(text: label, style: labelTextStyle),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              xPos - textPainter.width / 2,
              size.height / 2 + labelVerticalOffset,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

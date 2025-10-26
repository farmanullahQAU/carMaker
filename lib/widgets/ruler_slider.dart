import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final List<double> snapValues;

  const RulerSlider({
    super.key,
    this.minValue = 8.0,
    this.maxValue = 72.0,
    this.initialValue = 16.0,
    this.rulerHeight = 80.0,
    this.selectedBarColor = Colors.blue,
    this.unselectedBarColor = Colors.grey,
    this.tickSpacing = 10.0,
    this.valueTextStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    this.labelBuilder,
    this.onChanged,
    this.showFixedBar = true,
    this.fixedBarColor = Colors.blue,
    this.fixedBarWidth = 1.5,
    this.fixedBarHeight = 50.0,
    this.showFixedLabel = true,
    this.fixedLabelColor = Colors.blue,
    this.scrollSensitivity = 0.8,
    this.enableSnapping = true,
    this.majorTickInterval = 10,
    this.labelInterval = 10,
    this.labelVerticalOffset = 20.0,
    this.showBottomLabels = true,
    this.labelTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black54,
      fontWeight: FontWeight.w500,
    ),
    this.majorTickHeight = 15.0,
    this.minorTickHeight = 8.0,
    this.snapValues = const [
      8,
      10,
      12,
      14,
      16,
      18,
      20,
      24,
      28,
      32,
      36,
      48,
      60,
      72,
    ],
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
    _value = widget.initialValue.clamp(widget.minValue, widget.maxValue);
    double totalScrollableWidth = widget.maxValue * widget.tickSpacing;
    _rulerPosition =
        widget.labelInterval / 2 -
        (_value / widget.maxValue) * totalScrollableWidth;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      slider: true,
      value: _value.toStringAsFixed(0),
      label: 'Font size selector',
      child: GestureDetector(
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
            HapticFeedback.selectionClick();
            setState(() {
              double snappedValue = _getNearestSnapValue(_value);
              double totalScrollableWidth =
                  widget.maxValue * widget.tickSpacing;

              _animation =
                  Tween<double>(
                      begin: _rulerPosition,
                      end:
                          widget.labelInterval / 2 -
                          (snappedValue / widget.maxValue) *
                              totalScrollableWidth,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutQuad,
                      ),
                    )
                    ..addListener(() {
                      setState(() {
                        _rulerPosition = _animation.value;
                      });
                    });

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
                  labelBuilder:
                      widget.labelBuilder ??
                      (value) => value.toInt().toString(),
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
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      _value.toStringAsFixed(0),
                      style: widget.valueTextStyle.copyWith(
                        color: widget.fixedLabelColor,
                      ),
                    ),
                  ),
                ),
              if (widget.showFixedBar)
                Positioned(
                  child: Container(
                    height: widget.fixedBarHeight,
                    width: widget.fixedBarWidth,
                    decoration: BoxDecoration(
                      color: widget.fixedBarColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _getNearestSnapValue(double value) {
    if (widget.snapValues.isEmpty) {
      double snapInterval = widget.labelInterval.toDouble();
      return (value / snapInterval).round() * snapInterval;
    }
    return widget.snapValues.reduce(
      (a, b) => (b - value).abs() < (a - value).abs() ? b : a,
    );
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
      ..color = unselectedBarColor.withOpacity(0.6)
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;
    final Paint selectedTickPaint = Paint()
      ..color = selectedBarColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;

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

      if (showBottomLabels && i % labelInterval == 0) {
        String label = labelBuilder!(i);
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

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) {
    return oldDelegate.rulerPosition != rulerPosition ||
        oldDelegate.value != value;
  }
}

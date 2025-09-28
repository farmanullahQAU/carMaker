// stack_chart_case.dart
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_chart_item.dart';
import 'package:flutter/material.dart';

class StackChartCase extends StatelessWidget {
  final StackChartItem item;

  const StackChartCase({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.content == null) {
      return Container(
        width: item.size.width,
        height: item.size.height,
        color: Colors.grey.shade300,
        child: const Icon(Icons.error, color: Colors.red),
      );
    }

    final content = item.content!;
    final widget = item.content?.chartType == ChartType.linearProgress
        ? SizedBox(
            width: item.size.width,
            height: item.size.height,
            child: CustomPaint(
              painter: _ChartPainter(content: content),
              child: content.showValueText
                  ? _buildValueText(content)
                  : const SizedBox(),
            ),
          )
        : SizedBox(
            width: item.size.width,
            height: item.size.height,
            child: CustomPaint(
              painter: _ChartPainter(content: content),
              child: content.showValueText
                  ? _buildValueText(content)
                  : const SizedBox(),
            ),
          );

    return widget;
  }

  Widget _buildValueText(ChartItemContent content) {
    final percentage = (content.value / content.maxValue * 100).toStringAsFixed(
      1,
    );
    return Center(
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: content.textColor,
          fontSize: content.textSize * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final ChartItemContent content;

  _ChartPainter({required this.content});

  @override
  void paint(Canvas canvas, Size size) {
    switch (content.chartType) {
      case ChartType.linearProgress:
        _drawLinearProgress(canvas, size);
        break;
      case ChartType.circularProgress:
        _drawCircularProgress(canvas, size);
        break;
      case ChartType.radialProgress:
        _drawRadialProgress(canvas, size);
        break;
    }
  }

  void _drawLinearProgress(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = content.backgroundColor
      ..style = PaintingStyle.fill;

    final progressPaint = Paint()
      ..color = content.progressColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = content.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = content.borderWidth;

    // Draw background
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(content.cornerRadius),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    // Draw progress
    final progressWidth = size.width * content.percentage;
    if (progressWidth > 0) {
      final progressRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, progressWidth, size.height),
        Radius.circular(content.cornerRadius),
      );
      canvas.drawRRect(progressRect, progressPaint);
    }

    // Draw border
    if (content.borderWidth > 0) {
      canvas.drawRRect(backgroundRect, borderPaint);
    }

    // Draw glow effect
    if (content.glowEffect) {
      final glowPaint = Paint()
        ..color = content.glowColor ?? content.progressColor.withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, content.glowBlur);

      final glowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -content.glowBlur,
          -content.glowBlur,
          size.width + content.glowBlur * 2,
          size.height + content.glowBlur * 2,
        ),
        Radius.circular(content.cornerRadius),
      );
      canvas.drawRRect(glowRect, glowPaint);
    }
  }

  void _drawCircularProgress(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - content.thickness / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = content.backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = content.thickness;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = content.progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = content.thickness
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * content.percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw glow effect
    if (content.glowEffect) {
      final glowPaint = Paint()
        ..color = content.glowColor ?? content.progressColor.withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, content.glowBlur)
        ..style = PaintingStyle.stroke
        ..strokeWidth = content.thickness;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  void _drawRadialProgress(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.height - content.thickness / 2;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = content.backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = content.thickness
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159, // Start from left
      3.14159, // Half circle
      false,
      backgroundPaint,
    );

    // Draw progress arc
    final progressPaint = Paint()
      ..color = content.progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = content.thickness
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 3.14159 * content.percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw glow effect
    if (content.glowEffect) {
      final glowPaint = Paint()
        ..color = content.glowColor ?? content.progressColor.withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, content.glowBlur)
        ..style = PaintingStyle.stroke
        ..strokeWidth = content.thickness;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        3.14159,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

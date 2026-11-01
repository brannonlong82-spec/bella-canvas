import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

class ColoringPainter extends CustomPainter {
  final List<List<DrawingPoint?>> points;

  ColoringPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color.fromRGBO(0, 0, 0, 0.35),
    );

    for (int strokeIndex = 0; strokeIndex < points.length; strokeIndex++) {
      final stroke = points[strokeIndex];
      if (stroke.isEmpty) continue;

      final brushType = stroke[0]?.brushType ?? 'marker';
      final totalPoints = stroke.length;

      for (int j = 0; j < totalPoints - 1; j++) {
        final p1 = stroke[j];
        final p2 = stroke[j + 1];

        if (p1 == null || p2 == null) continue;

        Paint paint = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        if (brushType == 'marker') {
          paint.color = p1.color;
          paint.strokeWidth = p1.strokeWidth * 1.5;
          canvas.drawLine(p1.point, p2.point, paint);
        }
        else if (brushType == 'crayon') {
          paint.color = p1.color;
          paint.strokeWidth = p1.strokeWidth * 1.2;
          final double scatterX = (math.sin(j.toDouble() * 3.7) * 2.2);
          final double scatterY = (math.cos(j.toDouble() * 3.7) * 2.2);
          canvas.drawLine(
            Offset(p1.point.dx + scatterX, p1.point.dy + scatterY),
            Offset(p2.point.dx + scatterX, p2.point.dy + scatterY),
            paint,
          );
        }
        else if (brushType == 'watercolor') {
          final double fluidAlpha = 0.05 + (0.35 * (0.5 + 0.5 * math.sin(j.toDouble() * 0.8)));
          paint.color = p1.color.withValues(alpha: fluidAlpha);
          paint.strokeWidth = p1.strokeWidth * 2.4;
          canvas.drawLine(p1.point, p2.point, paint);
        }
        else if (brushType == 'pencil') {
          final double progress = totalPoints > 1 ? j / (totalPoints - 1) : 0.5;
          final double fadeFactor = math.sin(progress * math.pi);
          paint.color = p1.color.withValues(alpha: math.max(0.1, fadeFactor));
          paint.strokeWidth = math.max(1.5, p1.strokeWidth * 0.4);
          canvas.drawLine(p1.point, p2.point, paint);
        }
        else if (brushType == 'eraser') {
          paint.blendMode = BlendMode.clear;
          paint.strokeWidth = p1.strokeWidth * 1.5;
          canvas.drawLine(p1.point, p2.point, paint);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
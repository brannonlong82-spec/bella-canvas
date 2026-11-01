import 'package:flutter/material.dart';
import '../models/drawing_point.dart';
import '../utils/drawing_helper.dart';

class ColoringPainter extends CustomPainter {
  final List<List<DrawingPoint?>> points;

  ColoringPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    DrawingHelper.paintStrokes(canvas, size, points);
  }

  @override
  bool shouldRepaint(covariant ColoringPainter oldDelegate) {
    // Always repaint during active drawing and updates
    return true;
  }
}
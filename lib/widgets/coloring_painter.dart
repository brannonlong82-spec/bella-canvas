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
    // Only repaint if the reference to points changed, or if the number of strokes changed,
    // or if the active stroke's point count changed.
    if (oldDelegate.points != points) return true;
    if (oldDelegate.points.length != points.length) return true;

    if (points.isNotEmpty) {
      if (oldDelegate.points.last.length != points.last.length) return true;
    }

    return false;
  }
}
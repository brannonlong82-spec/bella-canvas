import 'package:flutter/material.dart';

class DrawingPoint {
  Offset point;
  Color color;
  double strokeWidth;
  String brushType;
  double opacity; // Locked-in opacity for permanent layering

  DrawingPoint(
      this.point,
      this.color,
      this.strokeWidth,
      this.brushType, {
        this.opacity = 0.2, // Default initial opacity
      });
}
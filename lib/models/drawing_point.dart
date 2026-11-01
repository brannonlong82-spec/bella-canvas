import 'package:flutter/material.dart';

class DrawingPoint {
  Offset point;
  Color color;
  double strokeWidth;
  String brushType;

  DrawingPoint(this.point, this.color, this.strokeWidth, this.brushType);
}
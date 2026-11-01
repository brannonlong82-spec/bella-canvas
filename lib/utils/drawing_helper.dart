import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import '../models/drawing_point.dart';

class DrawingHelper {
  static ui.Picture? _cachedPicture;
  static int _cachedStrokeCount = 0;
  static Size? _cachedSize;

  static Offset getScenePoint(Offset localPosition, TransformationController controller) {
    return controller.toScene(localPosition);
  }

  static Offset getLocalPoint(Offset globalPosition, RenderBox renderBox) {
    return renderBox.globalToLocal(globalPosition);
  }

  static void clearCache() {
    _cachedPicture?.dispose();
    _cachedPicture = null;
    _cachedStrokeCount = 0;
    _cachedSize = null;
  }

  static void paintStrokes(Canvas canvas, Size size, List<List<DrawingPoint?>> points) {
    if (points.isEmpty) {
      clearCache();
      return;
    }

    bool hasActiveStroke = points.isNotEmpty && points.last.isNotEmpty;
    int completedStrokeCount = hasActiveStroke ? points.length - 1 : points.length;

    if (_cachedPicture == null || _cachedStrokeCount != completedStrokeCount || _cachedSize != size) {
      _cachedPicture?.dispose();

      final recorder = ui.PictureRecorder();
      final cacheCanvas = Canvas(recorder);

      for (int i = 0; i < completedStrokeCount; i++) {
        _drawStrokeSequence(cacheCanvas, points[i]);
      }

      _cachedPicture = recorder.endRecording();
      _cachedStrokeCount = completedStrokeCount;
      _cachedSize = size;
    }

    if (_cachedPicture != null) {
      canvas.drawPicture(_cachedPicture!);
    }

    if (hasActiveStroke) {
      _drawStrokeSequence(canvas, points.last);
    }
  }

  static void _drawStrokeSequence(Canvas canvas, List<DrawingPoint?> stroke) {
    if (stroke.isEmpty) return;

    final firstPoint = stroke.first;
    if (firstPoint == null) return;

    final brushType = firstPoint.brushType;
    final totalPoints = stroke.length;

    for (int j = 0; j < totalPoints - 1; j++) {
      final p1 = stroke[j];
      final p2 = stroke[j + 1];

      if (p1 == null || p2 == null) continue;

      // Use BlendMode.darken so colors sit naturally on top of the white background
      if (brushType == 'crayon') {
        _drawCrayonSegment(canvas, p1, p2, j);
      } else if (brushType == 'marker') {
        _drawMarkerSegment(canvas, p1, p2, j);
      } else if (brushType == 'pencil') {
        _drawPencilSegment(canvas, p1, p2, j, totalPoints);
      } else if (brushType == 'watercolor') {
        _drawWatercolorSegment(canvas, p1, p2, j);
      } else if (brushType == 'eraser') {
        _drawEraserSegment(canvas, p1, p2);
      }
    }
  }

  static void _drawCrayonSegment(Canvas canvas, DrawingPoint p1, DrawingPoint p2, int index) {
    final edgePaint = Paint()
      ..color = p1.color.withValues(alpha: p1.opacity * 0.3)
      ..blendMode = BlendMode.darken
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = p1.strokeWidth * 1.4;

    final corePaint = Paint()
      ..color = p1.color.withValues(alpha: p1.opacity)
      ..blendMode = BlendMode.darken
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = p1.strokeWidth * 0.8;

    final double scatterX = (math.sin(index.toDouble() * 3.7) * 1.8);
    final double scatterY = (math.cos(index.toDouble() * 3.7) * 1.8);

    canvas.drawLine(p1.point, p2.point, edgePaint);
    canvas.drawLine(
      Offset(p1.point.dx + scatterX, p1.point.dy + scatterY),
      Offset(p2.point.dx + scatterX, p2.point.dy + scatterY),
      corePaint,
    );
  }

  static void _drawMarkerSegment(Canvas canvas, DrawingPoint p1, DrawingPoint p2, int index) {
    final edgePaint = Paint()
      ..color = p1.color.withValues(alpha: p1.opacity * 0.5)
      ..blendMode = BlendMode.darken
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = p1.strokeWidth * 1.5;

    final corePaint = Paint()
      ..color = p1.color.withValues(alpha: p1.opacity)
      ..blendMode = BlendMode.darken
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = p1.strokeWidth * 0.9;

    canvas.drawLine(p1.point, p2.point, edgePaint);
    canvas.drawLine(p1.point, p2.point, corePaint);
  }

  static void _drawPencilSegment(Canvas canvas, DrawingPoint p1, DrawingPoint p2, int index, int totalPoints) {
    final double progress = totalPoints > 1 ? index / (totalPoints - 1) : 0.5;
    final double fadeFactor = math.sin(progress * math.pi);

    final edgePaint = Paint()
      ..color = p1.color.withValues(alpha: 0.05)
      ..blendMode = BlendMode.darken
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = p1.strokeWidth * 0.8;

    final corePaint = Paint()
      ..color = p1.color.withValues(alpha: math.max(0.1, p1.opacity * fadeFactor))
      ..blendMode = BlendMode.darken
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(1.0, p1.strokeWidth * 0.3);

    canvas.drawLine(p1.point, p2.point, edgePaint);
    canvas.drawLine(p1.point, p2.point, corePaint);
  }

  static void _drawWatercolorSegment(Canvas canvas, DrawingPoint p1, DrawingPoint p2, int index) {
    final centerAlpha = p1.opacity * (0.5 + 0.5 * math.sin(index.toDouble() * 0.8));

    final edgePaint = Paint()
      ..color = p1.color.withValues(alpha: p1.opacity * 0.2)
      ..blendMode = BlendMode.darken
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = p1.strokeWidth * 2.5;

    final centerPaint = Paint()
      ..color = p1.color.withValues(alpha: centerAlpha.clamp(0.0, 1.0))
      ..blendMode = BlendMode.darken
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = p1.strokeWidth * 1.2;

    canvas.drawLine(p1.point, p2.point, edgePaint);
    canvas.drawLine(p1.point, p2.point, centerPaint);
  }

  static void _drawEraserSegment(Canvas canvas, DrawingPoint p1, DrawingPoint p2) {
    final erasePaint = Paint()
      ..blendMode = BlendMode.clear
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = p1.strokeWidth * 1.5;

    canvas.drawLine(p1.point, p2.point, erasePaint);
  }
}
import 'package:flutter/material.dart';
import '../models/drawing_point.dart';
import 'coloring_painter.dart';

class CanvasViewer extends StatefulWidget {
  final String selectedPagePath;
  final String selectedBrush;
  final Color selectedColor;
  final double strokeSize;
  final List<List<DrawingPoint?>> points;
  final TransformationController transformationController;
  final ValueChanged<Offset> onPanStart;
  final ValueChanged<Offset> onPanUpdate;
  final VoidCallback onPanEnd;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  const CanvasViewer({
    super.key,
    required this.selectedPagePath,
    required this.selectedBrush,
    required this.selectedColor,
    required this.strokeSize,
    required this.points,
    required this.transformationController,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  @override
  State<CanvasViewer> createState() => _CanvasViewerState();
}

class _CanvasViewerState extends State<CanvasViewer> {
  bool _isMouseInside = false;
  Offset _mousePosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final bool isHandTool = widget.selectedBrush == 'hand';

    return Center(
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.green.shade300, width: 3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              fit: StackFit.expand,
              children: [
                InteractiveViewer(
                  transformationController: widget.transformationController,
                  minScale: 1.0,
                  maxScale: 4.0,
                  panEnabled: isHandTool,
                  scaleEnabled: true,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 800,
                      height: 1000,
                      // By placing MouseRegion INSIDE the 800x1000 SizedBox,
                      // localPosition is perfectly calibrated with no manual math needed.
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isMouseInside = true),
                        onExit: (_) => setState(() => _isMouseInside = false),
                        onHover: (details) => setState(() => _mousePosition = details.localPosition),
                        cursor: isHandTool ? SystemMouseCursors.grab : SystemMouseCursors.none,
                        child: Stack(
                          key: ValueKey(widget.selectedPagePath),
                          fit: StackFit.expand,
                          children: [
                            Container(color: Colors.white),

                            // 1. Coloring Page Image
                            Image.asset(
                              widget.selectedPagePath,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    "Asset not found:\n${widget.selectedPagePath}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // 2. Drawing Layer & Gestures
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: isHandTool
                                  ? null
                                  : (details) {
                                // Update the cursor position instantly when the click starts
                                setState(() {
                                  _mousePosition = details.localPosition;
                                  _isMouseInside = true;
                                });
                                widget.onPanStart(details.localPosition);
                              },
                              onPanUpdate: isHandTool
                                  ? null
                                  : (details) {
                                // Keep updating the cursor position while dragging
                                setState(() => _mousePosition = details.localPosition);
                                widget.onPanUpdate(details.localPosition);
                              },
                              onPanEnd: isHandTool ? null : (_) => widget.onPanEnd(),
                              onPanCancel: isHandTool ? null : () => widget.onPanEnd(),
                              child: CustomPaint(
                                painter: ColoringPainter(widget.points),
                                size: Size.infinite,
                              ),
                            ),

                            // 3. Clean Circular Hover Cursor Preview
                            if (_isMouseInside && !isHandTool)
                              IgnorePointer(
                                child: CustomPaint(
                                  painter: BrushCursorPainter(
                                    position: _mousePosition,
                                    size: widget.strokeSize,
                                    color: widget.selectedColor,
                                    brushType: widget.selectedBrush,
                                  ),
                                  size: Size.infinite,
                                ),
                              ),

                            // Logo Watermark
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Image.asset(
                                'assets/logo/bella_logo.png',
                                width: 64,
                                height: 64,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating Zoom Controls
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.green.shade300, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.zoom_out, size: 24),
                            onPressed: widget.onZoomOut,
                            tooltip: 'Zoom Out',
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.zoom_in, size: 24),
                            onPressed: widget.onZoomIn,
                            tooltip: 'Zoom In',
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.restart_alt, size: 24),
                            onPressed: widget.onResetZoom,
                            tooltip: 'Reset Zoom',
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BrushCursorPainter extends CustomPainter {
  final Offset position;
  final double size;
  final Color color;
  final String brushType;

  BrushCursorPainter({
    required this.position,
    required this.size,
    required this.color,
    required this.brushType,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final effectiveColor = color == Colors.white ? Colors.black54 : color;

    if (brushType == 'eraser') {
      final strokePaint = Paint()
        ..color = Colors.redAccent.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(position, size / 2, strokePaint);

      final fillPaint = Paint()
        ..color = Colors.redAccent.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, size / 2, fillPaint);
    } else {
      final strokePaint = Paint()
        ..color = effectiveColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(position, size / 2, strokePaint);

      final fillPaint = Paint()
        ..color = effectiveColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, size / 2, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BrushCursorPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.size != size ||
        oldDelegate.color != color ||
        oldDelegate.brushType != brushType;
  }
}
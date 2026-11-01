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

  void _updateMousePosition(Offset localPosition) {
    setState(() {
      // Convert local viewer position to unscaled scene coordinates for the cursor
      _mousePosition = widget.transformationController.toScene(localPosition);
      _isMouseInside = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isMouseInside = true),
      onExit: (_) => setState(() => _isMouseInside = false),
      onHover: (details) => _updateMousePosition(details.localPosition),
      cursor: widget.selectedBrush == 'hand' ? SystemMouseCursors.grab : SystemMouseCursors.none,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.green.shade300, width: 3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 2)
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
                panEnabled: widget.selectedBrush == 'hand',
                scaleEnabled: true,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.white),
                    Image.asset(
                      widget.selectedPagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            "Asset not found:\n${widget.selectedPagePath}",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onPanStart: widget.selectedBrush == 'hand'
                          ? null
                          : (details) {
                        _updateMousePosition(details.localPosition);
                        final scenePoint = widget.transformationController.toScene(details.localPosition);
                        widget.onPanStart(scenePoint);
                      },
                      onPanUpdate: widget.selectedBrush == 'hand'
                          ? null
                          : (details) {
                        _updateMousePosition(details.localPosition);
                        final scenePoint = widget.transformationController.toScene(details.localPosition);
                        widget.onPanUpdate(scenePoint);
                      },
                      onPanEnd: widget.selectedBrush == 'hand'
                          ? null
                          : (_) => widget.onPanEnd(),
                      child: CustomPaint(
                        painter: ColoringPainter(widget.points),
                        size: Size.infinite,
                      ),
                    ),
                    if (_isMouseInside && widget.selectedBrush != 'hand')
                      IgnorePointer(
                        child: CustomPaint(
                          painter: BrushCursorPainter(
                            position: _mousePosition,
                            size: widget.strokeSize,
                            color: widget.selectedColor,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Image.asset(
                        'assets/logo/bella_logo.png',
                        width: 80,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Zoom Controls at Bottom Center of Canvas
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
    );
  }
}

class BrushCursorPainter extends CustomPainter {
  final Offset position;
  final double size;
  final Color color;

  BrushCursorPainter({
    required this.position,
    required this.size,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color == Colors.white ? Colors.black54 : color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(position, size / 2, paint);

    final fillPaint = Paint()
      ..color = (color == Colors.white ? Colors.black : color).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, size / 2, fillPaint);
  }

  @override
  bool shouldRepaint(covariant BrushCursorPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.size != size ||
        oldDelegate.color != color;
  }
}
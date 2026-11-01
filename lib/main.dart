import 'dart:async';
import 'package:flutter/material.dart';
import 'models/drawing_point.dart';
import 'models/color_palette_model.dart';
import 'data/coloring_pages.dart';
import 'utils/drawing_helper.dart';
import 'utils/printing_saving.dart';
import 'widgets/thumbnail_sidebar.dart';
import 'widgets/top_toolbar.dart';
import 'widgets/color_palette.dart';
import 'widgets/app_header.dart';
import 'widgets/canvas_viewer.dart';
import 'dart:math' as math;

void main() {
  runApp(const BellaCanvasApp());
}

class BellaCanvasApp extends StatelessWidget {
  const BellaCanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bella Art Studio",
      theme: ThemeData(primarySwatch: Colors.green),
      home: const ColoringScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ColoringScreen extends StatefulWidget {
  const ColoringScreen({super.key});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  Color _selectedColor = Colors.black;
  String _selectedBrush = 'crayon';
  double _strokeSize = 12.0;
  bool _isSidebarExpanded = true;

  final TransformationController _transformationController = TransformationController();
  Timer? _holdTimer;

  late String _selectedPagePath;

  @override
  void initState() {
    super.initState();
    _selectedPagePath = bellaColoringPages[0].path;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  // Proper Matrix4 scaling implementation for Flutter web/mobile
  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale < 4.0) {
      final matrix = _transformationController.value.clone();
      matrix.scale(1.25);
      _transformationController.value = matrix;
    }
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 1.0) {
      final matrix = _transformationController.value.clone();
      matrix.scale(0.8);
      if (matrix.getMaxScaleOnAxis() < 1.0) {
        _transformationController.value = Matrix4.identity();
      } else {
        _transformationController.value = matrix;
      }
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  final List<String> _brushes = ['crayon', 'marker', 'pencil', 'watercolor', 'eraser', 'hand'];
  final List<List<DrawingPoint?>> _points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        onDownloadArt: () => PdfUtility.downloadArtworkFile(context, _selectedPagePath, _points),
        onDownloadPrintablePage: () => PdfUtility.printBlankPage(context, _selectedPagePath),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // 1. Color Palette on the Left
            ColorPalette(
              colors: ColorPaletteModel.baseColors,
              selectedColor: _selectedColor,
              onColorSelected: (color) => setState(() => _selectedColor = color),
              customShadesMap: ColorPaletteModel.shadesMap,
            ),
            const SizedBox(width: 12),

            // 2. Vertical Toolbar
            TopToolbar(
              brushes: _brushes,
              selectedBrush: _selectedBrush,
              onBrushChanged: (brush) => setState(() => _selectedBrush = brush),
              strokeSize: _strokeSize,
              onSizeChanged: (size) => setState(() => _strokeSize = size),
            ),
            const SizedBox(width: 12),

            // 3. Central Canvas Viewing Area
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: CanvasViewer(
                      selectedPagePath: _selectedPagePath,
                      selectedBrush: _selectedBrush,
                      selectedColor: _selectedColor,
                      strokeSize: _strokeSize,
                      points: _points,
                      transformationController: _transformationController,
                      onPanStart: (point) {
                        setState(() {
                          _points.add([DrawingPoint(point, _selectedColor, _strokeSize, _selectedBrush, opacity: 0.2)]);
                        });

                        _holdTimer?.cancel();
                        _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
                          if (mounted && _points.isNotEmpty && _points.last.isNotEmpty) {
                            setState(() {
                              for (var p in _points.last) {
                                if (p != null) {
                                  p.opacity = math.min(1.0, p.opacity + 0.025);
                                }
                              }
                            });
                          }
                        });
                      },
                      onPanUpdate: (point) {
                        setState(() {
                          if (_points.isNotEmpty) {
                            _points.last.add(DrawingPoint(point, _selectedColor, _strokeSize, _selectedBrush, opacity: 0.2));
                          }
                        });
                      },
                      onPanEnd: () {
                        _holdTimer?.cancel();
                        setState(() {
                          if (_points.isNotEmpty && _points.last.isNotEmpty) {
                            _points.last.add(null);
                          }
                        });
                      },
                      onZoomIn: _zoomIn,
                      onZoomOut: _zoomOut,
                      onResetZoom: _resetZoom,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bottom Action Controls
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _holdTimer?.cancel();
                            setState(() {
                              if (_points.isNotEmpty) {
                                _points.removeLast();
                                DrawingHelper.clearCache();
                              }
                            });
                          },
                          icon: const Icon(Icons.undo),
                          label: const Text('Undo'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade600, foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _holdTimer?.cancel();
                            setState(() {
                              _points.clear();
                              DrawingHelper.clearCache();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Clear All'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => PdfUtility.printColoredArtwork(context, _selectedPagePath, _points),
                          icon: const Icon(Icons.print),
                          label: const Text('Print My Page'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => PdfUtility.downloadArtworkFile(context, _selectedPagePath, _points),
                          icon: const Icon(Icons.download),
                          label: const Text('Download Artwork'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 4. Thumbnail Sidebar on the Right
            ThumbnailSidebar(
              pages: bellaColoringPages,
              selectedPagePath: _selectedPagePath,
              isExpanded: _isSidebarExpanded,
              onToggleExpand: () => setState(() => _isSidebarExpanded = !_isSidebarExpanded),
              onPageSelected: (path) {
                _holdTimer?.cancel();
                setState(() {
                  _selectedPagePath = path;
                  _points.clear();
                  DrawingHelper.clearCache();
                  _resetZoom();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
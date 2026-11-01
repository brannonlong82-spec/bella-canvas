import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'models/drawing_point.dart';
import 'data/coloring_pages.dart';
import 'widgets/thumbnail_sidebar.dart';
import 'widgets/top_toolbar.dart';
import 'widgets/color_palette.dart';
import 'widgets/app_header.dart';
import 'widgets/canvas_viewer.dart';

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

  late String _selectedPagePath;

  @override
  void initState() {
    super.initState();
    _selectedPagePath = bellaColoringPages[0].path;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale < 4.0) {
      _transformationController.value = currentMatrix.clone()..scaledByDouble(1.25, 1.25, 1.0, 1.0);
    }
  }

  void _zoomOut() {
    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale > 1.0) {
      final newMatrix = currentMatrix.clone()..scaledByDouble(0.8, 0.8, 1.0, 1.0);
      if (newMatrix.getMaxScaleOnAxis() < 1.0) {
        _transformationController.value = Matrix4.identity();
      } else {
        _transformationController.value = newMatrix;
      }
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  // PDF Generation for Colored Artwork
  Future<void> _downloadColoredArtwork() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating your masterpiece PDF...')),
    );

    final pdf = pw.Document();

    try {
      final pageImage = await imageFromAssetBundle(_selectedPagePath);
      final logoImage = await imageFromAssetBundle('assets/logo/bella_logo.png');

      if (!mounted) return;

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Center(child: pw.Image(pageImage, fit: pw.BoxFit.contain)),
                pw.Positioned(
                  top: 10,
                  left: 10,
                  child: pw.Image(logoImage, width: 60, height: 60),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Bella_Art_Masterpiece.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  // PDF Generation for Blank Printable Page
  Future<void> _printBlankPage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing blank page for printing...')),
    );

    final pdf = pw.Document();

    try {
      final pageImage = await imageFromAssetBundle(_selectedPagePath);

      if (!mounted) return;

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pageImage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Bella_Coloring_Page.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error preparing page: $e')),
      );
    }
  }

  final List<Color> _colors = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.white,
  ];

  final List<String> _brushes = ['crayon', 'marker', 'pencil', 'watercolor', 'eraser', 'hand'];
  final List<List<DrawingPoint?>> _points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        onDownloadArt: _downloadColoredArtwork,
        onDownloadPrintablePage: _printBlankPage,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // 1. Color Palette on the Left
            ColorPalette(
              colors: _colors,
              selectedColor: _selectedColor,
              onColorSelected: (color) => setState(() => _selectedColor = color),
            ),
            const SizedBox(width: 12),

            // 2. Vertical Toolbar nested between Color Palette and Canvas
            TopToolbar(
              brushes: _brushes,
              selectedBrush: _selectedBrush,
              onBrushChanged: (brush) => setState(() => _selectedBrush = brush),
              strokeSize: _strokeSize,
              onSizeChanged: (size) => setState(() => _strokeSize = size),
            ),
            const SizedBox(width: 12),

            // 3. Central Canvas Viewing Area (Single Standalone CanvasViewer Widget)
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
                          _points.add([DrawingPoint(point, _selectedColor, _strokeSize, _selectedBrush)]);
                        });
                      },
                      onPanUpdate: (point) {
                        setState(() {
                          _points.last.add(DrawingPoint(point, _selectedColor, _strokeSize, _selectedBrush));
                        });
                      },
                      onPanEnd: () {
                        setState(() {
                          _points.add([]);
                        });
                      },
                      onZoomIn: _zoomIn,
                      onZoomOut: _zoomOut,
                      onResetZoom: _resetZoom,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bottom Action Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            if (_points.isNotEmpty) {
                              _points.removeLast();
                            }
                          });
                        },
                        icon: const Icon(Icons.undo),
                        label: const Text('Undo'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade600, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _points.clear()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Clear All'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _downloadColoredArtwork,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Artwork'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                      ),
                    ],
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
                setState(() {
                  _selectedPagePath = path;
                  _points.clear();
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
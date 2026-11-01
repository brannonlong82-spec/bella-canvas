import 'package:flutter/material.dart';

class TopToolbar extends StatelessWidget {
  final List<String> brushes;
  final String selectedBrush;
  final ValueChanged<String> onBrushChanged;
  final double strokeSize;
  final ValueChanged<double> onSizeChanged;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  const TopToolbar({
    super.key,
    required this.brushes,
    required this.selectedBrush,
    required this.onBrushChanged,
    required this.strokeSize,
    required this.onSizeChanged,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  // Map each brush type to its custom asset path in assets/icons/
  String _getBrushAssetPath(String brush) {
    switch (brush) {
      case 'crayon':
        return 'assets/icons/crayon_icon.jpg';
      case 'marker':
        return 'assets/icons/marker_icon.jpg';
      case 'pencil':
        return 'assets/icons/pencil_icon.jpg';
      case 'watercolor':
        return 'assets/icons/water_color_icon.jpg';
      case 'eraser':
        return 'assets/icons/eraser_icon.jpg';
      default:
        return 'assets/icons/marker_icon.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Brush Selectors with Custom Image Assets + Labels
          ToggleButtons(
            isSelected: brushes.map((b) => b == selectedBrush).toList(),
            onPressed: (index) => onBrushChanged(brushes[index]),
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: Colors.green.shade600,
            constraints: const BoxConstraints(minHeight: 44, minWidth: 85),
            children: brushes.map((b) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _getBrushAssetPath(b),
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.brush, size: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      b[0].toUpperCase() + b.substring(1),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          // Size Slider
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Brush Size: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              SizedBox(
                width: 120,
                child: Slider(
                  value: strokeSize,
                  min: 4,
                  max: 40,
                  activeColor: Colors.green.shade600,
                  onChanged: onSizeChanged,
                ),
              ),
            ],
          ),

          // Zoom Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Zoom: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              IconButton(
                icon: const Icon(Icons.zoom_out, size: 20),
                onPressed: onZoomOut,
                tooltip: 'Zoom Out',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, size: 20),
                onPressed: onZoomIn,
                tooltip: 'Zoom In',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt, size: 20),
                onPressed: onResetZoom,
                tooltip: 'Reset Zoom',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
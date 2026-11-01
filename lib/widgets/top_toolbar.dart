import 'package:flutter/material.dart';

class TopToolbar extends StatelessWidget {
  final List<String> brushes;
  final String selectedBrush;
  final ValueChanged<String> onBrushChanged;
  final double strokeSize;
  final ValueChanged<double> onSizeChanged;

  const TopToolbar({
    super.key,
    required this.brushes,
    required this.selectedBrush,
    required this.onBrushChanged,
    required this.strokeSize,
    required this.onSizeChanged,
  });

  String _getBrushAssetPath(String brush) {
    switch (brush) {
      case 'crayon':
        return 'assets/icons/crayon_icon.png';
      case 'marker':
        return 'assets/icons/marker_icon.png';
      case 'pencil':
        return 'assets/icons/pencil_icon.png';
      case 'watercolor':
        return 'assets/icons/water_color_icon.png';
      case 'eraser':
        return 'assets/icons/eraser_icon.png';
      case 'hand':
        return 'assets/icons/mover_icon.png';
      default:
        return 'assets/icons/marker_icon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            ...brushes.map((b) {
              bool isSelected = b == selectedBrush;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GestureDetector(
                  onTap: () => onBrushChanged(b),
                  child: Container(
                    width: 74,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green.shade600 : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.green.shade800 : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          _getBrushAssetPath(b),
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.brush, size: 28),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          b[0].toUpperCase() + b.substring(1),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Divider(height: 20, thickness: 2),
            const Text('Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            SizedBox(
              width: 75,
              child: Slider(
                value: strokeSize,
                min: 4,
                max: 40,
                activeColor: Colors.green.shade600,
                onChanged: selectedBrush == 'hand' ? null : onSizeChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
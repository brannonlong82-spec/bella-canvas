import 'package:flutter/material.dart';

class ColorPalette extends StatefulWidget {
  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPalette({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  Color? _activeBaseColor;

  // Generates lighter, base, and darker shades for a given color
  List<Color> _getShades(Color color) {
    if (color == Colors.white || color == Colors.black) {
      return [color];
    }
    final hsl = HSLColor.fromColor(color);
    return [
      hsl.withLightness((hsl.lightness + 0.22).clamp(0.0, 1.0)).toColor(), // Lighter tint
      color, // Base color
      hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor(), // Darker shade
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.colors.map((color) {
            final shades = _getShades(color);
            bool isExpanded = _activeBaseColor == color;
            bool isBaseSelected = widget.selectedColor == color || shades.contains(widget.selectedColor);

            return Column(
              children: [
                // Main Color Circle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_activeBaseColor == color) {
                        _activeBaseColor = null; // Collapse if tapped again
                      } else {
                        _activeBaseColor = color; // Expand shades
                      }
                    });
                    widget.onColorSelected(color);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    width: isBaseSelected ? 38 : 32,
                    height: isBaseSelected ? 38 : 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isBaseSelected ? Colors.black : Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),

                // Shade Selector Dropdown Underneath (Lighter, Base, Darker)
                if (isExpanded && shades.length > 1)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: shades.map((shade) {
                        bool isShadeSelected = widget.selectedColor == shade;
                        return GestureDetector(
                          onTap: () => widget.onColorSelected(shade),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: shade,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isShadeSelected ? Colors.green.shade700 : Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
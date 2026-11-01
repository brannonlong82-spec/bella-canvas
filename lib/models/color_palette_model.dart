import 'package:flutter/material.dart';

class PaletteItem {
  final String name;
  final Color base;   // Color1: Base color
  final Color light;  // Color2: Lighter shade
  final Color dark;   // Color3: Darker shade

  const PaletteItem({
    required this.name,
    required this.base,
    required this.light,
    required this.dark,
  });

  /// Returns all 3 shades in order [Color1 (Base), Color2 (Light), Color3 (Dark)]
  List<Color> get shades => [base, light, dark];
}

class ColorPaletteModel {
  // Predefined list of all 13 base colors with customized Color1, Color2, Color3
  static final List<PaletteItem> items = [
    PaletteItem(
      name: 'Red',
      base: Colors.red,                          // Red1 (Base)
      light: Colors.redAccent.shade100,          // Red2 (Light)
      dark: Colors.red.shade900,                 // Red3 (Dark)
    ),
    PaletteItem(
      name: 'Orange',
      base: Colors.orange,                       // Orange1 (Base)
      light: Colors.orangeAccent.shade100,       // Orange2 (Light)
      dark: Colors.orange.shade900,              // Orange3 (Dark)
    ),
    PaletteItem(
      name: 'Yellow',
      base: Colors.yellow.shade700,              // Yellow1 (Base)
      light: Colors.yellow.shade100,             // Yellow2 (Light)
      dark: Colors.yellow.shade900,              // Yellow3 (Dark)
    ),
    PaletteItem(
      name: 'Green',
      base: Colors.green,                        // Green1 (Base)
      light: Colors.greenAccent.shade100,        // Green2 (Light)
      dark: Colors.green.shade900,               // Green3 (Dark)
    ),
    PaletteItem(
      name: 'Blue',
      base: Colors.blue,                         // Blue1 (Base)
      light: Colors.blueAccent.shade100,         // Blue2 (Light)
      dark: Colors.blue.shade900,                // Blue3 (Dark)
    ),
    PaletteItem(
      name: 'Purple',
      base: Colors.purple,                       // Purple1 (Base)
      light: Colors.purpleAccent.shade100,       // Purple2 (Light)
      dark: Colors.purple.shade900,              // Purple3 (Dark)
    ),
    PaletteItem(
      name: 'Brown',
      base: Colors.brown,                        // Brown1 (Base)
      light: Colors.brown.shade300,              // Brown2 (Light)
      dark: Colors.brown.shade900,               // Brown3 (Dark)
    ),
    PaletteItem(
      name: 'Pink',
      base: Colors.pink,                         // Pink1 (Base)
      light: Colors.pinkAccent.shade100,         // Pink2 (Light)
      dark: Colors.pink.shade900,                // Pink3 (Dark)
    ),
    PaletteItem(
      name: 'Teal',
      base: Colors.teal,                         // Teal1 (Base)
      light: Colors.tealAccent.shade100,         // Teal2 (Light)
      dark: Colors.teal.shade900,                // Teal3 (Dark)
    ),
    PaletteItem(
      name: 'Cyan',
      base: Colors.cyan,                         // Cyan1 (Base)
      light: Colors.cyanAccent.shade100,         // Cyan2 (Light)
      dark: Colors.cyan.shade900,                // Cyan3 (Dark)
    ),
    PaletteItem(
      name: 'Magenta',
      base: Colors.primaries[5],                 // Magenta equivalent (Base)
      light: Colors.pink.shade100,               // Light shade
      dark: Colors.purple.shade900,              // Dark shade
    ),
    PaletteItem(
      name: 'White',
      base: Colors.white,                        // White1 (Base)
      light: Colors.white,                       // White stays white
      dark: Colors.grey.shade300,                // White3 (Darker option going to light gray)
    ),
    PaletteItem(
      name: 'Black',
      base: Colors.black,                        // Black1 (Base)
      light: Colors.grey.shade700,               // Black2 (Lighter option going to dark gray)
      dark: Colors.black,                        // Black stays black
    ),
  ];

  /// Convenient getter to get all base colors (Color1) for the main palette sidebar
  static List<Color> get baseColors => items.map((item) => item.base).toList();

  /// Map used to feed directly into your ColorPalette widget's customShadesMap
  static Map<Color, List<Color>> get shadesMap {
    return {
      for (var item in items) item.base: item.shades
    };
  }
}
// //It contains all colors used in app

import 'package:flutter/material.dart';

class Tile {
  final Color tileColor;
  final Color tileBorderColor;

  Tile(this.tileColor, this.tileBorderColor);
}

class CatalogueColors {
  static final List<Tile> tiles = [
    Tile(const Color(0xFFEEF7F1), const Color(0xFF82C69A)),
    Tile(const Color(0xFFFEF6ED), const Color(0xFFFABD7C)),
    Tile(const Color(0xFFFDE8E4), const Color(0xFFF7A593)),
    Tile(const Color(0xFFF4EBF7), const Color(0xFFD3B0E0)),
    Tile(const Color(0xFFFFF8E5), const Color(0xFFFDE598)),
    Tile(const Color(0xFFEDF7FC), const Color(0xFFB7DFF5)),
    Tile(const Color(0xFFE9E6FB), const Color(0xFFB6A9F8)),
    Tile(const Color(0xFFF5DFE7), const Color(0xFFE68FB0)),
  ];
}

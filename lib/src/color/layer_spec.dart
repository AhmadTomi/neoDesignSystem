import 'package:flutter/material.dart';

/// Metadata information for individual layers for display & inspection.
class LayerSpec {
  final String id;
  final String label;
  final String role;
  final double l;
  final double c;
  final Color color;
  final String hex;
  final String formula;

  const LayerSpec({
    required this.id,
    required this.label,
    required this.role,
    required this.l,
    required this.c,
    required this.color,
    required this.hex,
    required this.formula,
  });
}

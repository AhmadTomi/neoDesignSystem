import 'package:flutter/material.dart';
import '../shape/app_radius_theme.dart';
import '../spacing/app_spacing_theme.dart';
import 'theme_preset.dart';

/// JSON serializable configuration model for exporting and importing theme presets.
class ThemeConfig {
  final String id;
  final String name;
  final String description;
  final String lightAnchorHex;
  final String darkAnchorHex;
  final String primaryHex;
  final String shape;
  final String density;
  final String? fontFamily;

  const ThemeConfig({
    required this.id,
    required this.name,
    this.description = '',
    required this.lightAnchorHex,
    required this.darkAnchorHex,
    required this.primaryHex,
    required this.shape,
    required this.density,
    this.fontFamily,
  });

  /// Creates a [ThemeConfig] from a [ThemePreset].
  factory ThemeConfig.fromPreset(ThemePreset preset) {
    return ThemeConfig(
      id: preset.id,
      name: preset.name,
      description: preset.description,
      lightAnchorHex: _colorToHex(preset.lightAnchor),
      darkAnchorHex: _colorToHex(preset.darkAnchor),
      primaryHex: _colorToHex(preset.primaryColor),
      shape: preset.shape == ShapePreset.sharp ? 'sharp' : 'rounded',
      density: preset.density == DensityPreset.compact ? 'compact' : 'comfortable',
      fontFamily: preset.fontFamily,
    );
  }

  /// Converts this configuration into a runnable [ThemePreset].
  ThemePreset toPreset() {
    return ThemePreset(
      id: id,
      name: name,
      description: description,
      lightAnchor: _parseHex(lightAnchorHex),
      darkAnchor: _parseHex(darkAnchorHex),
      primaryColor: _parseHex(primaryHex),
      shape: shape == 'sharp' ? ShapePreset.sharp : ShapePreset.rounded,
      density: density == 'compact' ? DensityPreset.compact : DensityPreset.comfortable,
      fontFamily: fontFamily,
      isBuiltIn: false,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'lightAnchorHex': lightAnchorHex,
    'darkAnchorHex': darkAnchorHex,
    'primaryHex': primaryHex,
    'shape': shape,
    'density': density,
    if (fontFamily != null) 'fontFamily': fontFamily,
  };

  /// Deserializes from JSON map.
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      id: json['id'] as String? ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Custom Preset',
      description: json['description'] as String? ?? '',
      lightAnchorHex: json['lightAnchorHex'] as String? ?? '#F4F5F7',
      darkAnchorHex: json['darkAnchorHex'] as String? ?? '#101010',
      primaryHex: json['primaryHex'] as String? ?? '#2563EB',
      shape: json['shape'] as String? ?? 'rounded',
      density: json['density'] as String? ?? 'comfortable',
      fontFamily: json['fontFamily'] as String?,
    );
  }

  static String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  static Color _parseHex(String hex) {
    var clean = hex.replaceAll('#', '').trim();
    if (clean.length == 6) {
      clean = 'FF$clean';
    }
    return Color(int.parse(clean, radix: 16));
  }
}

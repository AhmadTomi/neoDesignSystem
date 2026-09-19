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
  final double? baseRadius;
  final String density;
  final double? baseSpacing;
  final String? fontFamily;
  final double baseFontSize;
  final int? minFontWeightValue;

  const ThemeConfig({
    required this.id,
    required this.name,
    this.description = '',
    required this.lightAnchorHex,
    required this.darkAnchorHex,
    required this.primaryHex,
    required this.shape,
    this.baseRadius,
    required this.density,
    this.baseSpacing,
    this.fontFamily,
    this.baseFontSize = 14.0,
    this.minFontWeightValue,
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
      baseRadius: preset.baseRadius,
      density: preset.density == DensityPreset.compact ? 'compact' : 'comfortable',
      baseSpacing: preset.baseSpacing,
      fontFamily: preset.fontFamily,
      baseFontSize: preset.baseFontSize,
      minFontWeightValue: preset.minFontWeight?.value,
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
      baseRadius: baseRadius,
      density: density == 'compact' ? DensityPreset.compact : DensityPreset.comfortable,
      baseSpacing: baseSpacing,
      fontFamily: fontFamily,
      baseFontSize: baseFontSize,
      minFontWeight: minFontWeightValue != null
          ? FontWeight.values.where((w) => w.value == minFontWeightValue).firstOrNull
          : null,
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
    if (baseRadius != null) 'baseRadius': baseRadius,
    'density': density,
    if (baseSpacing != null) 'baseSpacing': baseSpacing,
    if (fontFamily != null) 'fontFamily': fontFamily,
    'baseFontSize': baseFontSize,
    if (minFontWeightValue != null) 'minFontWeightValue': minFontWeightValue,
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
      baseRadius: (json['baseRadius'] as num?)?.toDouble(),
      density: json['density'] as String? ?? 'comfortable',
      baseSpacing: (json['baseSpacing'] as num?)?.toDouble(),
      fontFamily: json['fontFamily'] as String?,
      baseFontSize: (json['baseFontSize'] as num?)?.toDouble() ?? 14.0,
      minFontWeightValue: json['minFontWeightValue'] as int?,
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

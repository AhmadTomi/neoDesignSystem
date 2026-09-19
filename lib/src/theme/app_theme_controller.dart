import 'dart:convert';
import 'package:flutter/material.dart';
import '../shape/app_radius_theme.dart';
import '../spacing/app_spacing_theme.dart';
import 'theme_config.dart';
import 'theme_preset.dart';

/// Central state management controller for on-the-fly theme switching, editing, saving, and loading presets.
class AppThemeController extends ChangeNotifier {
  ThemePreset _currentPreset;
  final List<ThemePreset> _customPresets = [];
  ThemeMode _themeMode;

  AppThemeController({
    ThemePreset? initialPreset,
    ThemeMode initialThemeMode = ThemeMode.system,
  })  : _currentPreset = initialPreset ?? BuiltInPresets.slate,
        _themeMode = initialThemeMode;

  /// The currently active preset.
  ThemePreset get currentPreset => _currentPreset;

  /// Active shape preset (rounded vs sharp).
  ShapePreset get shape => _currentPreset.shape;

  /// Active density preset (comfortable vs compact).
  DensityPreset get density => _currentPreset.density;

  /// The active ThemeMode (system, light, dark).
  ThemeMode get themeMode => _themeMode;

  /// All available presets (built-in presets followed by user custom presets).
  List<ThemePreset> get allPresets => [
        ...BuiltInPresets.all,
        ..._customPresets,
      ];

  /// Set the active ThemeMode.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  /// Select a preset by instance.
  void setPreset(ThemePreset preset) {
    _currentPreset = preset;
    notifyListeners();
  }

  /// Select a preset by ID.
  bool selectPresetById(String id) {
    final match = allPresets.where((p) => p.id == id).firstOrNull;
    if (match != null) {
      setPreset(match);
      return true;
    }
    return false;
  }

  /// Toggle or set the shape preset (rounded vs sharp) on the fly.
  void setShape(ShapePreset shape) {
    if (_currentPreset.shape == shape) return;
    _currentPreset = _currentPreset.copyWith(shape: shape);
    notifyListeners();
  }

  /// Toggle or set the density preset (comfortable vs compact) on the fly.
  void setDensity(DensityPreset density) {
    if (_currentPreset.density == density) return;
    _currentPreset = _currentPreset.copyWith(density: density);
    notifyListeners();
  }

  /// Update the light mode anchor color on the fly.
  void updateLightAnchor(Color color) {
    _currentPreset = _currentPreset.copyWith(lightAnchor: color);
    notifyListeners();
  }

  /// Update the dark mode anchor color on the fly.
  void updateDarkAnchor(Color color) {
    _currentPreset = _currentPreset.copyWith(darkAnchor: color);
    notifyListeners();
  }

  /// Update the primary brand color on the fly.
  void updatePrimaryColor(Color color) {
    _currentPreset = _currentPreset.copyWith(primaryColor: color);
    notifyListeners();
  }

  /// Save current configuration as a new custom preset.
  ThemePreset saveCustomPreset(String name, {String description = ''}) {
    final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final custom = _currentPreset.copyWith(
      id: newId,
      name: name,
      description: description,
      isBuiltIn: false,
    );
    _customPresets.add(custom);
    _currentPreset = custom;
    notifyListeners();
    return custom;
  }

  /// Delete a custom preset by ID.
  bool deleteCustomPreset(String id) {
    final index = _customPresets.indexWhere((p) => p.id == id);
    if (index != -1) {
      final removed = _customPresets.removeAt(index);
      if (_currentPreset.id == removed.id) {
        _currentPreset = BuiltInPresets.slate;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Exports the active (or given) preset as a formatted JSON string.
  String exportPresetJson([ThemePreset? preset]) {
    final target = preset ?? _currentPreset;
    final config = ThemeConfig.fromPreset(target);
    return const JsonEncoder.withIndent('  ').convert(config.toJson());
  }

  /// Alias for [exportPresetJson].
  String exportCurrentPresetAsJson() => exportPresetJson();

  /// Imports a preset from a JSON string and activates it.
  ThemePreset importPresetJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final config = ThemeConfig.fromJson(decoded);
    final preset = config.toPreset();
    _customPresets.add(preset);
    _currentPreset = preset;
    notifyListeners();
    return preset;
  }

  /// Alias for [importPresetJson].
  ThemePreset importPresetFromJson(String jsonString) => importPresetJson(jsonString);

  /// Builds a [ThemeData] for either light or dark mode based on the current preset.
  ThemeData buildThemeData({required bool isDark}) {
    return _currentPreset.toThemeData(isDark: isDark);
  }
}

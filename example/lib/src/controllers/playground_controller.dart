import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';
import '../models/color_picker_target.dart';
import '../theme/neo_trading_theme.dart';

/// Central state controller managing theme preset, anchor parameters, and dynamic OKLCH palettes.
class PlaygroundController extends ChangeNotifier {
  PlaygroundController() {
    _themeController = AppThemeController(
      initialPreset: NeoTradingTheme.preset,
      initialCustomPresets: [NeoTradingTheme.preset],
    );
    applyPreset(NeoTradingTheme.preset, notify: false);
  }

  late final AppThemeController _themeController;
  AppThemeController get themeController => _themeController;

  ThemePreset get currentPreset => _themeController.currentPreset;
  List<ThemePreset> get allPresets => _themeController.allPresets;

  ShapePreset _shape = ShapePreset.rounded;
  ShapePreset get shape => _shape;

  DensityPreset _density = DensityPreset.comfortable;
  DensityPreset get density => _density;

  bool _highContrast = false;
  bool get highContrast => _highContrast;

  // Configurable OKLCH anchor parameters for LIGHT MODE
  double _lightAnchorL = 0.970;
  double _lightChroma = 0.003;
  double _lightHue = 264.5;
  final double _lightC2Delta = 0.018;
  final double _lightTroughDelta = 0.030;
  Color _lightAnchorColor = const Color(0xFFF4F5F7);
  Color get lightAnchorColor => _lightAnchorColor;

  // Configurable OKLCH anchor parameters for DARK MODE
  static const _defaultDark = Color(0xFF181818);
  static final _darkOklch = OklchColor.fromColor(_defaultDark);
  double _darkAnchorL = _darkOklch.l;
  double _darkChroma = _darkOklch.c;
  double _darkHue = _darkOklch.h;
  final double _darkC2Delta = 0.022;
  final double _darkTroughDelta = 0.018;
  Color _darkAnchorColor = _defaultDark;
  Color get darkAnchorColor => _darkAnchorColor;

  // Base semantic & brand colors
  Color _primaryColor = const Color(0xFF2563EB);
  Color get primaryColor => _primaryColor;

  Color _successColor = const Color(0xFF10B981);
  Color get successColor => _successColor;

  Color _warningColor = const Color(0xFFF59E0B);
  Color get warningColor => _warningColor;

  Color _errorColor = const Color(0xFFEF4444);
  Color get errorColor => _errorColor;

  Color _infoColor = const Color(0xFF06B6D4);
  Color get infoColor => _infoColor;

  // Mode-specific color overrides
  Color? _darkPrimaryColor;
  Color? _lightPrimaryColor;
  Color? _darkSuccessColor;
  Color? _lightSuccessColor;
  Color? _darkWarningColor;
  Color? _lightWarningColor;
  Color? _darkErrorColor;
  Color? _lightErrorColor;
  Color? _darkInfoColor;
  Color? _lightInfoColor;
  Color? _borderColor;
  Color? _darkBorderColor;
  Color? _lightBorderColor;
  Color? _dividerColor;
  Color? _darkDividerColor;
  Color? _lightDividerColor;
  Color? _whiteColor;

  bool _showControls = true;
  bool get showControls => _showControls;

  void toggleControls() {
    _showControls = !_showControls;
    notifyListeners();
  }

  void setShape(ShapePreset newShape) {
    _shape = newShape;
    _themeController.setShape(newShape);
    notifyListeners();
  }

  void setDensity(DensityPreset newDensity) {
    _density = newDensity;
    _themeController.setDensity(newDensity);
    notifyListeners();
  }

  void setHighContrast(bool value) {
    _highContrast = value;
    _themeController.setHighContrast(value);
    notifyListeners();
  }

  void toggleHighContrast() {
    setHighContrast(!_highContrast);
  }

  void applyPreset(ThemePreset preset, {bool notify = true}) {
    _themeController.setPreset(preset);
    _shape = preset.shape;
    _density = preset.density;
    _highContrast = preset.highContrast;
    _lightAnchorColor = preset.lightAnchor;
    _darkAnchorColor = preset.darkAnchor;

    _primaryColor = preset.primaryColor;
    _darkPrimaryColor = preset.darkPrimaryColor;
    _lightPrimaryColor = preset.lightPrimaryColor;

    _errorColor = preset.errorColor ?? const Color(0xFFEF4444);
    _darkErrorColor = preset.darkErrorColor;
    _lightErrorColor = preset.lightErrorColor;

    _warningColor = preset.warningColor ?? const Color(0xFFF59E0B);
    _darkWarningColor = preset.darkWarningColor;
    _lightWarningColor = preset.lightWarningColor;

    _infoColor = preset.infoColor ?? const Color(0xFF06B6D4);
    _darkInfoColor = preset.darkInfoColor;
    _lightInfoColor = preset.lightInfoColor;

    _successColor = preset.successColor ?? const Color(0xFF10B981);
    _darkSuccessColor = preset.darkSuccessColor;
    _lightSuccessColor = preset.lightSuccessColor;

    _borderColor = preset.borderColor;
    _darkBorderColor = preset.darkBorderColor;
    _lightBorderColor = preset.lightBorderColor;

    _dividerColor = preset.dividerColor;
    _darkDividerColor = preset.darkDividerColor;
    _lightDividerColor = preset.lightDividerColor;

    _whiteColor = preset.whiteColor;

    final oklchL = OklchColor.fromColor(_lightAnchorColor);
    _lightHue = oklchL.h;
    _lightChroma = oklchL.c.clamp(0.0, 0.15);
    _lightAnchorL = oklchL.l.clamp(0.80, 0.98);

    final oklchD = OklchColor.fromColor(_darkAnchorColor);
    _darkHue = oklchD.h;
    _darkChroma = oklchD.c.clamp(0.0, 0.15);
    _darkAnchorL = oklchD.l.clamp(0.10, 0.40);

    if (notify) notifyListeners();
  }

  Color getColor(ColorPickerTarget target, {bool? isDark}) {
    if (isDark == true) {
      return switch (target) {
        ColorPickerTarget.lightAnchor => _lightAnchorColor,
        ColorPickerTarget.darkAnchor => _darkAnchorColor,
        ColorPickerTarget.primary => darkPalette.primary,
        ColorPickerTarget.success => darkPalette.success,
        ColorPickerTarget.warning => darkPalette.warning,
        ColorPickerTarget.error => darkPalette.error,
        ColorPickerTarget.info => darkPalette.info,
      };
    } else if (isDark == false) {
      return switch (target) {
        ColorPickerTarget.lightAnchor => _lightAnchorColor,
        ColorPickerTarget.darkAnchor => _darkAnchorColor,
        ColorPickerTarget.primary => lightPalette.primary,
        ColorPickerTarget.success => lightPalette.success,
        ColorPickerTarget.warning => lightPalette.warning,
        ColorPickerTarget.error => lightPalette.error,
        ColorPickerTarget.info => lightPalette.info,
      };
    }
    return switch (target) {
      ColorPickerTarget.lightAnchor => _lightAnchorColor,
      ColorPickerTarget.darkAnchor => _darkAnchorColor,
      ColorPickerTarget.primary => _primaryColor,
      ColorPickerTarget.success => _successColor,
      ColorPickerTarget.warning => _warningColor,
      ColorPickerTarget.error => _errorColor,
      ColorPickerTarget.info => _infoColor,
    };
  }

  void updateColor(Color newColor, {required ColorPickerTarget target, bool? isDark}) {
    switch (target) {
      case ColorPickerTarget.primary:
        _primaryColor = newColor;
        if (isDark == true) {
          _darkPrimaryColor = newColor;
        } else if (isDark == false) {
          _lightPrimaryColor = newColor;
        } else {
          _darkPrimaryColor = null;
          _lightPrimaryColor = null;
        }
        break;
      case ColorPickerTarget.success:
        _successColor = newColor;
        if (isDark == true) {
          _darkSuccessColor = newColor;
        } else if (isDark == false) {
          _lightSuccessColor = newColor;
        } else {
          _darkSuccessColor = null;
          _lightSuccessColor = null;
        }
        break;
      case ColorPickerTarget.warning:
        _warningColor = newColor;
        if (isDark == true) {
          _darkWarningColor = newColor;
        } else if (isDark == false) {
          _lightWarningColor = newColor;
        } else {
          _darkWarningColor = null;
          _lightWarningColor = null;
        }
        break;
      case ColorPickerTarget.error:
        _errorColor = newColor;
        if (isDark == true) {
          _darkErrorColor = newColor;
        } else if (isDark == false) {
          _lightErrorColor = newColor;
        } else {
          _darkErrorColor = null;
          _lightErrorColor = null;
        }
        break;
      case ColorPickerTarget.info:
        _infoColor = newColor;
        if (isDark == true) {
          _darkInfoColor = newColor;
        } else if (isDark == false) {
          _lightInfoColor = newColor;
        } else {
          _darkInfoColor = null;
          _lightInfoColor = null;
        }
        break;
      case ColorPickerTarget.lightAnchor:
        _lightAnchorColor = newColor;
        final oklch = OklchColor.fromColor(newColor);
        _lightHue = oklch.h;
        _lightChroma = oklch.c.clamp(0.0, 0.15);
        _lightAnchorL = oklch.l.clamp(0.80, 0.98);
        break;
      case ColorPickerTarget.darkAnchor:
        _darkAnchorColor = newColor;
        final oklch = OklchColor.fromColor(newColor);
        _darkHue = oklch.h;
        _darkChroma = oklch.c.clamp(0.0, 0.15);
        _darkAnchorL = oklch.l.clamp(0.10, 0.40);
        break;
    }
    notifyListeners();
  }

  ThemePreset buildCurrentPreset({String? id, String? name}) {
    return ThemePreset(
      id: id ?? currentPreset.id,
      name: name ?? currentPreset.name,
      description: currentPreset.description,
      lightAnchor: _lightAnchorColor,
      darkAnchor: _darkAnchorColor,
      primaryColor: _primaryColor,
      darkPrimaryColor: _darkPrimaryColor,
      lightPrimaryColor: _lightPrimaryColor,
      errorColor: _errorColor,
      darkErrorColor: _darkErrorColor,
      lightErrorColor: _lightErrorColor,
      warningColor: _warningColor,
      darkWarningColor: _darkWarningColor,
      lightWarningColor: _lightWarningColor,
      infoColor: _infoColor,
      darkInfoColor: _darkInfoColor,
      lightInfoColor: _lightInfoColor,
      successColor: _successColor,
      darkSuccessColor: _darkSuccessColor,
      lightSuccessColor: _lightSuccessColor,
      borderColor: _borderColor,
      darkBorderColor: _darkBorderColor,
      lightBorderColor: _lightBorderColor,
      dividerColor: _dividerColor,
      darkDividerColor: _darkDividerColor,
      lightDividerColor: _lightDividerColor,
      whiteColor: _whiteColor,
      shape: _shape,
      density: _density,
      highContrast: _highContrast,
    );
  }

  String exportPresetJson(ThemePreset preset) {
    return _themeController.exportPresetJson(preset);
  }

  ThemePreset saveCustomPreset(String name) {
    final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final custom = buildCurrentPreset(
      id: newId,
      name: name.isEmpty ? 'Custom Theme' : name,
    );
    _themeController.addCustomPreset(custom);
    _themeController.setPreset(custom);
    applyPreset(custom);
    return custom;
  }

  void addCustomPreset(ThemePreset preset) {
    _themeController.addCustomPreset(preset);
    applyPreset(preset);
  }

  void importPresetJson(String jsonString) {
    final imported = _themeController.importPresetJson(jsonString);
    applyPreset(imported);
  }

  LayerPalette get lightPalette {
    return LayerPalette.fromAnchor(
      anchorL: _lightAnchorL,
      c: _lightChroma,
      h: _lightHue,
      isDark: false,
      highContrast: _highContrast,
      c2Delta: _lightC2Delta,
      troughDelta: _lightTroughDelta,
      primaryColor: _primaryColor,
      darkPrimaryColor: _darkPrimaryColor,
      lightPrimaryColor: _lightPrimaryColor,
      successColor: _successColor,
      darkSuccessColor: _darkSuccessColor,
      lightSuccessColor: _lightSuccessColor,
      warningColor: _warningColor,
      darkWarningColor: _darkWarningColor,
      lightWarningColor: _lightWarningColor,
      errorColor: _errorColor,
      darkErrorColor: _darkErrorColor,
      lightErrorColor: _lightErrorColor,
      infoColor: _infoColor,
      darkInfoColor: _darkInfoColor,
      lightInfoColor: _lightInfoColor,
      borderColor: _borderColor,
      darkBorderColor: _darkBorderColor,
      lightBorderColor: _lightBorderColor,
      dividerColor: _dividerColor,
      darkDividerColor: _darkDividerColor,
      lightDividerColor: _lightDividerColor,
      whiteColor: _whiteColor,
    );
  }

  LayerPalette get darkPalette {
    return LayerPalette.fromAnchor(
      anchorL: _darkAnchorL,
      c: _darkChroma,
      h: _darkHue,
      isDark: true,
      highContrast: _highContrast,
      c2Delta: _darkC2Delta,
      troughDelta: _darkTroughDelta,
      primaryColor: _primaryColor,
      darkPrimaryColor: _darkPrimaryColor,
      lightPrimaryColor: _lightPrimaryColor,
      successColor: _successColor,
      darkSuccessColor: _darkSuccessColor,
      lightSuccessColor: _lightSuccessColor,
      warningColor: _warningColor,
      darkWarningColor: _darkWarningColor,
      lightWarningColor: _lightWarningColor,
      errorColor: _errorColor,
      darkErrorColor: _darkErrorColor,
      lightErrorColor: _lightErrorColor,
      infoColor: _infoColor,
      darkInfoColor: _darkInfoColor,
      lightInfoColor: _lightInfoColor,
      borderColor: _borderColor,
      darkBorderColor: _darkBorderColor,
      lightBorderColor: _lightBorderColor,
      dividerColor: _dividerColor,
      darkDividerColor: _darkDividerColor,
      lightDividerColor: _lightDividerColor,
      whiteColor: _whiteColor,
    );
  }

  AppRadiusTheme get radiusTheme {
    return AppRadiusTheme.create(
      baseRadius: currentPreset.baseRadius ??
          (_shape == ShapePreset.sharp ? 0.0 : 12.0),
      shape: _shape,
    );
  }

  AppSpacingTheme get spacingTheme {
    return AppSpacingTheme.create(
      baseSpacing: currentPreset.baseSpacing ??
          (_density == DensityPreset.compact ? 10.0 : 16.0),
      density: _density,
    );
  }
}

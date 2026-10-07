import 'package:flutter/material.dart';
import '../color/app_color_theme.dart';
import '../shape/app_radius_theme.dart';
import '../spacing/app_spacing_theme.dart';
import '../typography/app_typography.dart';
import 'theme_tokens.dart';

/// A self-contained Design System Theme Preset.
class ThemePreset {
  final String id;
  final String name;
  final String description;

  /// Anchor color for light mode (Flutter Color).
  final Color lightAnchor;

  /// Anchor color for dark mode (Flutter Color).
  final Color darkAnchor;

  /// Brand accent color (Flutter Color).
  final Color primaryColor;

  /// Optional exact dark mode override for primary brand color.
  final Color? darkPrimaryColor;

  /// Optional exact light mode override for primary brand color.
  final Color? lightPrimaryColor;

  /// Optional semantic error color override.
  final Color? errorColor;

  /// Optional exact dark mode override for error color.
  final Color? darkErrorColor;

  /// Optional exact light mode override for error color.
  final Color? lightErrorColor;

  /// Optional semantic warning color override.
  final Color? warningColor;

  /// Optional exact dark mode override for warning color.
  final Color? darkWarningColor;

  /// Optional exact light mode override for warning color.
  final Color? lightWarningColor;

  /// Optional semantic info color override.
  final Color? infoColor;

  /// Optional exact dark mode override for info color.
  final Color? darkInfoColor;

  /// Optional exact light mode override for info color.
  final Color? lightInfoColor;

  /// Optional semantic success color override.
  final Color? successColor;

  /// Optional exact dark mode override for success color.
  final Color? darkSuccessColor;

  /// Optional exact light mode override for success color.
  final Color? lightSuccessColor;

  /// Optional custom border color override (derives containerBorder and dividerLine).
  final Color? borderColor;

  /// Optional exact dark mode override for border color.
  final Color? darkBorderColor;

  /// Optional exact light mode override for border color.
  final Color? lightBorderColor;

  /// Optional custom divider color override.
  final Color? dividerColor;

  /// Optional exact dark mode override for divider color.
  final Color? darkDividerColor;

  /// Optional exact light mode override for divider color.
  final Color? lightDividerColor;

  /// Optional custom white tone (defaults to pure #FFFFFF).
  /// Used for text on solid background widgets and dark theme foregrounds.
  final Color? whiteColor;

  /// Corner radius scale preset.
  final ShapePreset shape;

  /// Optional base corner radius anchor (default 12.0 for rounded, 0.0 for sharp).
  final double? baseRadius;

  /// Spacing and insets density profile.
  final DensityPreset density;

  /// Optional base spacing anchor (default 16.0 for comfortable, 10.0 for compact).
  final double? baseSpacing;

  /// Optional custom font family (defaults to 'Inter').
  final String? fontFamily;

  /// Base font size anchor for typography (defaults to 14.0).
  final double baseFontSize;

  /// Optional minimum font weight clamp. When set, all styles with a weight below this
  /// are automatically elevated to this weight.
  final FontWeight? minFontWeight;

  /// Optional typography geometry override.
  final AppTypography? typography;

  /// Optional callback to customize ThemeData with full access to [ThemeTokens].
  final ThemeModifier? themeModifier;

  /// Indicates if this is a built-in system preset.
  final bool isBuiltIn;

  const ThemePreset({
    required this.id,
    required this.name,
    this.description = '',
    required this.lightAnchor,
    required this.darkAnchor,
    required this.primaryColor,
    this.darkPrimaryColor,
    this.lightPrimaryColor,
    this.errorColor,
    this.darkErrorColor,
    this.lightErrorColor,
    this.warningColor,
    this.darkWarningColor,
    this.lightWarningColor,
    this.infoColor,
    this.darkInfoColor,
    this.lightInfoColor,
    this.successColor,
    this.darkSuccessColor,
    this.lightSuccessColor,
    this.borderColor,
    this.darkBorderColor,
    this.lightBorderColor,
    this.dividerColor,
    this.darkDividerColor,
    this.lightDividerColor,
    this.whiteColor,
    this.shape = ShapePreset.rounded,
    this.baseRadius,
    this.density = DensityPreset.comfortable,
    this.baseSpacing,
    this.fontFamily,
    this.baseFontSize = 14.0,
    this.minFontWeight,
    this.typography,
    this.themeModifier,
    this.isBuiltIn = false,
  });

  /// Builds a complete Flutter [ThemeData] with all token extensions registered.
  ThemeData toThemeData({required bool isDark}) {
    final anchor = isDark ? darkAnchor : lightAnchor;

    // 1. Generate AppColorTheme
    final colorTheme = AppColorTheme.fromColor(
      anchorColor: anchor,
      isDark: isDark,
      primaryColor: primaryColor,
      darkPrimaryColor: darkPrimaryColor,
      lightPrimaryColor: lightPrimaryColor,
      errorColor: errorColor,
      darkErrorColor: darkErrorColor,
      lightErrorColor: lightErrorColor,
      warningColor: warningColor,
      darkWarningColor: darkWarningColor,
      lightWarningColor: lightWarningColor,
      infoColor: infoColor,
      darkInfoColor: darkInfoColor,
      lightInfoColor: lightInfoColor,
      successColor: successColor,
      darkSuccessColor: darkSuccessColor,
      lightSuccessColor: lightSuccessColor,
      borderColor: borderColor,
      darkBorderColor: darkBorderColor,
      lightBorderColor: lightBorderColor,
      dividerColor: dividerColor,
      darkDividerColor: darkDividerColor,
      lightDividerColor: lightDividerColor,
      whiteColor: whiteColor,
    );

    // 2. Generate AppRadiusTheme
    final radiusTheme = AppRadiusTheme.create(
      baseRadius: baseRadius ?? (shape == ShapePreset.sharp ? 0.0 : 12.0),
      shape: shape,
    );

    // 3. Generate AppSpacingTheme
    final spacingTheme = AppSpacingTheme.create(
      baseSpacing: baseSpacing ?? (density == DensityPreset.compact ? 10.0 : 16.0),
      density: density,
    );

    // 4. Generate Typography
    final typographyTheme = typography ??
        AppTypography.create(
          fontFamily: fontFamily ?? 'Inter',
          baseFontSize: baseFontSize,
          isCompact: density == DensityPreset.compact,
          minFontWeight: minFontWeight,
        );

    // 5. Bundle into ThemeTokens
    final tokens = ThemeTokens(
      color: colorTheme,
      radius: radiusTheme,
      spacing: spacingTheme,
      typography: typographyTheme,
    );

    // 6. Build base ThemeData
    var theme = ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colorTheme.primary,
        onPrimary: colorTheme.onPrimary,
        secondary: colorTheme.primary,
        onSecondary: colorTheme.onPrimary,
        error: colorTheme.error,
        onError: colorTheme.onError,
        surface: colorTheme.container3,
        onSurface: colorTheme.textMain,
        surfaceContainerLowest: colorTheme.container1,
        surfaceContainerLow: colorTheme.container1,
        surfaceContainer: colorTheme.container2,
        surfaceContainerHigh: colorTheme.container3,
        surfaceContainerHighest: colorTheme.container4,
        outline: colorTheme.textFieldBorder,
        outlineVariant: colorTheme.dividerLine,
      ),
      scaffoldBackgroundColor: colorTheme.container1,
      textTheme: typographyTheme.toTextTheme(colorTheme.textMain),
      extensions: [
        colorTheme,
        radiusTheme,
        spacingTheme,
      ],
      // Standard Component Theme Defaults using Token instances
      cardTheme: CardThemeData(
        color: colorTheme.container3,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusTheme.lg.all,
          side: BorderSide(color: colorTheme.containerBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorTheme.container4,
        shape: RoundedRectangleBorder(
          borderRadius: radiusTheme.xl.all,
          side: BorderSide(color: colorTheme.containerBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorTheme.primary,
          foregroundColor: colorTheme.onPrimary,
          padding: spacingTheme.insetSquish,
          shape: RoundedRectangleBorder(borderRadius: radiusTheme.md.all),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorTheme.textFieldFill,
        contentPadding: spacingTheme.insetSquish,
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusTheme.md.all,
          borderSide: BorderSide(color: colorTheme.textFieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusTheme.md.all,
          borderSide: BorderSide(color: colorTheme.primary, width: 1.8),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: radiusTheme.md.all,
          borderSide: BorderSide(color: colorTheme.textFieldDisabledBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusTheme.md.all,
          borderSide: BorderSide(color: colorTheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radiusTheme.md.all,
          borderSide: BorderSide(color: colorTheme.error, width: 1.8),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorTheme.dividerLine,
        thickness: 1.0,
        space: 1.0,
      ),
    );

    // 7. Apply ThemeModifier if provided
    if (themeModifier != null) {
      theme = themeModifier!(theme, tokens);
    }

    return theme;
  }

  ThemePreset copyWith({
    String? id,
    String? name,
    String? description,
    Color? lightAnchor,
    Color? darkAnchor,
    Color? primaryColor,
    Color? darkPrimaryColor,
    Color? lightPrimaryColor,
    Color? errorColor,
    Color? darkErrorColor,
    Color? lightErrorColor,
    Color? warningColor,
    Color? darkWarningColor,
    Color? lightWarningColor,
    Color? infoColor,
    Color? darkInfoColor,
    Color? lightInfoColor,
    Color? successColor,
    Color? darkSuccessColor,
    Color? lightSuccessColor,
    Color? borderColor,
    Color? darkBorderColor,
    Color? lightBorderColor,
    Color? dividerColor,
    Color? darkDividerColor,
    Color? lightDividerColor,
    Color? whiteColor,
    bool clearDarkPrimaryColor = false,
    bool clearLightPrimaryColor = false,
    bool clearDarkErrorColor = false,
    bool clearLightErrorColor = false,
    bool clearDarkWarningColor = false,
    bool clearLightWarningColor = false,
    bool clearDarkInfoColor = false,
    bool clearLightInfoColor = false,
    bool clearDarkSuccessColor = false,
    bool clearLightSuccessColor = false,
    bool clearBorderColor = false,
    bool clearDarkBorderColor = false,
    bool clearLightBorderColor = false,
    bool clearDividerColor = false,
    bool clearDarkDividerColor = false,
    bool clearLightDividerColor = false,
    bool clearWhiteColor = false,
    ShapePreset? shape,
    double? baseRadius,
    DensityPreset? density,
    double? baseSpacing,
    String? fontFamily,
    double? baseFontSize,
    FontWeight? minFontWeight,
    bool clearMinFontWeight = false,
    AppTypography? typography,
    ThemeModifier? themeModifier,
    bool? isBuiltIn,
  }) {
    return ThemePreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      lightAnchor: lightAnchor ?? this.lightAnchor,
      darkAnchor: darkAnchor ?? this.darkAnchor,
      primaryColor: primaryColor ?? this.primaryColor,
      darkPrimaryColor: clearDarkPrimaryColor ? null : (darkPrimaryColor ?? this.darkPrimaryColor),
      lightPrimaryColor: clearLightPrimaryColor ? null : (lightPrimaryColor ?? this.lightPrimaryColor),
      errorColor: errorColor ?? this.errorColor,
      darkErrorColor: clearDarkErrorColor ? null : (darkErrorColor ?? this.darkErrorColor),
      lightErrorColor: clearLightErrorColor ? null : (lightErrorColor ?? this.lightErrorColor),
      warningColor: warningColor ?? this.warningColor,
      darkWarningColor: clearDarkWarningColor ? null : (darkWarningColor ?? this.darkWarningColor),
      lightWarningColor: clearLightWarningColor ? null : (lightWarningColor ?? this.lightWarningColor),
      infoColor: infoColor ?? this.infoColor,
      darkInfoColor: clearDarkInfoColor ? null : (darkInfoColor ?? this.darkInfoColor),
      lightInfoColor: clearLightInfoColor ? null : (lightInfoColor ?? this.lightInfoColor),
      successColor: successColor ?? this.successColor,
      darkSuccessColor: clearDarkSuccessColor ? null : (darkSuccessColor ?? this.darkSuccessColor),
      lightSuccessColor: clearLightSuccessColor ? null : (lightSuccessColor ?? this.lightSuccessColor),
      borderColor: clearBorderColor ? null : (borderColor ?? this.borderColor),
      darkBorderColor: clearDarkBorderColor ? null : (darkBorderColor ?? this.darkBorderColor),
      lightBorderColor: clearLightBorderColor ? null : (lightBorderColor ?? this.lightBorderColor),
      dividerColor: clearDividerColor ? null : (dividerColor ?? this.dividerColor),
      darkDividerColor: clearDarkDividerColor ? null : (darkDividerColor ?? this.darkDividerColor),
      lightDividerColor: clearLightDividerColor ? null : (lightDividerColor ?? this.lightDividerColor),
      whiteColor: clearWhiteColor ? null : (whiteColor ?? this.whiteColor),
      shape: shape ?? this.shape,
      baseRadius: baseRadius ?? this.baseRadius,
      density: density ?? this.density,
      baseSpacing: baseSpacing ?? this.baseSpacing,
      fontFamily: fontFamily ?? this.fontFamily,
      baseFontSize: baseFontSize ?? this.baseFontSize,
      minFontWeight: clearMinFontWeight ? null : (minFontWeight ?? this.minFontWeight),
      typography: typography ?? this.typography,
      themeModifier: themeModifier ?? this.themeModifier,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }
}

/// Collection of curated built-in theme presets.
abstract final class BuiltInPresets {
  /// Default Slate: Clean cool neutral with modern rounded cards and comfortable density.
  static const slate = ThemePreset(
    id: 'default_slate',
    name: 'Default Slate',
    description: 'Neutral cool slate with modern rounded surfaces',
    lightAnchor: Color(0xFFF4F5F7),
    darkAnchor: Color(0xFF101010),
    primaryColor: Color(0xFF2563EB), // Blue 600
    shape: ShapePreset.rounded,
    density: DensityPreset.comfortable,
    isBuiltIn: true,
  );

  /// Emerald Enterprise: Sharp edges, pure compact density, and emerald accent for data tools.
  static const emerald = ThemePreset(
    id: 'emerald_enterprise',
    name: 'Emerald Enterprise',
    description: 'High-density sharp layout with emerald brand accent',
    lightAnchor: Color(0xFFF0FDF4),
    darkAnchor: Color(0xFF061A14),
    primaryColor: Color(0xFF059669), // Emerald 600
    shape: ShapePreset.sharp,
    density: DensityPreset.compact,
    isBuiltIn: true,
  );

  /// Nordic Cyan: Arctic cool tones with vibrant cyan highlights.
  static const nordic = ThemePreset(
    id: 'nordic_cyan',
    name: 'Nordic Cyan',
    description: 'Crisp Arctic atmosphere with vibrant cyan accents',
    lightAnchor: Color(0xFFF0F9FF),
    darkAnchor: Color(0xFF081826),
    primaryColor: Color(0xFF0284C7), // Sky 600
    shape: ShapePreset.rounded,
    density: DensityPreset.comfortable,
    isBuiltIn: true,
  );

  /// Warm Amber: Cozy warm amber tint with comfortable rounded surfaces.
  static const amber = ThemePreset(
    id: 'warm_amber',
    name: 'Warm Amber',
    description: 'Cozy cream & stone atmosphere with sunny amber accents',
    lightAnchor: Color(0xFFFFFBEB),
    darkAnchor: Color(0xFF1C1917),
    primaryColor: Color(0xFFD97706), // Amber 600
    shape: ShapePreset.rounded,
    density: DensityPreset.comfortable,
    isBuiltIn: true,
  );

  /// Neo Trading: Specialized trading interface with high contrast and compact metrics.
  static const trading = ThemePreset(
    id: 'neo_trading',
    name: 'Neo Trading',
    description: 'Specialized trading interface with high contrast and compact metrics.',
    lightAnchor: Color(0xFFF4F5F7),
    darkAnchor: Color(0xFF101010),
    primaryColor: Color(0xFF1D65AB),
    errorColor: Color(0xFFDC2626),
    warningColor: Color(0xFFD97706),
    infoColor: Color(0xFF417BD2),
    shape: ShapePreset.rounded,
    density: DensityPreset.compact,
    fontFamily: 'Inter',
    baseFontSize: 13,
    baseRadius: 4,
    baseSpacing: 8,
    isBuiltIn: true,
  );

  /// Alias for [trading].
  static const neoTrading = trading;

  /// All built-in presets list.
  static const List<ThemePreset> all = [
    slate,
    emerald,
    nordic,
    amber,
    trading,
  ];
}


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_design_system/neo_design_system.dart';

void main() {
  group('OKLCH Math & Conversion Tests', () {
    test('Pure white and black mapping', () {
      const black = OklchColor(0.0, 0.0, 0.0);
      final blackColor = black.toColor();
      expect((blackColor.r * 255).round(), 0);
      expect((blackColor.g * 255).round(), 0);
      expect((blackColor.b * 255).round(), 0);

      const white = OklchColor(1.0, 0.0, 0.0);
      final whiteColor = white.toColor();
      expect((whiteColor.r * 255).round(), 255);
      expect((whiteColor.g * 255).round(), 255);
      expect((whiteColor.b * 255).round(), 255);
    });

    test('Chroma & Hue produces valid color boundaries', () {
      const cyan = OklchColor(0.7, 0.12, 200.0);
      final col = cyan.toColor();
      expect((col.a * 255).round(), 255);
      expect(cyan.hexCode.startsWith('#'), isTrue);
      expect(cyan.hexCode.length, 7);
    });

    test('fromColor converts Red and Yellow accurately', () {
      const red = Color(0xFFEF4444);
      final oklchRed = OklchColor.fromColor(red);
      expect(oklchRed.h, inInclusiveRange(10.0, 45.0));
      expect(oklchRed.c, greaterThan(0.05));

      const yellow = Color(0xFFEAB308);
      final oklchYellow = OklchColor.fromColor(yellow);
      expect(oklchYellow.h, inInclusiveRange(70.0, 115.0));
      expect(oklchYellow.c, greaterThan(0.05));

      const lightAnchor = Color(0xFFF4F5F7);
      final oklchLight = OklchColor.fromColor(lightAnchor);
      expect(oklchLight.l, closeTo(0.970, 0.005));
      expect(oklchLight.toColor(), lightAnchor);

      const darkAnchor = Color(0xFF101010);
      final oklchDark = OklchColor.fromColor(darkAnchor);
      expect(oklchDark.l, closeTo(0.173, 0.005));
      expect(oklchDark.toColor(), darkAnchor);
    });
  });

  group('LayerPalette Architecture Tests', () {
    test('Light mode relative derivations from anchorL', () {
      const anchorL = 0.92;
      const c = 0.05;
      const h = 250.0;

      final palette = LayerPalette.fromAnchor(
        anchorL: anchorL,
        c: c,
        h: h,
        isDark: false,
      );

      final specC1 = palette.specs.firstWhere((s) => s.id == 'C1');
      final specC2 = palette.specs.firstWhere((s) => s.id == 'C2');
      final specC3 = palette.specs.firstWhere((s) => s.id == 'C3');
      final specTf = palette.specs.firstWhere((s) => s.id == 'TF');
      final specTfb = palette.specs.firstWhere((s) => s.id == 'TFB');
      final specTfd = palette.specs.firstWhere((s) => s.id == 'TFD');
      final specDiv = palette.specs.firstWhere((s) => s.id == 'DIV');
      final specC4 = palette.specs.firstWhere((s) => s.id == 'C4');
      final specTbf = palette.specs.firstWhere((s) => s.id == 'TBF');
      final specTbt = palette.specs.firstWhere((s) => s.id == 'TBT');

      // C1: anchorL + (0.018 * 2.0) = 0.956, chroma: c * 0.70
      expect(specC1.l, closeTo(0.92 + 0.036, 0.001));
      expect(specC1.c, closeTo(0.05 * 0.70, 0.001));

      // C2: anchorL + 0.018 = 0.938 (lebih dekat & harmonis dengan C3), chroma: c * 0.90
      expect(specC2.l, closeTo(0.92 + 0.018, 0.001));
      expect(specC2.c, closeTo(0.05 * 0.90, 0.001));

      // C3 (Anchor): anchorL, chroma: c
      expect(specC3.l, closeTo(0.92, 0.001));
      expect(specC3.c, closeTo(0.05, 0.001));

      // TF: anchorL - 0.030, chroma: c * 1.2
      expect(specTf.l, closeTo(0.92 - 0.030, 0.001));
      expect(specTf.c, closeTo(0.05 * 1.2, 0.001));

      // 1. Divider Line (Light): anchorL - 0.05, chroma: c * 0.5
      expect(specDiv.l, closeTo(0.92 - 0.05, 0.001));
      expect(specDiv.c, closeTo(0.05 * 0.5, 0.001));

      // 2. Border TextField (Light): anchorL - 0.10, chroma: 0.02
      expect(specTfb.l, closeTo(0.92 - 0.10, 0.001));
      expect(specTfb.c, closeTo(0.02, 0.001));

      // 3. Disabled TF Fill (Light): sama persis dengan C3
      expect(specTfd.l, closeTo(0.92, 0.001));
      expect(palette.textFieldDisabledFill, palette.container3);

      // 4. Disabled Border: textMain alpha 0.08
      expect((palette.textFieldDisabledBorder.a * 255).round(), closeTo(255 * 0.08, 2));

      // 5. Disabled Text/Icon: textMain alpha 0.38
      expect((palette.textDisabled.a * 255).round(), closeTo(255 * 0.38, 2));

      // C4 (Dialog & Menu Surface): anchorL + 0.010, chroma: c * 0.85
      expect(specC4.l, closeTo(0.92 + 0.010, 0.001));
      expect(specC4.c, closeTo(0.05 * 0.85, 0.001));

      // Tonal Button Fill (Light): anchorL - 0.055
      expect(specTbf.l, closeTo(0.92 - 0.055, 0.001));
      expect(palette.tonalButtonFill, isNotNull);

      // Tonal Button Text (Light): textMain (L = 0.20)
      expect(specTbt.l, closeTo(0.20, 0.001));
      expect(palette.tonalButtonText, palette.textMain);

      // Primary & onPrimary (Light)
      expect(palette.primary, isNotNull);
      expect(palette.onPrimary, isNotNull);
      expect(palette.specs.any((s) => s.id == 'PRI'), isTrue);

      // Status Tokens (Light)
      expect(palette.success, isNotNull);
      expect(palette.onSuccess, isNotNull);
      expect(palette.warning, isNotNull);
      expect(palette.onWarning, isNotNull);
      expect(palette.error, isNotNull);
      expect(palette.onError, isNotNull);
      expect(palette.info, isNotNull);
      expect(palette.onInfo, isNotNull);
      expect(palette.specs.any((s) => s.id == 'SUC'), isTrue);
      expect(palette.specs.any((s) => s.id == 'WAR'), isTrue);
      expect(palette.specs.any((s) => s.id == 'ERR'), isTrue);
      expect(palette.specs.any((s) => s.id == 'INF'), isTrue);
    });

    test('Dark mode relative derivations from anchorL', () {
      const anchorL = 0.26;
      const c = 0.05;
      const h = 250.0;

      final palette = LayerPalette.fromAnchor(
        anchorL: anchorL,
        c: c,
        h: h,
        isDark: true,
      );

      final specC1 = palette.specs.firstWhere((s) => s.id == 'C1');
      final specC2 = palette.specs.firstWhere((s) => s.id == 'C2');
      final specC3 = palette.specs.firstWhere((s) => s.id == 'C3');
      final specTf = palette.specs.firstWhere((s) => s.id == 'TF');
      final specTfb = palette.specs.firstWhere((s) => s.id == 'TFB');
      final specTfd = palette.specs.firstWhere((s) => s.id == 'TFD');
      final specDiv = palette.specs.firstWhere((s) => s.id == 'DIV');
      final specC4 = palette.specs.firstWhere((s) => s.id == 'C4');
      final specTbf = palette.specs.firstWhere((s) => s.id == 'TBF');
      final specTbt = palette.specs.firstWhere((s) => s.id == 'TBT');

      // C1: anchorL - (0.022 * 2.5) = 0.205 (paling gelap), chroma: c * 0.82
      expect(specC1.l, closeTo(0.26 - 0.055, 0.001));
      expect(specC1.c, closeTo(0.05 * 0.82, 0.001));

      // C2: anchorL - 0.022 = 0.238 (dekat & harmonis dengan C3), chroma: c * 0.94
      expect(specC2.l, closeTo(0.26 - 0.022, 0.001));
      expect(specC2.c, closeTo(0.05 * 0.94, 0.001));

      // C3 (Anchor): anchorL, chroma: c
      expect(specC3.l, closeTo(0.26, 0.001));
      expect(specC3.c, closeTo(0.05, 0.001));

      // TF: anchorL - 0.018 (soft trough seimbang di atas C2), chroma: c * 0.88
      expect(specTf.l, closeTo(0.26 - 0.018, 0.001));
      expect(specTf.c, closeTo(0.05 * 0.88, 0.001));

      // 1. Divider Line (Dark): anchorL + 0.05, chroma: c * 0.5
      expect(specDiv.l, closeTo(0.26 + 0.05, 0.001));
      expect(specDiv.c, closeTo(0.05 * 0.5, 0.001));

      // 2. Border TextField (Dark): anchorL + 0.08, chroma: 0.02
      expect(specTfb.l, closeTo(0.26 + 0.08, 0.001));
      expect(specTfb.c, closeTo(0.02, 0.001));

      // 3. Disabled TF Fill (Dark): sama persis dengan C3
      expect(specTfd.l, closeTo(0.26, 0.001));
      expect(palette.textFieldDisabledFill, palette.container3);

      // 4. Disabled Border: textMain alpha 0.08
      expect((palette.textFieldDisabledBorder.a * 255).round(), closeTo(255 * 0.08, 2));

      // 5. Disabled Text/Icon: textMain alpha 0.38
      expect((palette.textDisabled.a * 255).round(), closeTo(255 * 0.38, 2));

      // C4 (Dialog & Menu Surface): anchorL + 0.07, chroma: c * 1.0
      expect(specC4.l, closeTo(0.33, 0.001));
      expect(specC4.c, closeTo(0.05 * 1.0, 0.001));

      // Tonal Button Fill (Dark): C4 + 0.065 = 0.33 + 0.065 = 0.395
      expect(specTbf.l, closeTo(0.33 + 0.065, 0.001));
      expect(palette.tonalButtonFill, isNotNull);

      // Tonal Button Text (Dark): textMain (L = 0.93)
      expect(specTbt.l, closeTo(0.93, 0.001));
      expect(palette.tonalButtonText, palette.textMain);

      // Primary & onPrimary (Dark)
      expect(palette.primary, isNotNull);
      expect(palette.onPrimary, isNotNull);
      expect(palette.specs.any((s) => s.id == 'PRI'), isTrue);

      // Status Tokens (Dark)
      expect(palette.success, isNotNull);
      expect(palette.onSuccess, isNotNull);
      expect(palette.warning, isNotNull);
      expect(palette.onWarning, isNotNull);
      expect(palette.error, isNotNull);
      expect(palette.onError, isNotNull);
      expect(palette.info, isNotNull);
      expect(palette.onInfo, isNotNull);
      expect(palette.specs.any((s) => s.id == 'SUC'), isTrue);
      expect(palette.specs.any((s) => s.id == 'WAR'), isTrue);
      expect(palette.specs.any((s) => s.id == 'ERR'), isTrue);
      expect(palette.specs.any((s) => s.id == 'INF'), isTrue);
    });

    test('copyWith and lerp operations with new tokens', () {
      final light = LayerPalette.fromAnchor(anchorL: 0.92, c: 0.05, h: 250, isDark: false);
      final dark = LayerPalette.fromAnchor(anchorL: 0.26, c: 0.05, h: 250, isDark: true);

      final cloned = light.copyWith(
        anchorL: 0.90,
        success: const Color(0xFF00FF00),
      );
      expect(cloned.anchorL, 0.90);
      expect(cloned.dividerLine, light.dividerLine);
      expect(cloned.textFieldBorder, light.textFieldBorder);
      expect(cloned.tonalButtonFill, light.tonalButtonFill);
      expect(cloned.tonalButtonText, light.tonalButtonText);
      expect(cloned.primary, light.primary);
      expect(cloned.onPrimary, light.onPrimary);
      expect(cloned.success, const Color(0xFF00FF00));
      expect(cloned.warning, light.warning);
      expect(cloned.error, light.error);
      expect(cloned.info, light.info);

      final blended = light.lerp(dark, 0.5);
      expect(blended.anchorL, closeTo((0.92 + 0.26) / 2, 0.001));
      expect(blended.dividerLine, isNotNull);
      expect(blended.textFieldBorder, isNotNull);
      expect(blended.tonalButtonFill, isNotNull);
      expect(blended.tonalButtonText, isNotNull);
      expect(blended.primary, isNotNull);
      expect(blended.onPrimary, isNotNull);
      expect(blended.success, isNotNull);
      expect(blended.warning, isNotNull);
      expect(blended.error, isNotNull);
      expect(blended.info, isNotNull);
    });

    test('toThemeData overrides Flutter ThemeData accurately for Light and Dark modes', () {
      final light = LayerPalette.fromAnchor(anchorL: 0.970, c: 0.003, h: 264.5, isDark: false);
      final lightTheme = light.toThemeData();

      expect(lightTheme.scaffoldBackgroundColor, light.container1);
      expect(lightTheme.cardTheme.color, light.container3);
      expect(lightTheme.dialogTheme.backgroundColor, light.container4);
      expect(lightTheme.dividerTheme.color, light.dividerLine);
      expect(lightTheme.colorScheme.primary, light.primary);
      expect(lightTheme.colorScheme.onPrimary, light.onPrimary);
      expect(lightTheme.colorScheme.error, light.error);
      expect(lightTheme.colorScheme.onError, light.onError);
      expect(lightTheme.inputDecorationTheme.fillColor, light.textFieldFill);
      expect(lightTheme.inputDecorationTheme.enabledBorder?.borderSide.color, light.textFieldBorder);
      expect(lightTheme.inputDecorationTheme.focusedBorder?.borderSide.color, light.primary);
      expect(lightTheme.inputDecorationTheme.disabledBorder?.borderSide.color, light.textFieldDisabledBorder);
      expect(lightTheme.inputDecorationTheme.errorBorder?.borderSide.color, light.error);
      expect(lightTheme.inputDecorationTheme.focusedErrorBorder?.borderSide.color, light.error);
      expect(lightTheme.inputDecorationTheme.errorStyle?.color, light.error);
      expect(lightTheme.extension<LayerPalette>(), light);

      final dark = LayerPalette.fromAnchor(anchorL: 0.173, c: 0.0, h: 0.0, isDark: true);
      final darkTheme = dark.toThemeData();

      expect(darkTheme.scaffoldBackgroundColor, dark.container1);
      expect(darkTheme.cardTheme.color, dark.container3);
      expect(darkTheme.dialogTheme.backgroundColor, dark.container4);
      expect(darkTheme.dividerTheme.color, dark.dividerLine);
      expect(darkTheme.colorScheme.primary, dark.primary);
      expect(darkTheme.colorScheme.onPrimary, dark.onPrimary);
      expect(darkTheme.colorScheme.error, dark.error);
      expect(darkTheme.colorScheme.onError, dark.onError);
      expect(darkTheme.inputDecorationTheme.fillColor, dark.textFieldFill);
      expect(darkTheme.inputDecorationTheme.enabledBorder?.borderSide.color, dark.textFieldBorder);
      expect(darkTheme.inputDecorationTheme.focusedBorder?.borderSide.color, dark.primary);
      expect(darkTheme.inputDecorationTheme.disabledBorder?.borderSide.color, dark.textFieldDisabledBorder);
      expect(darkTheme.inputDecorationTheme.errorBorder?.borderSide.color, dark.error);
      expect(darkTheme.inputDecorationTheme.focusedErrorBorder?.borderSide.color, dark.error);
      expect(darkTheme.inputDecorationTheme.errorStyle?.color, dark.error);
      expect(darkTheme.extension<LayerPalette>(), dark);
    });
  });

  group('AppRadiusTheme Tests', () {
    test('Rounded preset directional properties and concentric nesting', () {
      final radius = AppRadiusTheme.rounded();
      expect(radius.xs.all, BorderRadius.circular(4));
      expect(radius.sm.all, BorderRadius.circular(8));
      expect(radius.md.all, BorderRadius.circular(12));
      expect(radius.lg.all, BorderRadius.circular(16));
      expect(radius.xl.all, BorderRadius.circular(24));
      expect(radius.full.all, BorderRadius.circular(9999));

      // Directional
      expect(radius.md.top, const BorderRadius.vertical(top: Radius.circular(12)));
      expect(radius.md.bottom, const BorderRadius.vertical(bottom: Radius.circular(12)));
      expect(radius.md.left, const BorderRadius.horizontal(left: Radius.circular(12)));
      expect(radius.md.right, const BorderRadius.horizontal(right: Radius.circular(12)));

      // Concentric nesting: R_inner = max(0, R_outer - padding)
      expect(radius.nested(outer: radius.xl, padding: 8).value, 16.0);
    });

    test('Sharp preset zero curvature', () {
      final sharp = AppRadiusTheme.sharp();
      expect(sharp.xs.value, 0.0);
      expect(sharp.sm.value, 0.0);
      expect(sharp.md.value, 0.0);
      expect(sharp.lg.value, 0.0);
      expect(sharp.xl.value, 0.0);
      expect(sharp.full.value, 0.0);
    });
  });

  group('AppSpacingTheme Tests', () {
    test('Comfortable density insets, gaps, and SizedBox helpers', () {
      final spacing = AppSpacingTheme.comfortable();
      expect(spacing.insetSm, const EdgeInsets.all(8));
      expect(spacing.insetMd, const EdgeInsets.all(16));
      expect(spacing.insetLg, const EdgeInsets.all(24));
      expect(spacing.vGapSm.height, 12.0);
      expect(spacing.hGapMd.width, 16.0);
      expect(spacing.touchTargetMin, 48.0);
    });

    test('Compact density pure dense without touch target limits', () {
      final compact = AppSpacingTheme.compact();
      expect(compact.insetSm, const EdgeInsets.all(4));
      expect(compact.insetMd, const EdgeInsets.all(10));
      expect(compact.vGapSm.height, 6.0);
      expect(compact.touchTargetMin, 0.0); // Pure dense!
    });
  });

  group('SingleFontFeaturesX Typography Tests', () {
    test('OpenType tabular and slashed zero chaining', () {
      const style = TextStyle(fontSize: 14);
      final tabularStyle = style.tabular;
      expect(tabularStyle?.fontFeatures, contains(const FontFeature.tabularFigures()));

      final slashedStyle = style.slashZero;
      expect(slashedStyle?.fontFeatures, contains(const FontFeature.slashedZero()));

      final combinedStyle = style.tabular.slashZero;
      expect(combinedStyle?.fontFeatures, contains(const FontFeature.tabularFigures()));
      expect(combinedStyle?.fontFeatures, contains(const FontFeature.slashedZero()));
    });
  });

  group('ThemePreset and AppThemeController Tests', () {
    test('Built-in presets exist and generate valid ThemeData', () {
      expect(BuiltInPresets.all.length, greaterThanOrEqualTo(4));
      final slate = BuiltInPresets.slate;
      final theme = slate.toThemeData(isDark: false);
      expect(theme.scaffoldBackgroundColor, isNotNull);
      expect(theme.extension<AppColorTheme>(), isNotNull);
      expect(theme.extension<AppRadiusTheme>(), isNotNull);
      expect(theme.extension<AppSpacingTheme>(), isNotNull);
    });

    test('ThemeModifier allows modifying ThemeData using all tokens', () {
      final customPreset = ThemePreset(
        id: 'test_custom',
        name: 'Custom With Modifier',
        lightAnchor: const Color(0xFFF4F5F7),
        darkAnchor: const Color(0xFF101010),
        primaryColor: const Color(0xFF3B82F6),
        themeModifier: (baseTheme, tokens) {
          // Verify tokens provides direct access to all active token instances
          expect(tokens.color, isNotNull);
          expect(tokens.radius, isNotNull);
          expect(tokens.spacing, isNotNull);
          expect(tokens.typography, isNotNull);
          return baseTheme.copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: tokens.color.container2,
              elevation: 0,
            ),
          );
        },
      );

      final theme = customPreset.toThemeData(isDark: false);
      expect(theme.appBarTheme.elevation, 0);
    });

    test('ThemeConfig JSON serialization and deserialization', () {
      final originalConfig = ThemeConfig(
        id: 'emerald',
        name: 'Emerald City',
        lightAnchorHex: '#F0FDF4',
        darkAnchorHex: '#052E16',
        primaryHex: '#10B981',
        shape: 'rounded',
        density: 'comfortable',
      );

      final jsonMap = originalConfig.toJson();
      final restoredConfig = ThemeConfig.fromJson(jsonMap);

      expect(restoredConfig.id, originalConfig.id);
      expect(restoredConfig.name, originalConfig.name);
      expect(restoredConfig.lightAnchorHex, originalConfig.lightAnchorHex);
      expect(restoredConfig.darkAnchorHex, originalConfig.darkAnchorHex);
      expect(restoredConfig.primaryHex, originalConfig.primaryHex);
      expect(restoredConfig.shape, 'rounded');
      expect(restoredConfig.density, 'comfortable');

      final preset = restoredConfig.toPreset();
      expect(preset.name, 'Emerald City');
      expect(preset.primaryColor, const Color(0xFF10B981));
    });

    test('AppThemeController state switching and custom preset adding', () {
      final controller = AppThemeController();
      expect(controller.currentPreset.id, BuiltInPresets.slate.id);
      expect(controller.density, DensityPreset.comfortable);
      expect(controller.shape, ShapePreset.rounded);

      controller.setPreset(BuiltInPresets.emerald);
      expect(controller.currentPreset.id, BuiltInPresets.emerald.id);

      controller.setDensity(DensityPreset.compact);
      expect(controller.density, DensityPreset.compact);

      controller.setShape(ShapePreset.sharp);
      expect(controller.shape, ShapePreset.sharp);

      // Export to JSON string
      final jsonStr = controller.exportCurrentPresetAsJson();
      expect(jsonStr, contains('"id": "emerald_enterprise"'));
      expect(jsonStr, contains('"density": "compact"'));
      expect(jsonStr, contains('"shape": "sharp"'));

      // Import from JSON string
      final imported = controller.importPresetFromJson(jsonStr);
      expect(imported.id, BuiltInPresets.emerald.id);
    });

    test('AppTypography scales dynamically and proportionally from baseFontSize', () {
      // 1. Standard base 14
      final typo14 = AppTypography.create(baseFontSize: 14.0, isCompact: false);
      expect(typo14.titleLg.fontSize, 20.0);
      expect(typo14.titleMd.fontSize, 16.0);
      expect(typo14.titleSm.fontSize, 14.0);
      expect(typo14.bodyLg.fontSize, 16.0);
      expect(typo14.bodyMd.fontSize, 14.0);
      expect(typo14.bodySm.fontSize, 13.0);
      expect(typo14.labelMd.fontSize, 13.0);
      expect(typo14.labelSm.fontSize, 11.0);

      // 2. Scaled up base 16 (Accessibility / Large mode)
      final typo16 = AppTypography.create(baseFontSize: 16.0, isCompact: false);
      expect(typo16.titleSm.fontSize, 16.0); // 16 * 1.0 = 16
      expect(typo16.titleLg.fontSize, closeTo(16.0 * (20 / 14), 0.5)); // ~23.0
      expect(typo16.titleLg.fontSize! > typo14.titleLg.fontSize!, isTrue);
      expect(typo16.bodyMd.fontSize! > typo14.bodyMd.fontSize!, isTrue);

      // 3. Compact mode with base 14 (effective base = 13.0)
      final typoCompact = AppTypography.create(baseFontSize: 14.0, isCompact: true);
      expect(typoCompact.titleSm.fontSize, 13.0);
      expect(typoCompact.titleLg.fontSize, closeTo(13.0 * (20 / 14), 0.5)); // ~18.5
      expect(typoCompact.titleLg.fontSize! < typo14.titleLg.fontSize!, isTrue);

      // 4. Verification in ThemePreset integration
      final presetCustomSize = BuiltInPresets.slate.copyWith(baseFontSize: 18.0);
      final themeData = presetCustomSize.toThemeData(isDark: false);
      expect(themeData.textTheme.titleSmall?.fontSize, 18.0);
    });

    test('AppTypography clamps minFontWeight and supports on-the-fly switching', () {
      // 1. Default without clamp: body is w400, label is w500, title is w600
      final defaultTypo = AppTypography.create();
      expect(defaultTypo.bodyMd.fontWeight, FontWeight.w400);
      expect(defaultTypo.labelMd.fontWeight, FontWeight.w500);
      expect(defaultTypo.titleLg.fontWeight, FontWeight.w600);

      // 2. Clamped with w600: body and label elevated to w600; title remains w600
      final clampedTypo = AppTypography.create(minFontWeight: FontWeight.w600);
      expect(clampedTypo.bodyMd.fontWeight, FontWeight.w600);
      expect(clampedTypo.bodySm.fontWeight, FontWeight.w600);
      expect(clampedTypo.labelMd.fontWeight, FontWeight.w600);
      expect(clampedTypo.titleLg.fontWeight, FontWeight.w600);

      // 3. Clamping via withMinWeight method
      final dynamicClamped = defaultTypo.withMinWeight(FontWeight.w600);
      expect(dynamicClamped.bodyMd.fontWeight, FontWeight.w600);
      expect(dynamicClamped.titleLg.fontWeight, FontWeight.w600);

      // 4. On-the-fly switching via AppThemeController
      final controller = AppThemeController();
      expect(controller.currentPreset.minFontWeight, isNull);

      // Elevate on-the-fly
      controller.setMinFontWeight(FontWeight.w600);
      expect(controller.currentPreset.minFontWeight, FontWeight.w600);
      final themeClamped = controller.currentPreset.toThemeData(isDark: false);
      expect(themeClamped.textTheme.bodyMedium?.fontWeight, FontWeight.w600);
      expect(themeClamped.textTheme.titleSmall?.fontWeight, FontWeight.w600);

      // Reset on-the-fly
      controller.setMinFontWeight(null);
      expect(controller.currentPreset.minFontWeight, isNull);
      final themeReset = controller.currentPreset.toThemeData(isDark: false);
      expect(themeReset.textTheme.bodyMedium?.fontWeight, FontWeight.w400);
    });

    test('AppRadiusTheme and AppSpacingTheme scale dynamically from base anchors on-the-fly', () {
      // 1. Radius scaling
      final customRadius = AppRadiusTheme.create(baseRadius: 18.0);
      expect(customRadius.md.value, 18.0);
      expect(customRadius.xs.value, 6.0); // 18 * (4/12)
      expect(customRadius.lg.value, 24.0); // 18 * (16/12)

      // Sharp radius
      final sharpRadius = AppRadiusTheme.create(baseRadius: 0.0);
      expect(sharpRadius.md.value, 0.0);
      expect(sharpRadius.lg.value, 0.0);

      // 2. Spacing scaling
      final customSpacing = AppSpacingTheme.create(baseSpacing: 20.0);
      expect(customSpacing.gapMd, 20.0);
      expect(customSpacing.gapSm, 15.0); // 20 * (12/16)
      expect(customSpacing.gapLg, 30.0); // 20 * (24/16)

      // 3. Controller on-the-fly adjustments
      final controller = AppThemeController();
      controller.setBaseRounded(18.0);
      expect(controller.currentPreset.baseRadius, 18.0);
      expect(controller.shape, ShapePreset.rounded);

      final themeWithRadius = controller.currentPreset.toThemeData(isDark: false);
      final radiusExt = themeWithRadius.extension<AppRadiusTheme>();
      expect(radiusExt?.md.value, 18.0);

      controller.setBaseSpacing(24.0);
      expect(controller.currentPreset.baseSpacing, 24.0);

      final themeWithSpacing = controller.currentPreset.toThemeData(isDark: false);
      final spacingExt = themeWithSpacing.extension<AppSpacingTheme>();
      expect(spacingExt?.gapMd, 24.0);

      // 4. Test setting zero radius switches to sharp
      controller.setBaseRounded(0.0);
      expect(controller.shape, ShapePreset.sharp);
    });
  });
}

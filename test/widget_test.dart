import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_color_picker/neo_color_picker.dart';
import 'package:design_system_lite/main.dart';

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

  group('UI Showcase Widget Test', () {
    testWidgets('Renders Light (#F4F5F7) and Dark (#101010) Mode with TextFields, Dividers and Disabled Inputs', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const OklchPaletteDemoApp());
      await tester.pumpAndSettle();

      expect(find.text('LIGHT MODE'), findsOneWidget);
      expect(find.text('DARK MODE'), findsOneWidget);
      expect(find.text('Light Anchor Color'), findsOneWidget);
      expect(find.text('Dark Anchor Color'), findsOneWidget);
      expect(find.text('Primary Brand Color'), findsOneWidget);
      expect(find.text('Success Status Color'), findsOneWidget);
      expect(find.text('Warning Status Color'), findsOneWidget);
      expect(find.text('Error Status Color'), findsOneWidget);
      expect(find.text('Info Status Color'), findsOneWidget);
      expect(find.text('Pilih Warna'), findsNWidgets(7));
      expect(find.text('Container 3 (Primary Anchor)'), findsNWidgets(2));
      expect(find.text('Custom Anchor'), findsNWidgets(2));

      // Verify TextFields: 2 active search + 2 disabled + 2 error validation = 6 TextFields
      expect(find.byType(TextField), findsNWidgets(6));

      // Verify presence of Divider widgets
      expect(find.byType(Divider), findsWidgets);
      expect(find.text('DIVIDER LINE'), findsNWidgets(2));
      expect(find.text('DISABLED TEXT FIELD (FLAT SURFACE)'), findsNWidgets(2));
      expect(find.text('ERROR TEXT FIELD (VALIDATION STATE)'), findsNWidgets(2));
      expect(find.text('SEMANTIC STATUS TOKENS & BADGES'), findsNWidgets(2));

      // Verify Primary Brand Button and Tonal Button are rendered
      expect(find.text('Primary Button'), findsNWidgets(2));
      expect(find.text('Tonal Button (C4)'), findsNWidgets(2));
      expect(find.text('Disabled Button (C4)'), findsNWidgets(2));
      expect(find.text('Open Dialog Preview (C4)'), findsNWidgets(2));
      expect(find.text('Context Menu Mockup (C4)'), findsNWidgets(2));

      // Tap on Light mode Custom Anchor button to open NeoColorPicker dialog
      await tester.tap(find.text('Custom Anchor').first);
      await tester.pumpAndSettle();

      expect(find.text('Light Mode Custom Anchor'), findsOneWidget);
      final picker = tester.widget<NeoColorPicker>(find.byType(NeoColorPicker));
      expect(picker.mode, NeoColorPickerMode.hsl);
      expect(find.text('Apply'), findsOneWidget);

      // Dismiss picker dialog
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Light Mode Custom Anchor'), findsNothing);

      // Tap on Primary Brand Color card to open NeoColorPicker dialog
      await tester.tap(find.text('Primary Brand Color'));
      await tester.pumpAndSettle();

      expect(find.text('Primary Brand Color'), findsWidgets);
      expect(find.text('Apply'), findsOneWidget);

      // Dismiss primary picker dialog
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Tap on Success Status Color card to open NeoColorPicker dialog
      await tester.tap(find.text('Success Status Color'));
      await tester.pumpAndSettle();

      expect(find.text('Success Semantic Color'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);

      // Dismiss success picker dialog
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Success Semantic Color'), findsNothing);

      // Open Dialog Preview (C4)
      await tester.ensureVisible(find.text('Open Dialog Preview (C4)').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Dialog Preview (C4)').first);
      await tester.pumpAndSettle();

      expect(find.text('Dialog Surface (Container 4)'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Dismiss C4 Dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Dialog Surface (Container 4)'), findsNothing);
    });
  });
}

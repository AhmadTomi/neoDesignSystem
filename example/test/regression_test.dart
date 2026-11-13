import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_design_system_example/main.dart';
import 'package:neo_design_system_example/quantity_text_field.dart';

void main() {
  group('PlaygroundController', () {
    test('buildCurrentPreset keeps typography, radius and spacing anchors', () {
      final controller = PlaygroundController();
      addTearDown(controller.dispose);

      final preset = controller.buildCurrentPreset();
      const source = NeoTradingTheme.preset;

      expect(preset.baseRadius, source.baseRadius);
      expect(preset.baseSpacing, source.baseSpacing);
      expect(preset.fontFamily, source.fontFamily);
      expect(preset.baseFontSize, source.baseFontSize);

      final saved = controller.saveCustomPreset('Mine');
      expect(saved.baseFontSize, 13);
      expect(saved.baseRadius, 4);
      expect(saved.baseSpacing, 8);
    });

    test('mode-specific color edit does not change the shared base color', () {
      final controller = PlaygroundController();
      addTearDown(controller.dispose);
      final basePrimary = controller.primaryColor;
      final lightPrimaryBefore = controller.lightPalette.primary;

      controller.updateColor(
        const Color(0xFFFF00FF),
        target: ColorPickerTarget.primary,
        isDark: true,
      );

      expect(controller.primaryColor, basePrimary);
      expect(controller.lightPalette.primary, lightPrimaryBefore);
      expect(controller.darkPalette.primary, const Color(0xFFFF00FF));
    });

    test('shared color edit updates base and clears mode overrides', () {
      final controller = PlaygroundController();
      addTearDown(controller.dispose);

      controller.updateColor(
        const Color(0xFF00AA00),
        target: ColorPickerTarget.primary,
      );

      expect(controller.primaryColor, const Color(0xFF00AA00));
      expect(controller.buildCurrentPreset().darkPrimaryColor, isNull);
      expect(controller.buildCurrentPreset().lightPrimaryColor, isNull);
    });
  });

  group('QuantityTextField ownership', () {
    Widget host({FocusNode? focusNode, TextEditingController? controller}) {
      return MaterialApp(
        home: Material(
          child: QuantityTextField(
            focusNode: focusNode,
            controller: controller,
          ),
        ),
      );
    }

    bool isDisposed(ChangeNotifier notifier) {
      try {
        notifier.addListener(() {});
        return false;
      } on FlutterError {
        return true;
      }
    }

    testWidgets('does not dispose a caller FocusNode swapped in later',
        (tester) async {
      final external = FocusNode();
      addTearDown(external.dispose);

      await tester.pumpWidget(host());
      await tester.pumpWidget(host(focusNode: external));
      await tester.pumpWidget(const SizedBox());

      expect(isDisposed(external), isFalse);
    });

    testWidgets('does not dispose a caller controller swapped in later',
        (tester) async {
      final external = TextEditingController(text: '5');
      addTearDown(external.dispose);

      await tester.pumpWidget(host());
      await tester.pumpWidget(host(controller: external));
      await tester.pumpWidget(const SizedBox());

      expect(isDisposed(external), isFalse);
    });
  });
}

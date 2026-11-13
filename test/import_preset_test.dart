import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_design_system/neo_design_system.dart';

void main() {
  group('AppThemeController.importPresetJson keeps preset ids unique', () {
    const custom = ThemePreset(
      id: 'neo_trading',
      name: 'Neo Trading',
      lightAnchor: Color(0xFFFCFDFD),
      darkAnchor: Color(0xFF1A1A1A),
      primaryColor: Color(0xFF1D65AB),
    );

    test('re-importing an existing custom preset replaces it in place', () {
      final controller = AppThemeController(initialCustomPresets: [custom]);
      final json = controller.exportPresetJson(
        custom.copyWith(primaryColor: const Color(0xFFFF0000)),
      );

      controller.importPresetJson(json);
      controller.importPresetJson(json);

      final matches =
          controller.allPresets.where((p) => p.id == 'neo_trading').toList();
      expect(matches, hasLength(1));
      expect(matches.single.primaryColor, const Color(0xFFFF0000));
      expect(controller.currentPreset.id, 'neo_trading');
    });

    test('importing a built-in id gets a fresh custom id', () {
      final controller = AppThemeController();
      final json = controller.exportPresetJson(BuiltInPresets.slate);

      final imported = controller.importPresetJson(json);

      expect(imported.id, isNot(BuiltInPresets.slate.id));
      expect(imported.id, startsWith('custom_'));
      expect(
        controller.allPresets.where((p) => p.id == BuiltInPresets.slate.id),
        hasLength(1),
      );
      final ids = controller.allPresets.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('non-object JSON throws FormatException', () {
      final controller = AppThemeController();
      expect(
        () => controller.importPresetJson('[1, 2, 3]'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

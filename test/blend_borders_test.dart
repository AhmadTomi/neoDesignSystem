import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_design_system/neo_design_system.dart';

const _base = ThemePreset(
  id: 'base',
  name: 'Base',
  lightAnchor: Color(0xFFFCFDFD),
  darkAnchor: Color(0xFF1A1A1A),
  primaryColor: Color(0xFF1D65AB),
);

void main() {
  group('blendBorders', () {
    test('off by default: borders stay visible', () {
      final c = _base.toThemeData(isDark: true).extension<AppColorTheme>()!;
      expect(c.blendBorders, isFalse);
      expect(c.textFieldBorder, isNot(c.textFieldFill));
      expect(c.subtleBorder.a, greaterThan(0));
      expect(c.containerBorder.a, greaterThan(0));
      expect(c.accentBorder(const Color(0xFF00FF00)), const Color(0xFF00FF00));
    });

    for (final isDark in [true, false]) {
      test('on (${isDark ? 'dark' : 'light'}): borders blend into their surfaces', () {
        final theme = _base.copyWith(blendBorders: true).toThemeData(isDark: isDark);
        final c = theme.extension<AppColorTheme>()!;

        expect(c.blendBorders, isTrue);
        expect(c.textFieldBorder.a, 0);
        expect(c.textFieldDisabledBorder.a, 0);
        expect(c.containerBorder.a, 0);
        expect(c.subtleBorder.a, 0);
        // A borderless field is only its fill: it must differ from panels.
        expect(c.textFieldFill, isNot(c.container2));
        expect(c.textFieldFill, isNot(c.container3));
        // Recessed: darker than the panels it sits on.
        expect(
          c.textFieldFill.computeLuminance(),
          lessThan(c.container2.computeLuminance()),
        );
        if (isDark) {
          // Gentle: between the deepest surface and container2, never black.
          expect(
            c.textFieldFill.computeLuminance(),
            greaterThan(c.container1.computeLuminance()),
          );
        }
        expect(c.accentBorder(const Color(0xFF00FF00)).a, 0);
        // Dividers are not borders and stay visible.
        expect(c.dividerLine.a, greaterThan(0));

        final input = theme.inputDecorationTheme;
        expect((input.enabledBorder as OutlineInputBorder).borderSide.color.a, 0);
        // Focus and error borders stay visible for keyboard users.
        expect((input.focusedBorder as OutlineInputBorder).borderSide.color, c.primary);
        expect((input.errorBorder as OutlineInputBorder).borderSide.color, c.error);
      });
    }

    test('high contrast always shows borders', () {
      final preset = _base.copyWith(blendBorders: true);
      final c = preset
          .toThemeData(isDark: true, highContrast: true)
          .extension<AppColorTheme>()!;
      expect(c.blendBorders, isFalse);
      expect(c.textFieldBorder, isNot(c.textFieldFill));
      expect(c.subtleBorder.a, greaterThan(0));
    });

    test('survives JSON round trip and can be toggled on the fly', () {
      final controller = AppThemeController(initialPreset: _base.copyWith(blendBorders: true));
      final json = controller.exportPresetJson();
      expect(jsonDecode(json)['blendBorders'], isTrue);
      expect(controller.importPresetJson(json).blendBorders, isTrue);

      controller.setBlendBorders(false);
      expect(controller.currentPreset.blendBorders, isFalse);
    });
  });
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_design_system/neo_design_system.dart';

const _base = ThemePreset(
  id: 'base',
  name: 'Base',
  lightAnchor: Color(0xFFFCFDFD),
  darkAnchor: Color(0xFF000000),
  primaryColor: Color(0xFF1D65AB),
);

AppColorTheme _colors(ThemePreset p, {required bool isDark}) =>
    p.toThemeData(isDark: isDark).extension<AppColorTheme>()!;

void main() {
  group('field border overrides', () {
    test('default field border is derived (not the override)', () {
      final c = _colors(_base, isDark: true);
      expect(c.textFieldBorder, isNot(const Color(0xFF2C2C2C)));
    });

    test('dark/light overrides apply per mode; shared one is the fallback', () {
      final p = _base.copyWith(
        fieldBorderColor: const Color(0xFF777777),
        darkFieldBorderColor: const Color(0xFF2C2C2C),
      );
      expect(_colors(p, isDark: true).textFieldBorder, const Color(0xFF2C2C2C));
      expect(_colors(p, isDark: false).textFieldBorder, const Color(0xFF777777));
    });

    test('input decoration borders use the override', () {
      final p = _base.copyWith(darkFieldBorderColor: const Color(0xFF2C2C2C));
      final input = p.toThemeData(isDark: true).inputDecorationTheme;
      expect(
        (input.enabledBorder as OutlineInputBorder).borderSide.color,
        const Color(0xFF2C2C2C),
      );
    });

    test('blendBorders still hides an overridden field border', () {
      final p = _base.copyWith(
        darkFieldBorderColor: const Color(0xFF2C2C2C),
        blendBorders: true,
      );
      expect(_colors(p, isDark: true).textFieldBorder.a, 0);
    });

    test('overrides survive JSON round trip and can be cleared', () {
      final p = _base.copyWith(
        fieldBorderColor: const Color(0xFF777777),
        darkFieldBorderColor: const Color(0xFF2C2C2C),
        lightFieldBorderColor: const Color(0xFFC4C4C4),
      );
      final controller = AppThemeController(initialPreset: p);
      final json = jsonDecode(controller.exportPresetJson()) as Map<String, dynamic>;
      expect(json['darkFieldBorderHex'], isNotNull);
      final restored = ThemeConfig.fromJson(json).toPreset();
      expect(restored.fieldBorderColor, const Color(0xFF777777));
      expect(restored.darkFieldBorderColor, const Color(0xFF2C2C2C));
      expect(restored.lightFieldBorderColor, const Color(0xFFC4C4C4));

      final cleared = restored.copyWith(clearDarkFieldBorderColor: true);
      expect(cleared.darkFieldBorderColor, isNull);
      expect(cleared.fieldBorderColor, const Color(0xFF777777));
    });
  });
}

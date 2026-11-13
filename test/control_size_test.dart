import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  group('AppControlSizeTheme', () {
    test('density defaults: compact md 30, comfortable md 38', () {
      final compact = AppControlSizeTheme.create(density: DensityPreset.compact);
      expect([compact.xs, compact.sm, compact.md, compact.lg], [20, 24, 30, 36]);

      final comfortable = AppControlSizeTheme.create();
      expect([comfortable.xs, comfortable.sm, comfortable.md, comfortable.lg], [25, 30, 38, 46]);
    });

    test('baseControlHeight scales all steps proportionally to whole pixels', () {
      final t = AppControlSizeTheme.create(baseControlHeight: 32);
      expect([t.xs, t.sm, t.md, t.lg], [21, 26, 32, 38]);
      expect(t.iconSize, 16);
    });

    test('preset exposes the extension and drives field and button heights', () {
      final preset = _base.copyWith(density: DensityPreset.compact, baseControlHeight: 32);
      final theme = preset.toThemeData(isDark: true);

      expect(theme.extension<AppControlSizeTheme>()?.md, 32);
      expect(theme.inputDecorationTheme.constraints, const BoxConstraints(minHeight: 32));
      expect(
        theme.elevatedButtonTheme.style?.minimumSize?.resolve({}),
        const Size(0, 32),
      );
      expect(
        theme.outlinedButtonTheme.style?.minimumSize?.resolve({}),
        const Size(0, 32),
      );
    });

    test('field padding makes content fill controlSize.md (border is drawn around content)', () {
      for (final h in [26.0, 30.0, 32.0, 38.0]) {
        final theme = _base
            .copyWith(density: DensityPreset.compact, baseControlHeight: h)
            .toThemeData(isDark: false);
        final pad = theme.inputDecorationTheme.contentPadding!.resolve(TextDirection.ltr);
        final body = theme.textTheme.bodyLarge!;
        final content = body.fontSize! * (body.height ?? 1.2) + pad.vertical;
        expect((content - h).abs(), lessThanOrEqualTo(1.0), reason: 'height $h');
      }
    });

    test('fieldVerticalPadding snaps to 0.5 and respects minPadding', () {
      const t = AppControlSizeTheme(md: 32);
      expect(t.fieldVerticalPadding(16.2), 8.0);
      expect(t.fieldVerticalPadding(40), 2.0);
    });

    test('baseControlHeight survives JSON round trip', () {
      final controller = AppThemeController(initialPreset: _base.copyWith(baseControlHeight: 28));
      final json = controller.exportPresetJson();
      expect(jsonDecode(json)['baseControlHeight'], 28);

      final imported = controller.importPresetJson(json);
      expect(imported.baseControlHeight, 28);
    });

    test('setBaseControlHeight updates the preset on the fly', () {
      final controller = AppThemeController(initialPreset: _base);
      controller.setBaseControlHeight(34);
      expect(controller.currentPreset.baseControlHeight, 34);
    });

    testWidgets('on desktop a plain field and a button paint exactly controlSize.md', (tester) async {
      // Desktop platforms default to VisualDensity.compact, which shrinks fields by 8px.
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final theme = _base
          .copyWith(density: DensityPreset.compact, baseControlHeight: 32)
          .toThemeData(isDark: true);
      // Drop minHeight so the measured size is the painted (content) height.
      final unconstrained = theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(constraints: const BoxConstraints()),
      );
      await tester.pumpWidget(MaterialApp(
        theme: unconstrained,
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: TextEditingController(text: 'gomi')),
              ElevatedButton(onPressed: () {}, child: const Text('Login')),
            ],
          ),
        ),
      ));
      expect(tester.getSize(find.byType(InputDecorator)).height, closeTo(32, 1));
      expect(tester.getSize(find.byType(ElevatedButton)).height, 32);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('context.controlSize reads the active theme', (tester) async {
      late AppControlSizeTheme read;
      await tester.pumpWidget(MaterialApp(
        theme: _base.copyWith(density: DensityPreset.compact).toThemeData(isDark: false),
        home: Builder(builder: (context) {
          read = context.controlSize;
          return const SizedBox();
        }),
      ));
      expect(read.md, 30);
    });
  });
}

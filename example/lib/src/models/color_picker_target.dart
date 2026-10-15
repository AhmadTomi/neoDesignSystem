import 'package:flutter/material.dart';

/// Targets for interactive color selection in the playground.
enum ColorPickerTarget {
  lightAnchor,
  darkAnchor,
  primary,
  success,
  warning,
  error,
  info,
}

/// Metadata extension for [ColorPickerTarget].
extension ColorPickerTargetInfo on ColorPickerTarget {
  String get title => switch (this) {
        ColorPickerTarget.lightAnchor => 'Light Mode Custom Anchor',
        ColorPickerTarget.darkAnchor => 'Dark Mode Custom Anchor',
        ColorPickerTarget.primary => 'Primary Brand Color',
        ColorPickerTarget.success => 'Success Semantic Color',
        ColorPickerTarget.warning => 'Warning Semantic Color',
        ColorPickerTarget.error => 'Error Semantic Color',
        ColorPickerTarget.info => 'Info Semantic Color',
      };

  String get description => switch (this) {
        ColorPickerTarget.lightAnchor =>
          'Pick a custom anchor color using NeoColorPicker. The OKLCH hue and chroma will dynamically anchor the light mode surfaces.',
        ColorPickerTarget.darkAnchor =>
          'Pick a custom anchor color using NeoColorPicker. The OKLCH hue and chroma will dynamically anchor the dark mode surfaces.',
        ColorPickerTarget.primary =>
          'Pick a primary brand color using NeoColorPicker. It will dynamically adapt in OKLCH for focus borders, primary buttons, and active indicators in both Light & Dark modes.',
        ColorPickerTarget.success =>
          'Pick a base color for success state. OKLCH derivations will generate accessible contrast and surface badges in Light & Dark modes.',
        ColorPickerTarget.warning =>
          'Pick a base color for warning state. OKLCH derivations ensure appropriate luminance and legibility for alerts.',
        ColorPickerTarget.error =>
          'Pick a base color for error state. Applied to TextField error borders, error labels, and alert banners.',
        ColorPickerTarget.info =>
          'Pick a base color for info state. OKLCH derivations ensure cohesive informative callouts and badges.',
      };

  Color defaultAccentColor(Color fallback) => switch (this) {
        ColorPickerTarget.lightAnchor => const Color(0xFFEF4444),
        ColorPickerTarget.darkAnchor => const Color(0xFFFBBF24),
        _ => fallback,
      };
}

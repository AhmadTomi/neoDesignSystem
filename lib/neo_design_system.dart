/// NeoDesignSystem: A modern, mathematical OKLCH-based design system for Flutter.
///
/// Features:
/// - Deterministic perceptual colors with guaranteed WCAG contrast.
/// - Directional corner radii with nested concentric curve support.
/// - Multi-density spacing presets (comfortable vs pure-dense compact).
/// - Single-font typography with OpenType tabular figures & slashed-zero support.
/// - On-the-fly theme switching, customizable presets, and JSON save/load.
library;

export 'src/color/app_color_theme.dart';
export 'src/color/layer_spec.dart';
export 'src/color/oklch_color.dart';
export 'src/extensions/context_extensions.dart';
export 'src/shape/app_radius_theme.dart';
export 'src/spacing/app_spacing_theme.dart';
export 'src/theme/app_theme_controller.dart';
export 'src/theme/theme_config.dart';
export 'src/theme/theme_preset.dart';
export 'src/theme/theme_tokens.dart';
export 'src/typography/app_typography.dart';
export 'src/typography/text_style_extensions.dart';

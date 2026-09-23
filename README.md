# NeoDesignSystem (`neo_design_system`)

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**NeoDesignSystem** is a modern, modular, and mathematically calibrated design system package for Flutter. Built around a 4-pillar token architecture, it combines perceptual **OKLCH** color physics, **directional corner radii**, **multi-density spacing**, and **single-font OpenType typography** with live on-the-fly theme switching, customizable presets, and JSON import/export.

---

## 🌟 Key Highlights

- 🎨 **Mathematical OKLCH Color Engine**: Perceptual uniformity ($L, C, H$) providing deterministic depth layering ($C1 \dots C4$) and guaranteed WCAG AAA contrast without manual tweaking.
- 📐 **Directional Corner Radius**: Directional getters (`.all`, `.top`, `.bottom`, `.left`, `.right`, `.asRadius`) with concentric nested curve formula $R_{\text{inner}} = \max(0, R_{\text{outer}} - \text{padding})$.
- 📏 **Multi-Density Spacing**: Switch between balanced **Comfortable** density and **Pure Dense Compact** layout (zero minimum touch target constraint, tailored for desktop/data-heavy dashboards).
- 🔤 **Single-Font OpenType Typography**: Eliminate extra monospace font weights by chaining OpenType features `.tabular` (tabular figures) and `.slashZero` (slashed zeros) directly on any `TextStyle`.
- 🔄 **On-the-Fly Theming & Modifiers**: Live preset switching, editing, JSON export/import, and dynamic `themeModifier: (baseTheme, tokens) => ...` giving full access to active tokens without hardcoded values.
- 🎛️ **Interactive Theme Playground**: Built-in interactive workbench (`example/lib/main.dart`) to inspect layers, tweak anchor colors, toggle shapes and density, and preview live components.

---

## 📦 Installation

Add `neo_design_system` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  neo_design_system:
    git:
      url: https://github.com/AhmadTomi/neoDesignSystem.git
      ref: master
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

### 1. Initialize Theme with Presets

```dart
import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _themeController = AppThemeController(
    initialPreset: BuiltInPresets.slate,
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'My Neo App',
          theme: _themeController.buildThemeData(isDark: false),
          darkTheme: _themeController.buildThemeData(isDark: true),
          themeMode: _themeController.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
```

### 2. Access Tokens via `BuildContext`

`neo_design_system` exposes ergonomic context extensions:

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.color;       // Active OKLCH AppColorTheme
    final radius = context.radius;     // Active AppRadiusTheme
    final spacing = context.spacing;   // Active AppSpacingTheme
    final text = context.text;         // Active TextTheme

    return Scaffold(
      backgroundColor: color.container1,
      body: Padding(
        padding: spacing.insetMd,
        child: Container(
          decoration: BoxDecoration(
            color: color.container3,
            borderRadius: radius.lg.all,
            border: Border.all(color: color.subtleBorder),
          ),
          padding: spacing.insetMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Balance',
                style: text.titleMedium?.withColor(color.textMain),
              ),
              spacing.vGapSm,
              Text(
                '\$10,240.50',
                style: text.titleLarge?.tabular.slashZero.withColor(color.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🏛️ 4-Pillar Design Tokens

### 1. OKLCH Tiered Surface Palette (`context.color`)
Surfaces are organized into a strict visual depth hierarchy derived from anchor colors:

| Token | Light Mode Behavior | Dark Mode Behavior | Primary Usage |
| :--- | :--- | :--- | :--- |
| `container1` | Canvas base ($L \approx 0.956$) | Deep canvas ($L \approx 0.205$) | App scaffold background |
| `container2` | Card wrapper | Elevating layer ($+0.022L$) | Card panels, grouped wrappers |
| `container3` | Primary Anchor ($L = 0.92$) | Primary Anchor ($L = 0.26$) | Interactive surface, base anchor |
| `textFieldFill` | Sunken trough ($-0.030L$) | Soft trough ($-0.018L$) | Sunken input fields |
| `container4` | Popover surface | Floating overlay ($+0.070L$) | Dialogs, context menus, tooltips |
| `primary` | Calibrated OKLCH brand color | Calibrated OKLCH brand color | CTA buttons, active indicators |
| `textMain` | WCAG AAA ($L = 0.20$) | WCAG AAA ($L = 0.93$) | Primary text |
| `textSecondary`| Auto-dimmed ($65\%$ alpha) | Auto-dimmed ($65\%$ alpha) | Subtitles, secondary captions |
| `textMuted` | Low-emphasis ($50\%$ alpha) | Low-emphasis ($50\%$ alpha) | Input placeholders |
| `textDisabled` | Accessible non-interactive | Accessible non-interactive | Disabled labels & borders |

### 2. Directional Corner Radius (`context.radius`)
- **Directional Properties**: `.all`, `.top`, `.bottom`, `.left`, `.right`, and `.asRadius`.
- **Concentric Nesting**:
  ```dart
  // Automatically ensures inner corners stay parallel to outer card curves
  final innerRadius = radius.nested(outer: radius.xl, padding: 8);
  ```
- **Presets**:
  - `AppRadiusTheme.rounded()`: Friendly modern curves (`sm: 8`, `md: 12`, `lg: 16`, `xl: 24`).
  - `AppRadiusTheme.sharp()`: Zero-radius crisp edges for compact data density.

### 3. Multi-Density Spacing (`context.spacing`)
- **Comfortable**: Standard mobile & web padding (`insetMd: 16px`, `gapSm: 12px`, `touchTargetMin: 48px`).
- **Compact**: Pure high-density layout without touch target constraints (`touchTargetMin: 0px`, `insetMd: 10px`, `gapSm: 6px`).
- **SizedBox Helpers**: `spacing.vGapXs`, `spacing.vGapSm`, `spacing.vGapMd`, `spacing.vGapLg`, `spacing.hGap...`.

### 4. Single-Font OpenType Typography (`SingleFontFeaturesX`)
Works across any single font family without needing separate monospaced fonts:
```dart
// Tabular numbers for financial tables & counters
Text('123,456.78', style: text.bodyMedium?.tabular);

// Slashed zero to prevent character ambiguity
Text('CODE-001', style: text.bodyMedium?.slashZero);

// Chaining both features
Text('2026-09-19', style: text.bodyMedium?.tabular.slashZero);
```

---

## 🎨 Theme Presets & Dynamic Modifiers

### Built-in Presets
- `BuiltInPresets.slate`: Cool slate with rounded cards and comfortable spacing.
- `BuiltInPresets.emerald`: Sharp enterprise layout with compact density and emerald accents.
- `BuiltInPresets.nordic`: Crisp frosty blue palette with modern rounded cards.
- `BuiltInPresets.amber`: Warm amber accents with high-readability dark mode.

### Custom Preset with `themeModifier`
Customize any Flutter `ThemeData` element using all active tokens directly:

```dart
final customPreset = ThemePreset(
  id: 'my_custom_theme',
  name: 'Custom Theme',
  lightAnchor: const Color(0xFFF4F5F7),
  darkAnchor: const Color(0xFF101010),
  primaryColor: const Color(0xFF6366F1),
  themeModifier: (baseTheme, tokens) {
    return baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.color.container2,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: tokens.radius.sm.all),
          padding: tokens.spacing.insetSquish,
        ),
      ),
    );
  },
);
```

### JSON Save & Load
Export and import theme presets seamlessly using standard JSON:

```dart
// Export
final jsonString = themeController.exportCurrentPresetAsJson();

// Import
final importedPreset = themeController.importPresetFromJson(jsonString);
```

---

## 🧪 Running the Interactive Playground & Tests

Run the interactive Theme Playground app locally:

```bash
flutter run -d chrome # or windows / macos
```

Run the automated test suite:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

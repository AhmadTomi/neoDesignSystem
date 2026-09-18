# Design System Lite (OKLCH Tiered Palette Architecture)

A Flutter design system and interactive showcase demonstrating a mathematically calibrated, tiered depth hierarchy built on the **OKLCH** perceptual color model.

## 📖 Specifications & AI Agent Rules

For the complete, deterministic mathematical formulas, token derivations, text hierarchy, and component rules, see:
* 👉 **[DESIGN_SYSTEM_RULES.md](DESIGN_SYSTEM_RULES.md)**

## 🚀 Key Features

* **Perceptual Uniformity**: Powered by OKLCH color conversions with mathematically predictable lightness ($L$), chroma ($C$), and hue ($H$).
* **Tiered Surface Hierarchy**: $C1$ Canvas, $C2$ Card Wrapper, $C3$ Anchor Surface, $TF$ Sunken Input Trough, and $C4$ Floating Overlay (Dialogs & Context Menus).
* **Single-Root Text Engine**: `textMain` derives directly from the theme anchor's hue while maintaining WCAG AAA contrast ($L = 0.20$ Light, $L = 0.93$ Dark).
* **Interactive NeoColorPicker Showcase**: Choose custom anchors for Light and Dark modes independently.


# Design Tokens Architecture Specification

> **Target Audience:** Design System Engineers, Frontend Developers, LLM/Agentic Assistants.  
> **Scope:** Spesifikasi lengkap sistem token untuk **Border Radius**, **Spacing (Multi-Density)**, dan **Typography (Single-Font OpenType)** terintegrasi dengan Color Engine (OKLCH).

---

## 1. Sistem Matriks 4 Pilar

Sistem desain ini dibangun di atas 4 pilar independen yang ortogonal:

| Pilar | Domain | Pengatur / Engine | Perilaku Multi-Theme |
| :--- | :--- | :--- | :--- |
| **Color** | *Lighting & State* | `LayerPalette` (OKLCH) | Light Mode vs Dark Mode, Brand Accent |
| **Shape** | *Brand Personality* | `AppRadiusTheme` | Rounded (Modern) vs Sharp (Dense/Enterprise) |
| **Spacing** | *Density & Ergonomics* | `AppSpacingTheme` | Comfortable (Default) vs Compact (Pure Dense) |
| **Typography** | *Legibility & Data* | `AppTypography` + OpenType | Single Font Family, Tabular Figures, Slashed Zero |

---

## 2. Corner Radius & Shape System

### 2.1. Skala Token Primitif
Token radius tidak hanya menyimpan nilai skalar `double`, melainkan dibungkus class `CornerRadius` agar mendukung sudut asimetris / directional (`all`, `top`, `bottom`, `left`, `right`) langsung ke `BorderRadius` Flutter.

```dart
@immutable
class CornerRadius {
  final double value;
  const CornerRadius(this.value);

  BorderRadius get all => BorderRadius.circular(value);
  BorderRadius get top => BorderRadius.vertical(top: Radius.circular(value));
  BorderRadius get bottom => BorderRadius.vertical(bottom: Radius.circular(value));
  BorderRadius get left => BorderRadius.horizontal(left: Radius.circular(value));
  BorderRadius get right => BorderRadius.horizontal(right: Radius.circular(value));
  Radius get asRadius => Radius.circular(value);
}
```

### 2.2. Hirarki Semantik & Presets

| Token | Deskripsi Semantik | Preset Rounded (Default) | Preset Sharp |
| :--- | :--- | :---: | :---: |
| `none` | Garis tegas / pembatas / flush | `0px` | `0px` |
| `sm` | Chip, badge, checkbox, inner nested slot | `6px` | `2px` |
| `md` | Controls (Button, TextField, Dropdown) | `10px` | `4px` |
| `lg` | Container / Card (C2, C3) | `16px` | `6px` |
| `xl` | Floating Overlays (Modal Dialog C4, Sheet) | `24px` | `8px` |
| `full` | Pill shape, avatar lingkaran | `9999px` | `9999px` |

### 2.3. Aturan Concentric Radius (Nested Corners)
Untuk menjaga sudut luar dan dalam tidak terjepit saat bersarang (*nested*):
$$\text{Radius}_{\text{inner}} = \max(0, \; \text{Radius}_{\text{outer}} - \text{Padding})$$
* *Contoh:* Card $R_{\text{outer}} = 16\text{px}$ dengan padding $10\text{px}$ $\implies$ inner slot idealnya $R_{\text{inner}} = 6\text{px}$ (`radius.sm`).

---

## 3. Spacing & Density System

Sistem spacing dirancang bebas dari *token bloat* dan **tidak membatasi touch target pada mode Compact**, memungkinkan tampilan *pure dense* untuk desktop/data-heavy tools.

### 3.1. Klasifikasi Ruang
* **Insets (`EdgeInsets`)**: Ruang bantalan internal komponen tertutup.
* **Gaps (`double`)**: Jarak antar elemen sejajar / bertumpuk, dilengkapi shortcut widget `SizedBox`.

### 3.2. Mapping Multi-Density

| Token | Peruntukan | Comfortable (Default) | Compact (Pure Dense) |
| :--- | :--- | :---: | :---: |
| `insetSquish` | Tombol, TextField, Chip (vertikal ramping) | `h: 14, v: 10` | `h: 8, v: 4` |
| `insetSm` | List item, compact panel | `8px` | `6px` |
| `insetMd` | Card normal (C2, C3) | `16px` | `10px` |
| `insetLg` | Modal dialog (C4), popover | `24px` | `16px` |
| `gapXs` | Micro gap (Icon ke teks) | `6px` | `4px` |
| `gapSm` | Form field item ke item | `12px` | `6px` |
| `gapMd` | Antar card / section kecil | `16px` | `10px` |
| `gapLg` | Antar section besar | `24px` | `16px` |

---

## 4. Typography & Single-Font System

Sistem tipografi menggunakan **1 jenis font tunggal** (misal: *Inter*, *Geist*, atau *Roboto*). Kebutuhan angka monospaced untuk tabel finansial dan timer diselesaikan via **OpenType Feature Flags**.

### 4.1. Hirarki Skala Teks (Ukuran & Line Height)
Pada mode Compact, keterbacaan dipertahankan dengan merapatkan `height` (line-height) alih-alih mengecilkan font secara ekstrem:

| Role | Token | Comfortable (`size / height`) | Compact (`size / height`) | Weight |
| :--- | :--- | :---: | :---: | :---: |
| **Title** | `titleLg`<br>`titleMd`<br>`titleSm` | 20px / 1.35<br>16px / 1.35<br>14px / 1.40 | 18px / 1.15<br>15px / 1.20<br>13px / 1.20 | w600<br>w600<br>w600 |
| **Body** | `bodyLg`<br>`bodyMd`<br>`bodySm` | 16px / 1.50<br>14px / 1.45<br>13px / 1.40 | 15px / 1.25<br>13.5px / 1.20<br>12px / 1.15 | w400<br>w400<br>w400 |
| **Label** | `labelMd`<br>`labelSm` | 13px / 1.20<br>11px / 1.20 | 12px / 1.10<br>10.5px / 1.10 | w500<br>w500 |

### 4.2. OpenType Feature Modifiers (Bebas Ambiguitas)
* **`.tabular`**: Mengaktifkan `FontFeature.tabularFigures()`. Angka (0–9) memiliki lebar seragam (*monospaced*) agar lurus vertikal di tabel data & counter tidak goyang.
* **`.slashZero`**: Mengaktifkan `FontFeature.slashedZero()`. Angka nol diberi garis coret diagonal agar jelas dibedakan dari huruf `O`.

### 4.3. Pewarnaan Semantik Fluent (`TextStyle?`)
Warna teks tidak di-hardcode pada definisi style, melainkan dirangkai (*chainable*) melalui extension:
* `.withColor(color)`: Mengubah warna bebas (misal: `palette.error`, `palette.primary`).
* `.withMain(textMain)`: 100% alpha (High emphasis).
* `.withSecondary(textMain)`: 72% alpha (Medium emphasis).
* `.withMuted(textMain)`: 50% alpha (Low emphasis).
* `.withDisabled(textMain)`: 38% alpha (Disabled).

---

## 5. Implementasi Flutter Lengkap

```dart
import 'dart:ui';
import 'package:flutter/material.dart';

// ==========================================
// 1. CORNER RADIUS THEME
// ==========================================

@immutable
class CornerRadius {
  final double value;
  const CornerRadius(this.value);

  BorderRadius get all => BorderRadius.circular(value);
  BorderRadius get top => BorderRadius.vertical(top: Radius.circular(value));
  BorderRadius get bottom => BorderRadius.vertical(bottom: Radius.circular(value));
  BorderRadius get left => BorderRadius.horizontal(left: Radius.circular(value));
  BorderRadius get right => BorderRadius.horizontal(right: Radius.circular(value));
  Radius get asRadius => Radius.circular(value);
}

@immutable
class AppRadiusTheme extends ThemeExtension<AppRadiusTheme> {
  final CornerRadius none;
  final CornerRadius sm;
  final CornerRadius md;
  final CornerRadius lg;
  final CornerRadius xl;
  final CornerRadius full;

  const AppRadiusTheme({
    this.none = const CornerRadius(0),
    this.sm = const CornerRadius(6),
    this.md = const CornerRadius(10),
    this.lg = const CornerRadius(16),
    this.xl = const CornerRadius(24),
    this.full = const CornerRadius(9999),
  });

  factory AppRadiusTheme.rounded() => const AppRadiusTheme();

  factory AppRadiusTheme.sharp() => const AppRadiusTheme(
    sm: CornerRadius(2),
    md: CornerRadius(4),
    lg: CornerRadius(6),
    xl: CornerRadius(8),
    full: CornerRadius(9999),
  );

  @override
  AppRadiusTheme copyWith({
    CornerRadius? none,
    CornerRadius? sm,
    CornerRadius? md,
    CornerRadius? lg,
    CornerRadius? xl,
    CornerRadius? full,
  }) {
    return AppRadiusTheme(
      none: none ?? this.none,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      full: full ?? this.full,
    );
  }

  @override
  AppRadiusTheme lerp(ThemeExtension<AppRadiusTheme>? other, double t) {
    if (other is! AppRadiusTheme) return this;
    return AppRadiusTheme(
      sm: CornerRadius(lerpDouble(sm.value, other.sm.value, t)!),
      md: CornerRadius(lerpDouble(md.value, other.md.value, t)!),
      lg: CornerRadius(lerpDouble(lg.value, other.lg.value, t)!),
      xl: CornerRadius(lerpDouble(xl.value, other.xl.value, t)!),
      full: CornerRadius(lerpDouble(full.value, other.full.value, t)!),
    );
  }
}

// ==========================================
// 2. SPACING THEME
// ==========================================

@immutable
class AppSpacingTheme extends ThemeExtension<AppSpacingTheme> {
  final EdgeInsets insetSquish;
  final EdgeInsets insetSm;
  final EdgeInsets insetMd;
  final EdgeInsets insetLg;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const AppSpacingTheme({
    required this.insetSquish,
    required this.insetSm,
    required this.insetMd,
    required this.insetLg,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  factory AppSpacingTheme.comfortable() => const AppSpacingTheme(
    insetSquish: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    insetSm: EdgeInsets.all(8),
    insetMd: EdgeInsets.all(16),
    insetLg: EdgeInsets.all(24),
    gapXs: 6,
    gapSm: 12,
    gapMd: 16,
    gapLg: 24,
  );

  factory AppSpacingTheme.compact() => const AppSpacingTheme(
    insetSquish: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    insetSm: EdgeInsets.all(6),
    insetMd: EdgeInsets.all(10),
    insetLg: EdgeInsets.all(16),
    gapXs: 4,
    gapSm: 6,
    gapMd: 10,
    gapLg: 16,
  );

  Widget get vGapXs => SizedBox(height: gapXs);
  Widget get vGapSm => SizedBox(height: gapSm);
  Widget get vGapMd => SizedBox(height: gapMd);
  Widget get vGapLg => SizedBox(height: gapLg);

  Widget get hGapXs => SizedBox(width: gapXs);
  Widget get hGapSm => SizedBox(width: gapSm);
  Widget get hGapMd => SizedBox(width: gapMd);
  Widget get hGapLg => SizedBox(width: gapLg);

  @override
  AppSpacingTheme copyWith({
    EdgeInsets? insetSquish,
    EdgeInsets? insetSm,
    EdgeInsets? insetMd,
    EdgeInsets? insetLg,
    double? gapXs,
    double? gapSm,
    double? gapMd,
    double? gapLg,
  }) {
    return AppSpacingTheme(
      insetSquish: insetSquish ?? this.insetSquish,
      insetSm: insetSm ?? this.insetSm,
      insetMd: insetMd ?? this.insetMd,
      insetLg: insetLg ?? this.insetLg,
      gapXs: gapXs ?? this.gapXs,
      gapSm: gapSm ?? this.gapSm,
      gapMd: gapMd ?? this.gapMd,
      gapLg: gapLg ?? this.gapLg,
    );
  }

  @override
  AppSpacingTheme lerp(ThemeExtension<AppSpacingTheme>? other, double t) {
    if (other is! AppSpacingTheme) return this;
    return AppSpacingTheme(
      insetSquish: EdgeInsets.lerp(insetSquish, other.insetSquish, t)!,
      insetSm: EdgeInsets.lerp(insetSm, other.insetSm, t)!,
      insetMd: EdgeInsets.lerp(insetMd, other.insetMd, t)!,
      insetLg: EdgeInsets.lerp(insetLg, other.insetLg, t)!,
      gapXs: lerpDouble(gapXs, other.gapXs, t)!,
      gapSm: lerpDouble(gapSm, other.gapSm, t)!,
      gapMd: lerpDouble(gapMd, other.gapMd, t)!,
      gapLg: lerpDouble(gapLg, other.gapLg, t)!,
    );
  }
}

// ==========================================
// 3. TYPOGRAPHY & OPENTYPE EXTENSIONS
// ==========================================

extension SingleFontFeaturesX on TextStyle? {
  TextStyle? get tabular => this?.copyWith(
    fontFeatures: [
      ...?this?.fontFeatures,
      const FontFeature.tabularFigures(),
    ],
  );

  TextStyle? get slashZero => this?.copyWith(
    fontFeatures: [
      ...?this?.fontFeatures,
      const FontFeature.slashedZero(),
    ],
  );

  TextStyle? withColor(Color color) => this?.copyWith(color: color);
  TextStyle? withMain(Color textMain) => this?.copyWith(color: textMain);
  TextStyle? withSecondary(Color textMain) => this?.copyWith(color: textMain.withValues(alpha: 0.72));
  TextStyle? withMuted(Color textMain) => this?.copyWith(color: textMain.withValues(alpha: 0.50));
  TextStyle? withDisabled(Color textMain) => this?.copyWith(color: textMain.withValues(alpha: 0.38));
}

// ==========================================
// 4. CONTEXT EXTENSIONS (DEVELOPER SHORTCUT)
// ==========================================

extension DesignTokensContext on BuildContext {
  AppSpacingTheme get spacing =>
      Theme.of(this).extension<AppSpacingTheme>() ?? AppSpacingTheme.comfortable();

  AppRadiusTheme get radius =>
      Theme.of(this).extension<AppRadiusTheme>() ?? AppRadiusTheme.rounded();

  TextTheme get text => Theme.of(this).textTheme;
}
```

---

## 6. Contoh Pemakaian Terpadu di Widget UI

```dart
class FinancialMetricCard extends StatelessWidget {
  final String title;
  final String invoiceCode;
  final double amount;
  final bool isNegative;

  const FinancialMetricCard({
    super.key,
    required this.title,
    required this.invoiceCode,
    required this.amount,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.spacing;
    final r = context.radius;
    final t = context.text;
    final palette = context.palette; // Dari LayerPalette OKLCH

    return Container(
      padding: s.insetMd,
      decoration: BoxDecoration(
        color: palette.container3,
        borderRadius: r.lg.all,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: t.titleMedium),
              // Kode invoice: Monospace + 0 bercoret + 50% muted alpha
              Text(invoiceCode, style: t.labelSmall.slashZero.tabular.withMuted(palette.textMain)),
            ],
          ),
          s.vGapSm,
          // Angka saldo: Tabular figures agar sejajar, warna dinamis error/main
          Text(
            "Rp ${amount.toStringAsFixed(2)}",
            style: t.titleLarge.tabular.withColor(isNegative ? palette.error : palette.textMain),
          ),
          s.vGapMd,
          // Inner action control
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: s.insetSquish,
              shape: RoundedRectangleBorder(borderRadius: r.md.all),
            ),
            onPressed: () {},
            child: Text("Lihat Detail", style: t.labelMedium),
          ),
        ],
      ),
    );
  }
}
```

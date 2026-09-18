import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:neo_color_picker/neo_color_picker.dart';

void main() {
  runApp(const OklchPaletteDemoApp());
}

/// Helper class for converting OKLCH color coordinates to Flutter [Color].
///
/// Formula pipeline:
/// OKLCH (L, C, H) -> OKLab (L, a, b) -> Linear LMS -> Linear sRGB -> Standard sRGB (Color)
class OklchColor {
  /// Perceptual lightness in the range [0.0, 1.0].
  final double l;

  /// Chroma (color intensity / saturation), >= 0.0.
  final double c;

  /// Hue angle in degrees in the range [0.0, 360.0).
  final double h;

  const OklchColor(this.l, this.c, this.h);

  /// Converts OKLCH to a Flutter [Color] with the given [alpha] (0.0 to 1.0).
  Color toColor({double alpha = 1.0}) {
    // 1. OKLCH to OKLab
    final hRad = h * (math.pi / 180.0);
    final a = c * math.cos(hRad);
    final b = c * math.sin(hRad);

    // 2. OKLab to non-linear LMS
    final l_ = l + 0.3963377774 * a + 0.2158037573 * b;
    final m_ = l - 0.1055613458 * a - 0.0638541728 * b;
    final s_ = l - 0.0894841775 * a - 1.2914855480 * b;

    // Cube to obtain linear LMS
    final lLin = l_ * l_ * l_;
    final mLin = m_ * m_ * m_;
    final sLin = s_ * s_ * s_;

    // 3. Linear LMS to Linear sRGB (Björn Ottosson inverse matrix)
    final rLin =
        4.0767416621 * lLin - 3.3077115913 * mLin + 0.2309699292 * sLin;
    final gLin =
        -1.2684380046 * lLin + 2.6097574011 * mLin - 0.3413193965 * sLin;
    final bLin =
        -0.0041960863 * lLin - 0.7034186147 * mLin + 1.7076147010 * sLin;

    // 4. Linear sRGB to standard sRGB (gamma transfer function)
    final rSrgb = _linearToSrgb(rLin);
    final gSrgb = _linearToSrgb(gLin);
    final bSrgb = _linearToSrgb(bLin);

    // Quantize to 8-bit channels [0..255]
    final rInt = (rSrgb * 255.0).round().clamp(0, 255);
    final gInt = (gSrgb * 255.0).round().clamp(0, 255);
    final bInt = (bSrgb * 255.0).round().clamp(0, 255);
    final aInt = (alpha * 255.0).round().clamp(0, 255);

    return Color.fromARGB(aInt, rInt, gInt, bInt);
  }

  /// Converts a standard Flutter [Color] into [OklchColor].
  factory OklchColor.fromColor(Color color) {
    // 1. sRGB [0..1] to Linear sRGB (gamma decode)
    final r = _srgbToLinear(color.r);
    final g = _srgbToLinear(color.g);
    final b = _srgbToLinear(color.b);

    // 2. Linear sRGB to Linear LMS (Björn Ottosson matrix)
    final lLin = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
    final mLin = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
    final sLin = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;

    // 3. Non-linear LMS (cube root)
    final l_ = _cbrt(lLin);
    final m_ = _cbrt(mLin);
    final s_ = _cbrt(sLin);

    // 4. LMS to OKLab (L, a, b)
    final lVal = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_;
    final aVal = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_;
    final bVal = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_;

    // 5. OKLab to OKLCH (L, C, H)
    final cVal = math.sqrt(aVal * aVal + bVal * bVal);
    var hRad = math.atan2(bVal, aVal);
    var hDeg = hRad * (180.0 / math.pi);
    if (hDeg < 0.0) hDeg += 360.0;

    return OklchColor(lVal.clamp(0.0, 1.0), math.max(0.0, cVal), hDeg % 360.0);
  }

  static double _cbrt(double x) {
    if (x > 0.0) return math.pow(x, 1.0 / 3.0).toDouble();
    if (x < 0.0) return -math.pow(-x, 1.0 / 3.0).toDouble();
    return 0.0;
  }

  static double _srgbToLinear(double val) {
    final clamped = val.clamp(0.0, 1.0);
    if (clamped <= 0.04045) {
      return clamped / 12.92;
    } else {
      return math.pow((clamped + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  /// Standard IEC 61966-2-1 sRGB gamma transfer function.
  static double _linearToSrgb(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (clamped <= 0.0031308) {
      return 12.92 * clamped;
    } else {
      return 1.055 * math.pow(clamped, 1.0 / 2.4) - 0.055;
    }
  }

  /// Returns 6-character hex string (e.g. #3B82F6).
  String get hexCode {
    final color = toColor();
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }
}

/// Metadata information for individual layers for display & inspection.
class LayerSpec {
  final String id;
  final String label;
  final String role;
  final double l;
  final double c;
  final Color color;
  final String hex;
  final String formula;

  const LayerSpec({
    required this.id,
    required this.label,
    required this.role,
    required this.l,
    required this.c,
    required this.color,
    required this.hex,
    required this.formula,
  });
}

/// Custom [ThemeExtension] implementing a tiered color system anchored at Container 3.
class LayerPalette extends ThemeExtension<LayerPalette> {
  /// Background utama kanvas
  final Color container1;

  /// Card penampung lapis kedua
  final Color container2;

  /// Permukaan acuan utama lapis ketiga (Anchor)
  final Color container3;

  /// Warna isian TextField dengan efek cekung/trough
  final Color textFieldFill;

  /// Lapis teratas mengambang (Dialog, Context Menu, dan Popover Surface)
  final Color container4;

  /// Warna teks berdaya kontras tinggi
  final Color textMain;

  /// Warna isian Tonal Button (kontras & harmonis di atas Container 3 dan Container 4)
  final Color tonalButtonFill;

  /// Warna teks/ikon Tonal Button berdaya kontras tinggi
  final Color tonalButtonText;

  /// Garis pemisah tipis dengan kontras rendah
  final Color dividerLine;

  /// Garis tepi fisik tipis (1px) untuk menegaskan lekukan cekung sebelum elemen disentuh
  final Color textFieldBorder;

  /// Warna isian TextField nonaktif (disamakan persis dengan Container 3 agar efek cekung hilang dan tampak rata)
  final Color textFieldDisabledFill;

  /// Garis tepi sangat redup agar batas fisik tetap ada secara samar tanpa mengundang interaksi
  final Color textFieldDisabledBorder;

  /// Standar kontras WCAG untuk menandakan status teks/ikon non-interaktif
  final Color textDisabled;

  /// Warna aksen utama (Primary Brand) untuk tombol utama, focused border, dan aksen aktif
  final Color primary;

  /// Warna teks/ikon dengan kontras tinggi di atas permukaan [primary]
  final Color onPrimary;

  /// Warna status sukses (Success) untuk badge konfirmasi, alert sukses, dll.
  final Color success;
  final Color onSuccess;

  /// Warna status peringatan (Warning) untuk alert perhatian, banner hati-hati, dll.
  final Color warning;
  final Color onWarning;

  /// Warna status kesalahan (Error) untuk error border, error text, alert bahaya, dll.
  final Color error;
  final Color onError;

  /// Warna status informasi (Info) untuk badge edukatif, popover tips, dll.
  final Color info;
  final Color onInfo;

  // Metadata parameters for UI transparency & inspection
  final double anchorL;
  final double chroma;
  final double hue;
  final bool isDark;

  // Layer specifications for the inspector
  final List<LayerSpec> specs;

  const LayerPalette({
    required this.container1,
    required this.container2,
    required this.container3,
    required this.textFieldFill,
    required this.container4,
    required this.textMain,
    required this.tonalButtonFill,
    required this.tonalButtonText,
    required this.dividerLine,
    required this.textFieldBorder,
    required this.textFieldDisabledFill,
    required this.textFieldDisabledBorder,
    required this.textDisabled,
    required this.primary,
    required this.onPrimary,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.error,
    required this.onError,
    required this.info,
    required this.onInfo,
    this.anchorL = 0.0,
    this.chroma = 0.0,
    this.hue = 0.0,
    this.isDark = false,
    this.specs = const [],
  });

  /// Factory constructor that calculates tiered colors relative to Container 3 (anchorL).
  factory LayerPalette.fromAnchor({
    required double anchorL,
    required double c,
    required double h,
    required bool isDark,
    Color? primaryColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? infoColor,
    double? c2Delta,
    double? troughDelta,
  }) {
    // Delta antara Container 2 dan Container 3 dibuat rapat, halus & harmonis:
    // Light Mode: 0.018 (sebelumnya 0.030)
    // Dark Mode: 0.022 (sebelumnya 0.050)
    final effectiveC2Delta = c2Delta ?? (isDark ? 0.022 : 0.018);
    final effectiveTroughDelta = troughDelta ?? (isDark ? 0.018 : 0.030);

    // Derivasi Primary & Semantic Status Color berbasis OKLCH
    final effectivePrimary = primaryColor ?? const Color(0xFF2563EB);
    final oklchP = OklchColor.fromColor(effectivePrimary);

    final effectiveSuccess = successColor ?? const Color(0xFF10B981);
    final oklchSuc = OklchColor.fromColor(effectiveSuccess);

    final effectiveWarning = warningColor ?? const Color(0xFFF59E0B);
    final oklchWar = OklchColor.fromColor(effectiveWarning);

    final effectiveError = errorColor ?? const Color(0xFFEF4444);
    final oklchErr = OklchColor.fromColor(effectiveError);

    final effectiveInfo = infoColor ?? const Color(0xFF06B6D4);
    final oklchInf = OklchColor.fromColor(effectiveInfo);

    if (!isDark) {
      // ----------------- Light Mode Formulas -----------------
      // container1: anchorL + (effectiveC2Delta * 2.0) (clamp max 0.99), chroma: c * 0.70
      final l1 = (anchorL + effectiveC2Delta * 2.0).clamp(0.0, 0.99);
      final c1 = c * 0.70;
      final oklch1 = OklchColor(l1, c1, h);

      // container2: anchorL + effectiveC2Delta (dekat & harmonis dengan C3), chroma: c * 0.90
      final l2 = (anchorL + effectiveC2Delta).clamp(0.0, 1.0);
      final c2 = c * 0.90;
      final oklch2 = OklchColor(l2, c2, h);

      // container3: anchorL, chroma: c (Primary Anchor)
      final l3 = anchorL.clamp(0.0, 1.0);
      final c3 = c;
      final oklch3 = OklchColor(l3, c3, h);

      // textFieldFill: anchorL - effectiveTroughDelta (efek cekung/trough lebih gelap dari C3), chroma: c * 1.2
      final lField = (anchorL - effectiveTroughDelta).clamp(0.0, 1.0);
      final cField = c * 1.2;
      final oklchField = OklchColor(lField, cField, h);

      // container4: anchorL + 0.010 (clamp max 0.985), chroma: c * 0.85 (Harmonis & lembut di atas C3)
      final l4 = (anchorL + 0.010).clamp(0.0, 0.985);
      final c4 = c * 0.85;
      final oklch4 = OklchColor(l4, c4, h);

      // textMain: L = 0.20, chroma: 0.03
      final lText = 0.20;
      final cText = 0.03;
      final oklchText = OklchColor(lText, cText, h);

      // tonalButtonFill: (anchorL - 0.055).clamp(0.0, 1.0)
      final lTbf = (anchorL - 0.055).clamp(0.0, 1.0);
      final cTbf = c > 0.001 ? math.max(c * 1.4, 0.018) : 0.0;
      final oklchTbf = OklchColor(lTbf, cTbf, h);

      // tonalButtonText: textMain (CR > 9:1 terhadap TBF)
      final oklchTbt = oklchText;

      // 1. Divider Line: oklch(clamp(0.0, L_c3 - 0.05, 1.0) (C * 0.5) H)
      final lDivider = (anchorL - 0.05).clamp(0.0, 1.0);
      final cDivider = c * 0.5;
      final oklchDivider = OklchColor(lDivider, cDivider, h);

      // 2. Border TextField (Default/Unfocused): oklch(clamp(0.0, L_c3 - 0.10, 1.0) 0.02 H)
      final lTfBorder = (anchorL - 0.10).clamp(0.0, 1.0);
      const cTfBorder = 0.02;
      final oklchTfBorder = OklchColor(lTfBorder, cTfBorder, h);

      // Primary Color in Light Mode: Kalibrasi lightness agar kontras seimbang di atas kanvas terang
      final lPri = oklchP.l.clamp(0.35, 0.65);
      final oklchPri = OklchColor(lPri, oklchP.c, oklchP.h);
      final colPrimary = oklchPri.toColor();
      final colOnPrimary = lPri > 0.62 ? const Color(0xFF0F172A) : Colors.white;

      // Semantic Status Colors in Light Mode
      final lSuc = oklchSuc.l.clamp(0.35, 0.65);
      final oklchSucDerived = OklchColor(lSuc, oklchSuc.c, oklchSuc.h);
      final colSuccess = oklchSucDerived.toColor();
      final colOnSuccess = lSuc > 0.62 ? const Color(0xFF0F172A) : Colors.white;

      final lWar = oklchWar.l.clamp(0.40, 0.72);
      final oklchWarDerived = OklchColor(lWar, oklchWar.c, oklchWar.h);
      final colWarning = oklchWarDerived.toColor();
      final colOnWarning = lWar > 0.62 ? const Color(0xFF0F172A) : Colors.white;

      final lErr = oklchErr.l.clamp(0.35, 0.65);
      final oklchErrDerived = OklchColor(lErr, oklchErr.c, oklchErr.h);
      final colError = oklchErrDerived.toColor();
      final colOnError = lErr > 0.62 ? const Color(0xFF0F172A) : Colors.white;

      final lInf = oklchInf.l.clamp(0.35, 0.65);
      final oklchInfDerived = OklchColor(lInf, oklchInf.c, oklchInf.h);
      final colInfo = oklchInfDerived.toColor();
      final colOnInfo = lInf > 0.62 ? const Color(0xFF0F172A) : Colors.white;

      final col1 = oklch1.toColor();
      final col2 = oklch2.toColor();
      final col3 = oklch3.toColor();
      final colField = oklchField.toColor();
      final col4 = oklch4.toColor();
      final colText = oklchText.toColor();
      final colTbf = oklchTbf.toColor();
      final colTbt = oklchTbt.toColor();
      final colDivider = oklchDivider.toColor();
      final colTfBorder = oklchTfBorder.toColor();

      // 3. Disabled TextField Fill: Disamakan persis dengan Container 3 (L = L_c3, C, H)
      final colTfDisabledFill = col3;

      // 4. Disabled Border: textMain dengan alpha 0.08
      final colTfDisabledBorder = colText.withValues(alpha: 0.08);

      // 5. Disabled Text / Icon: textMain dengan alpha 0.38
      final colTextDisabled = colText.withValues(alpha: 0.38);

      final specs = [
        LayerSpec(
          id: 'C1',
          label: 'Container 1',
          role: 'Canvas Background',
          l: l1,
          c: c1,
          color: col1,
          hex: oklch1.hexCode,
          formula:
              'anchorL + ${(effectiveC2Delta * 2.0).toStringAsFixed(3)} (c * 0.70)',
        ),
        LayerSpec(
          id: 'C2',
          label: 'Container 2',
          role: 'Card Wrapper',
          l: l2,
          c: c2,
          color: col2,
          hex: oklch2.hexCode,
          formula:
              'anchorL + ${effectiveC2Delta.toStringAsFixed(3)} (c * 0.90)',
        ),
        LayerSpec(
          id: 'C3',
          label: 'Container 3',
          role: 'Anchor Surface',
          l: l3,
          c: c3,
          color: col3,
          hex: oklch3.hexCode,
          formula: 'anchorL (c * 1.0)',
        ),
        LayerSpec(
          id: 'TF',
          label: 'TextField Fill',
          role: 'Sunken Trough',
          l: lField,
          c: cField,
          color: colField,
          hex: oklchField.hexCode,
          formula:
              'anchorL - ${effectiveTroughDelta.toStringAsFixed(3)} (c * 1.2)',
        ),
        LayerSpec(
          id: 'TFB',
          label: 'TF Border',
          role: 'Default Unfocused Outline',
          l: lTfBorder,
          c: cTfBorder,
          color: colTfBorder,
          hex: oklchTfBorder.hexCode,
          formula: 'anchorL - 0.10 (c = 0.02)',
        ),
        LayerSpec(
          id: 'TFD',
          label: 'Disabled TF Fill',
          role: 'Flat with C3 (no trough)',
          l: l3,
          c: c3,
          color: colTfDisabledFill,
          hex: oklch3.hexCode,
          formula: 'L = anchorL, C = c (= C3)',
        ),
        LayerSpec(
          id: 'DIV',
          label: 'Divider Line',
          role: 'Subtle Content Separator',
          l: lDivider,
          c: cDivider,
          color: colDivider,
          hex: oklchDivider.hexCode,
          formula: 'anchorL - 0.05 (c * 0.5)',
        ),
        LayerSpec(
          id: 'C4',
          label: 'Container 4',
          role: 'Dialog & Menu Surface',
          l: l4,
          c: c4,
          color: col4,
          hex: oklch4.hexCode,
          formula: 'anchorL + 0.010 (c * 0.85)',
        ),
        LayerSpec(
          id: 'TBF',
          label: 'Tonal Button Fill',
          role: 'Tonal Action Fill (C3 & C4)',
          l: lTbf,
          c: cTbf,
          color: colTbf,
          hex: oklchTbf.hexCode,
          formula: 'anchorL - 0.055 (L = ${lTbf.toStringAsFixed(3)})',
        ),
        LayerSpec(
          id: 'TBT',
          label: 'Tonal Button Text',
          role: 'Tonal Action Text',
          l: lText,
          c: cText,
          color: colTbt,
          hex: oklchTbt.hexCode,
          formula: 'textMain (L = 0.20)',
        ),
        LayerSpec(
          id: 'PRI',
          label: 'Primary Accent',
          role: 'Focus Border & Button',
          l: lPri,
          c: oklchP.c,
          color: colPrimary,
          hex: oklchPri.hexCode,
          formula: 'L: ${lPri.toStringAsFixed(3)}, C: ${oklchP.c.toStringAsFixed(3)}',
        ),
        LayerSpec(
          id: 'SUC',
          label: 'Success Status',
          role: 'Confirmations & Completed',
          l: lSuc,
          c: oklchSuc.c,
          color: colSuccess,
          hex: oklchSucDerived.hexCode,
          formula: 'L: ${lSuc.toStringAsFixed(3)}, C: ${oklchSuc.c.toStringAsFixed(3)}',
        ),
        LayerSpec(
          id: 'WAR',
          label: 'Warning Status',
          role: 'Cautions & Alerts',
          l: lWar,
          c: oklchWar.c,
          color: colWarning,
          hex: oklchWarDerived.hexCode,
          formula: 'L: ${lWar.toStringAsFixed(3)}, C: ${oklchWar.c.toStringAsFixed(3)}',
        ),
        LayerSpec(
          id: 'ERR',
          label: 'Error Status',
          role: 'Invalid Inputs & Hazards',
          l: lErr,
          c: oklchErr.c,
          color: colError,
          hex: oklchErrDerived.hexCode,
          formula: 'L: ${lErr.toStringAsFixed(3)}, C: ${oklchErr.c.toStringAsFixed(3)}',
        ),
        LayerSpec(
          id: 'INF',
          label: 'Info Status',
          role: 'Guidance & Notifications',
          l: lInf,
          c: oklchInf.c,
          color: colInfo,
          hex: oklchInfDerived.hexCode,
          formula: 'L: ${lInf.toStringAsFixed(3)}, C: ${oklchInf.c.toStringAsFixed(3)}',
        ),
        LayerSpec(
          id: 'TDB',
          label: 'Disabled Border',
          role: 'Faint Edge Boundary',
          l: lText,
          c: cText,
          color: colTfDisabledBorder,
          hex: ColorUtils.toHex(colTfDisabledBorder),
          formula: 'textMain alpha 0.08',
        ),
        LayerSpec(
          id: 'TDT',
          label: 'Disabled Text/Icon',
          role: 'WCAG Inactive Level',
          l: lText,
          c: cText,
          color: colTextDisabled,
          hex: ColorUtils.toHex(colTextDisabled),
          formula: 'textMain alpha 0.38',
        ),
      ];

      return LayerPalette(
        container1: col1,
        container2: col2,
        container3: col3,
        textFieldFill: colField,
        container4: col4,
        textMain: colText,
        tonalButtonFill: colTbf,
        tonalButtonText: colTbt,
        dividerLine: colDivider,
        textFieldBorder: colTfBorder,
        textFieldDisabledFill: colTfDisabledFill,
        textFieldDisabledBorder: colTfDisabledBorder,
        textDisabled: colTextDisabled,
        primary: colPrimary,
        onPrimary: colOnPrimary,
        success: colSuccess,
        onSuccess: colOnSuccess,
        warning: colWarning,
        onWarning: colOnWarning,
        error: colError,
        onError: colOnError,
        info: colInfo,
        onInfo: colOnInfo,
        anchorL: anchorL,
        chroma: c,
        hue: h,
        isDark: false,
        specs: specs,
      );
    } else {
      // ----------------- Dark Mode Formulas -----------------
      // container1: anchorL - (effectiveC2Delta * 2.5) (paling gelap), chroma: c * 0.82
      final l1 = (anchorL - effectiveC2Delta * 2.5).clamp(0.0, 1.0);
      final c1 = c * 0.82;
      final oklch1 = OklchColor(l1, c1, h);

      // container2: anchorL - effectiveC2Delta (sangat dekat dengan C3), chroma: c * 0.94
      final l2 = (anchorL - effectiveC2Delta).clamp(0.0, 1.0);
      final c2 = c * 0.94;
      final oklch2 = OklchColor(l2, c2, h);

      // container3: anchorL, chroma: c (Primary Anchor)
      final l3 = anchorL.clamp(0.0, 1.0);
      final c3 = c;
      final oklch3 = OklchColor(l3, c3, h);

      // textFieldFill: anchorL - effectiveTroughDelta (cekung halus seimbang di atas C2, tidak terlalu gelap / tidak jatuh ke C1)
      final lField = (anchorL - effectiveTroughDelta).clamp(0.0, 1.0);
      final cField = c * 0.88;
      final oklchField = OklchColor(lField, cField, h);

      // container4: anchorL + 0.07 (Dialog, Context Menu & Popover Surface melayang di atas C3)
      final l4 = (anchorL + 0.07).clamp(0.0, 1.0);
      final c4 = c * 1.0;
      final oklch4 = OklchColor(l4, c4, h);

      // textMain: L = 0.93, chroma: 0.015
      final lText = 0.93;
      final cText = 0.015;
      final oklchText = OklchColor(lText, cText, h);

      // tonalButtonFill: (l4 + 0.065).clamp(0.0, 1.0)
      final lTbf = (l4 + 0.065).clamp(0.0, 1.0);
      final cTbf = c > 0.001 ? math.max(c * 1.3, 0.025) : 0.0;
      final oklchTbf = OklchColor(lTbf, cTbf, h);

      // tonalButtonText: textMain (CR > 5.5:1 terhadap TBF)
      final oklchTbt = oklchText;

      // 1. Divider Line: oklch(clamp(0.0, L_c3 + 0.05, 1.0) (C * 0.5) H)
      final lDivider = (anchorL + 0.05).clamp(0.0, 1.0);
      final cDivider = c * 0.5;
      final oklchDivider = OklchColor(lDivider, cDivider, h);

      // 2. Border TextField (Default/Unfocused): oklch(clamp(0.0, L_c3 + 0.08, 1.0) 0.02 H)
      final lTfBorder = (anchorL + 0.08).clamp(0.0, 1.0);
      const cTfBorder = 0.02;
      final oklchTfBorder = OklchColor(lTfBorder, cTfBorder, h);

      // Primary Color in Dark Mode: L diangkat agar berpendar jelas dan mudah dibaca di atas permukaan gelap
      final lPri = (oklchP.l < 0.55 ? (oklchP.l + 0.22) : oklchP.l).clamp(0.55, 0.78);
      final oklchPri = OklchColor(lPri, oklchP.c, oklchP.h);
      final colPrimary = oklchPri.toColor();
      final colOnPrimary = lPri > 0.62 ? const Color(0xFF090D16) : Colors.white;

      // Semantic Status Colors in Dark Mode
      final lSuc = (oklchSuc.l < 0.55 ? (oklchSuc.l + 0.22) : oklchSuc.l).clamp(0.55, 0.78);
      final oklchSucDerived = OklchColor(lSuc, oklchSuc.c, oklchSuc.h);
      final colSuccess = oklchSucDerived.toColor();
      final colOnSuccess = lSuc > 0.62 ? const Color(0xFF090D16) : Colors.white;

      final lWar = (oklchWar.l < 0.60 ? (oklchWar.l + 0.18) : oklchWar.l).clamp(0.60, 0.82);
      final oklchWarDerived = OklchColor(lWar, oklchWar.c, oklchWar.h);
      final colWarning = oklchWarDerived.toColor();
      final colOnWarning = lWar > 0.62 ? const Color(0xFF090D16) : Colors.white;

      final lErr = (oklchErr.l < 0.55 ? (oklchErr.l + 0.22) : oklchErr.l).clamp(0.55, 0.78);
      final oklchErrDerived = OklchColor(lErr, oklchErr.c, oklchErr.h);
      final colError = oklchErrDerived.toColor();
      final colOnError = lErr > 0.62 ? const Color(0xFF090D16) : Colors.white;

      final lInf = (oklchInf.l < 0.55 ? (oklchInf.l + 0.22) : oklchInf.l).clamp(0.55, 0.78);
      final oklchInfDerived = OklchColor(lInf, oklchInf.c, oklchInf.h);
      final colInfo = oklchInfDerived.toColor();
      final colOnInfo = lInf > 0.62 ? const Color(0xFF090D16) : Colors.white;

      final col1 = oklch1.toColor();
      final col2 = oklch2.toColor();
      final col3 = oklch3.toColor();
      final colField = oklchField.toColor();
      final col4 = oklch4.toColor();
      final colText = oklchText.toColor();
      final colTbf = oklchTbf.toColor();
      final colTbt = oklchTbt.toColor();
      final colDivider = oklchDivider.toColor();
      final colTfBorder = oklchTfBorder.toColor();

      // 3. Disabled TextField Fill: Disamakan persis dengan Container 3 (L = L_c3, C, H)
      final colTfDisabledFill = col3;

      // 4. Disabled Border: textMain dengan alpha 0.08
      final colTfDisabledBorder = colText.withValues(alpha: 0.08);

      // 5. Disabled Text / Icon: textMain dengan alpha 0.38
      final colTextDisabled = colText.withValues(alpha: 0.38);

      final specs = [
        LayerSpec(
          id: 'C1',
          label: 'Container 1',
          role: 'Canvas Background',
          l: l1,
          c: c1,
          color: col1,
          hex: oklch1.hexCode,
          formula:
              'anchorL - ${(effectiveC2Delta * 2.5).toStringAsFixed(3)} (c * 0.82)',
        ),
        LayerSpec(
          id: 'C2',
          label: 'Container 2',
          role: 'Card Wrapper',
          l: l2,
          c: c2,
          color: col2,
          hex: oklch2.hexCode,
          formula:
              'anchorL - ${effectiveC2Delta.toStringAsFixed(3)} (c * 0.94)',
        ),
        LayerSpec(
          id: 'C3',
          label: 'Container 3',
          role: 'Anchor Surface',
          l: l3,
          c: c3,
          color: col3,
          hex: oklch3.hexCode,
          formula: 'anchorL (c * 1.0)',
        ),
        LayerSpec(
          id: 'TF',
          label: 'TextField Fill',
          role: 'Soft Sunken Trough',
          l: lField,
          c: cField,
          color: colField,
          hex: oklchField.hexCode,
          formula:
              'anchorL - ${effectiveTroughDelta.toStringAsFixed(3)} (c * 0.88)',
        ),
        LayerSpec(
          id: 'TFB',
          label: 'TF Border',
          role: 'Default Unfocused Outline',
          l: lTfBorder,
          c: cTfBorder,
          color: colTfBorder,
          hex: oklchTfBorder.hexCode,
          formula: 'anchorL + 0.08 (c = 0.02)',
        ),
        LayerSpec(
          id: 'TFD',
          label: 'Disabled TF Fill',
          role: 'Flat with C3 (no trough)',
          l: l3,
          c: c3,
          color: colTfDisabledFill,
          hex: oklch3.hexCode,
          formula: 'L = anchorL, C = c (= C3)',
        ),
        LayerSpec(
          id: 'DIV',
          label: 'Divider Line',
          role: 'Subtle Content Separator',
          l: lDivider,
          c: cDivider,
          color: colDivider,
          hex: oklchDivider.hexCode,
          formula: 'anchorL + 0.05 (c * 0.5)',
        ),
        LayerSpec(
          id: 'C4',
          label: 'Container 4',
          role: 'Dialog & Menu Surface',
          l: l4,
          c: c4,
          color: col4,
          hex: oklch4.hexCode,
          formula: 'anchorL + 0.07 (c * 1.0)',
        ),
        LayerSpec(
          id: 'TBF',
          label: 'Tonal Button Fill',
          role: 'Tonal Action Fill (C3 & C4)',
          l: lTbf,
          c: cTbf,
          color: colTbf,
          hex: oklchTbf.hexCode,
          formula: 'C4 + 0.065 (L = ${lTbf.toStringAsFixed(3)})',
        ),
        LayerSpec(
          id: 'TBT',
          label: 'Tonal Button Text',
          role: 'Tonal Action Text',
          l: lText,
          c: cText,
          color: colTbt,
          hex: oklchTbt.hexCode,
          formula: 'textMain (L = 0.93)',
        ),
        LayerSpec(
          id: 'PRI',
          label: 'Primary Accent',
          role: 'Focus Border & Button',
          l: lPri,
          c: oklchP.c,
          color: colPrimary,
          hex: oklchPri.hexCode,
          formula: 'L: ${lPri.toStringAsFixed(3)}, C: ${oklchP.c.toStringAsFixed(3)}',
        ),
        LayerSpec(
          id: 'SUC',
          label: 'Success Status',
          role: 'Confirmations & Completed',
          l: lSuc,
          c: oklchSuc.c,
          color: colSuccess,
          hex: oklchSucDerived.hexCode,
          formula: 'L: ${lSuc.toStringAsFixed(3)}, C: ${oklchSuc.c.toStringAsFixed(3)}',
        ),
        LayerSpec(
          id: 'WAR',
          label: 'Warning Status',
          role: 'Cautions & Alerts',
          l: lWar,
          c: oklchWar.c,
          color: colWarning,
          hex: oklchWarDerived.hexCode,
          formula: 'L: ${lWar.toStringAsFixed(3)}, C: ${oklchWar.c.toStringAsFixed(3)}',
        ),
        LayerSpec(
          id: 'ERR',
          label: 'Error Status',
          role: 'Invalid Inputs & Hazards',
          l: lErr,
          c: oklchErr.c,
          color: colError,
          hex: oklchErrDerived.hexCode,
          formula: 'L: ${lErr.toStringAsFixed(3)}, C: ${oklchErr.c.toStringAsFixed(3)}',
        ),
        LayerSpec(
          id: 'INF',
          label: 'Info Status',
          role: 'Guidance & Notifications',
          l: lInf,
          c: oklchInf.c,
          color: colInfo,
          hex: oklchInfDerived.hexCode,
          formula: 'L: ${lInf.toStringAsFixed(3)}, C: ${oklchInf.c.toStringAsFixed(3)}',
        ),
        LayerSpec(
          id: 'TDB',
          label: 'Disabled Border',
          role: 'Faint Edge Boundary',
          l: lText,
          c: cText,
          color: colTfDisabledBorder,
          hex: ColorUtils.toHex(colTfDisabledBorder),
          formula: 'textMain alpha 0.08',
        ),
        LayerSpec(
          id: 'TDT',
          label: 'Disabled Text/Icon',
          role: 'WCAG Inactive Level',
          l: lText,
          c: cText,
          color: colTextDisabled,
          hex: ColorUtils.toHex(colTextDisabled),
          formula: 'textMain alpha 0.38',
        ),
      ];

      return LayerPalette(
        container1: col1,
        container2: col2,
        container3: col3,
        textFieldFill: colField,
        container4: col4,
        textMain: colText,
        tonalButtonFill: colTbf,
        tonalButtonText: colTbt,
        dividerLine: colDivider,
        textFieldBorder: colTfBorder,
        textFieldDisabledFill: colTfDisabledFill,
        textFieldDisabledBorder: colTfDisabledBorder,
        textDisabled: colTextDisabled,
        primary: colPrimary,
        onPrimary: colOnPrimary,
        success: colSuccess,
        onSuccess: colOnSuccess,
        warning: colWarning,
        onWarning: colOnWarning,
        error: colError,
        onError: colOnError,
        info: colInfo,
        onInfo: colOnInfo,
        anchorL: anchorL,
        chroma: c,
        hue: h,
        isDark: true,
        specs: specs,
      );
    }
  }

  @override
  LayerPalette copyWith({
    Color? container1,
    Color? container2,
    Color? container3,
    Color? textFieldFill,
    Color? container4,
    Color? textMain,
    Color? tonalButtonFill,
    Color? tonalButtonText,
    Color? dividerLine,
    Color? textFieldBorder,
    Color? textFieldDisabledFill,
    Color? textFieldDisabledBorder,
    Color? textDisabled,
    Color? primary,
    Color? onPrimary,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? error,
    Color? onError,
    Color? info,
    Color? onInfo,
    double? anchorL,
    double? chroma,
    double? hue,
    bool? isDark,
    List<LayerSpec>? specs,
  }) {
    return LayerPalette(
      container1: container1 ?? this.container1,
      container2: container2 ?? this.container2,
      container3: container3 ?? this.container3,
      textFieldFill: textFieldFill ?? this.textFieldFill,
      container4: container4 ?? this.container4,
      textMain: textMain ?? this.textMain,
      tonalButtonFill: tonalButtonFill ?? this.tonalButtonFill,
      tonalButtonText: tonalButtonText ?? this.tonalButtonText,
      dividerLine: dividerLine ?? this.dividerLine,
      textFieldBorder: textFieldBorder ?? this.textFieldBorder,
      textFieldDisabledFill:
          textFieldDisabledFill ?? this.textFieldDisabledFill,
      textFieldDisabledBorder:
          textFieldDisabledBorder ?? this.textFieldDisabledBorder,
      textDisabled: textDisabled ?? this.textDisabled,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      anchorL: anchorL ?? this.anchorL,
      chroma: chroma ?? this.chroma,
      hue: hue ?? this.hue,
      isDark: isDark ?? this.isDark,
      specs: specs ?? this.specs,
    );
  }

  @override
  LayerPalette lerp(ThemeExtension<LayerPalette>? other, double t) {
    if (other is! LayerPalette) return this;
    return LayerPalette(
      container1: Color.lerp(container1, other.container1, t) ?? container1,
      container2: Color.lerp(container2, other.container2, t) ?? container2,
      container3: Color.lerp(container3, other.container3, t) ?? container3,
      textFieldFill:
          Color.lerp(textFieldFill, other.textFieldFill, t) ?? textFieldFill,
      container4: Color.lerp(container4, other.container4, t) ?? container4,
      textMain: Color.lerp(textMain, other.textMain, t) ?? textMain,
      tonalButtonFill:
          Color.lerp(tonalButtonFill, other.tonalButtonFill, t) ??
          tonalButtonFill,
      tonalButtonText:
          Color.lerp(tonalButtonText, other.tonalButtonText, t) ??
          tonalButtonText,
      dividerLine: Color.lerp(dividerLine, other.dividerLine, t) ?? dividerLine,
      textFieldBorder:
          Color.lerp(textFieldBorder, other.textFieldBorder, t) ??
          textFieldBorder,
      textFieldDisabledFill:
          Color.lerp(textFieldDisabledFill, other.textFieldDisabledFill, t) ??
          textFieldDisabledFill,
      textFieldDisabledBorder:
          Color.lerp(
            textFieldDisabledBorder,
            other.textFieldDisabledBorder,
            t,
          ) ??
          textFieldDisabledBorder,
      textDisabled:
          Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      error: Color.lerp(error, other.error, t) ?? error,
      onError: Color.lerp(onError, other.onError, t) ?? onError,
      info: Color.lerp(info, other.info, t) ?? info,
      onInfo: Color.lerp(onInfo, other.onInfo, t) ?? onInfo,
      anchorL: anchorL + (other.anchorL - anchorL) * t,
      chroma: chroma + (other.chroma - chroma) * t,
      hue: hue + (other.hue - hue) * t,
      isDark: t < 0.5 ? isDark : other.isDark,
      specs: t < 0.5 ? specs : other.specs,
    );
  }

  /// Converts this [LayerPalette] into a complete, standard Flutter [ThemeData].
  ///
  /// Automatically overrides and standardizes:
  /// - [scaffoldBackgroundColor] -> container1 (C1)
  /// - [cardTheme] -> container3 (C3)
  /// - [inputDecorationTheme] -> textFieldFill (TF), textFieldBorder (TFB), textFieldDisabledBorder, errorBorder, focusedErrorBorder
  /// - [dividerTheme] -> dividerLine (DIV)
  /// - [dialogTheme] & [popupMenuTheme] -> container4 (C4)
  /// - [colorScheme] -> Material 3 color mapping matching OKLCH depth tiers & status colors
  /// - [textTheme] -> textMain typography hierarchy
  /// - [extensions] -> [this] for explicit token access
  ThemeData toThemeData() {
    final baseColorScheme = isDark
        ? const ColorScheme.dark()
        : const ColorScheme.light();

    final colorScheme = baseColorScheme.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      error: error,
      onError: onError,
      surface: container3,
      onSurface: textMain,
      onSurfaceVariant: textMain.withValues(alpha: 0.72),
      surfaceContainerLowest: container1,
      surfaceContainerLow: container1,
      surfaceContainer: container2,
      surfaceContainerHigh: container3,
      surfaceContainerHighest: container4,
      outline: textFieldBorder,
      outlineVariant: dividerLine,
      secondaryContainer: tonalButtonFill,
      onSecondaryContainer: tonalButtonText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: container1,

      // Text Theme mapping
      textTheme: TextTheme(
        headlineMedium: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: textMain, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textMain.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textMain),
        bodyMedium: TextStyle(color: textMain),
        bodySmall: TextStyle(color: textMain.withValues(alpha: 0.72)),
        labelLarge: TextStyle(color: textMain, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(color: textMain.withValues(alpha: 0.75)),
        labelSmall: TextStyle(color: textMain.withValues(alpha: 0.55)),
      ),

      // Input Decoration (TextFields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: textFieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textFieldBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primary,
            width: 1.8,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textFieldDisabledBorder, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 1.8),
        ),
        errorStyle: TextStyle(
          color: error,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: textMain.withValues(alpha: 0.45)),
        labelStyle: TextStyle(color: textMain.withValues(alpha: 0.75)),
      ),

      // Button Themes (Primary Action)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: dividerLine,
        thickness: 1.0,
        space: 1.0,
      ),

      // Dialog Theme (Container 4)
      dialogTheme: DialogThemeData(
        backgroundColor: container4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : textMain.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
      ),

      // Popup Menu & Menu Theme (Container 4)
      popupMenuTheme: PopupMenuThemeData(
        color: container4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : textMain.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
      ),

      // Card Theme (Container 3)
      cardTheme: CardThemeData(
        color: container3,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : textMain.withValues(alpha: 0.04),
          ),
        ),
      ),

      // Extensions
      extensions: [this],
    );
  }
}

/// Main Application Entry Point
class OklchPaletteDemoApp extends StatefulWidget {
  const OklchPaletteDemoApp({super.key});

  @override
  State<OklchPaletteDemoApp> createState() => _OklchPaletteDemoAppState();
}

enum ColorPickerTarget {
  lightAnchor,
  darkAnchor,
  primary,
  success,
  warning,
  error,
  info,
}

class _OklchPaletteDemoAppState extends State<OklchPaletteDemoApp> {
  // Configurable OKLCH anchor parameters for LIGHT MODE
  // Defaults to #F4F5F7 (Cool Neutral Slate Light)
  double _lightAnchorL = 0.970;
  double _lightChroma = 0.003;
  double _lightHue = 264.5;
  final double _lightC2Delta = 0.018; // Rapat & harmonis dengan C3
  final double _lightTroughDelta = 0.030;
  Color _lightAnchorColor = const Color(0xFFF4F5F7);

  // Configurable OKLCH anchor parameters for DARK MODE
  // Defaults to #101010 (True Neutral Dark Anchor)
  static const _defaultDark = Color(0xFF181818);
  static final _darkOklch = OklchColor.fromColor(_defaultDark);

  double _darkAnchorL = _darkOklch.l;
  double _darkChroma = _darkOklch.c;
  double _darkHue = _darkOklch.h;
  final double _darkC2Delta = 0.022;
  final double _darkTroughDelta = 0.018;
  Color _darkAnchorColor = _defaultDark;

  Color _primaryColor = const Color(0xFF2563EB);
  Color _successColor = const Color(0xFF10B981);
  Color _warningColor = const Color(0xFFF59E0B);
  Color _errorColor = const Color(0xFFEF4444);
  Color _infoColor = const Color(0xFF06B6D4);

  bool _showControls = true;

  void _updateColorFromPicker(
    Color newColor, {
    required ColorPickerTarget target,
  }) {
    setState(() {
      switch (target) {
        case ColorPickerTarget.primary:
          _primaryColor = newColor;
          break;
        case ColorPickerTarget.success:
          _successColor = newColor;
          break;
        case ColorPickerTarget.warning:
          _warningColor = newColor;
          break;
        case ColorPickerTarget.error:
          _errorColor = newColor;
          break;
        case ColorPickerTarget.info:
          _infoColor = newColor;
          break;
        case ColorPickerTarget.lightAnchor:
          _lightAnchorColor = newColor;
          final oklch = OklchColor.fromColor(newColor);
          _lightHue = oklch.h;
          _lightChroma = oklch.c.clamp(0.0, 0.15);
          _lightAnchorL = oklch.l.clamp(0.80, 0.98);
          break;
        case ColorPickerTarget.darkAnchor:
          _darkAnchorColor = newColor;
          final oklch = OklchColor.fromColor(newColor);
          _darkHue = oklch.h;
          _darkChroma = oklch.c.clamp(0.0, 0.15);
          _darkAnchorL = oklch.l.clamp(0.10, 0.40);
          break;
      }
    });
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _openColorPicker({
    required ColorPickerTarget target,
    BuildContext? context,
  }) {
    final targetContext = context ?? _navigatorKey.currentContext;
    if (targetContext == null) return;
    showDialog(
      context: targetContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentColor = switch (target) {
              ColorPickerTarget.lightAnchor => _lightAnchorColor,
              ColorPickerTarget.darkAnchor => _darkAnchorColor,
              ColorPickerTarget.primary => _primaryColor,
              ColorPickerTarget.success => _successColor,
              ColorPickerTarget.warning => _warningColor,
              ColorPickerTarget.error => _errorColor,
              ColorPickerTarget.info => _infoColor,
            };
            final currentOklch = OklchColor.fromColor(currentColor);

            final (title, description, accentColor) = switch (target) {
              ColorPickerTarget.lightAnchor => (
                'Light Mode Custom Anchor',
                'Pick a custom anchor color using NeoColorPicker. The OKLCH hue and chroma will dynamically anchor the light mode surfaces.',
                const Color(0xFFEF4444),
              ),
              ColorPickerTarget.darkAnchor => (
                'Dark Mode Custom Anchor',
                'Pick a custom anchor color using NeoColorPicker. The OKLCH hue and chroma will dynamically anchor the dark mode surfaces.',
                const Color(0xFFFBBF24),
              ),
              ColorPickerTarget.primary => (
                'Primary Brand Color',
                'Pick a primary brand color using NeoColorPicker. It will dynamically adapt in OKLCH for focus borders, primary buttons, and active indicators in both Light & Dark modes.',
                _primaryColor,
              ),
              ColorPickerTarget.success => (
                'Success Semantic Color',
                'Pick a base color for success state. OKLCH derivations will generate accessible contrast and surface badges in Light & Dark modes.',
                _successColor,
              ),
              ColorPickerTarget.warning => (
                'Warning Semantic Color',
                'Pick a base color for warning state. OKLCH derivations ensure appropriate luminance and legibility for alerts.',
                _warningColor,
              ),
              ColorPickerTarget.error => (
                'Error Semantic Color',
                'Pick a base color for error state. Applied to TextField error borders, error labels, and alert banners.',
                _errorColor,
              ),
              ColorPickerTarget.info => (
                'Info Semantic Color',
                'Pick a base color for info state. OKLCH derivations ensure cohesive informative callouts and badges.',
                _infoColor,
              ),
            };

            return Dialog(
              backgroundColor: const Color(0xFF161B26),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF2E384D), width: 1.5),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: currentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: NeoColorPicker(
                            selectedColor: currentColor,
                            mode: NeoColorPickerMode.hsl,
                            enableAlpha: false,
                            onColorChanged: (newColor) {
                              _updateColorFromPicker(
                                newColor,
                                target: target,
                              );
                              setDialogState(() {});
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF222938),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'OKLCH: H ${currentOklch.h.round()}° • C ${currentOklch.c.toStringAsFixed(3)} • L ${currentOklch.l.toStringAsFixed(3)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton.icon(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Apply'),
                              style: FilledButton.styleFrom(
                                backgroundColor: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate Light and Dark LayerPalettes dynamically with separated anchor parameters
    final lightPalette = LayerPalette.fromAnchor(
      anchorL: _lightAnchorL,
      c: _lightChroma,
      h: _lightHue,
      isDark: false,
      c2Delta: _lightC2Delta,
      troughDelta: _lightTroughDelta,
      primaryColor: _primaryColor,
      successColor: _successColor,
      warningColor: _warningColor,
      errorColor: _errorColor,
      infoColor: _infoColor,
    );

    final darkPalette = LayerPalette.fromAnchor(
      anchorL: _darkAnchorL,
      c: _darkChroma,
      h: _darkHue,
      isDark: true,
      c2Delta: _darkC2Delta,
      troughDelta: _darkTroughDelta,
      primaryColor: _primaryColor,
      successColor: _successColor,
      warningColor: _warningColor,
      errorColor: _errorColor,
      infoColor: _infoColor,
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'OKLCH Tiered Palette System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF0F1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181C26),
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF252D3D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF384357)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'OKLCH',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF1F5F9),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tiered Color Palette Architecture',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Independent Anchors (e.g. Light = #F4F5F7, Dark = #101010) • Semantic Status System',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: _showControls
                  ? 'Sembunyikan Panel Warna'
                  : 'Buka Panel Warna',
              icon: Icon(
                _showControls ? Icons.palette_rounded : Icons.palette_outlined,
                color: _showControls ? _primaryColor : Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Interactive Parameter Controls Bar
              AnimatedCrossFade(
                firstChild: _buildControlPanel(),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _showControls
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 240),
              ),

              // Main Side-by-Side Showcase Area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 840;

                    final lightThemeWidget = Theme(
                      data: lightPalette.toThemeData(),
                      child: StackPreviewCard(
                        modeTitle: 'LIGHT MODE',
                        isDark: false,
                        anchorColor: _lightAnchorColor,
                        onOpenColorPicker: () =>
                            _openColorPicker(target: ColorPickerTarget.lightAnchor),
                      ),
                    );

                    final darkThemeWidget = Theme(
                      data: darkPalette.toThemeData(),
                      child: StackPreviewCard(
                        modeTitle: 'DARK MODE',
                        isDark: true,
                        anchorColor: _darkAnchorColor,
                        onOpenColorPicker: () =>
                            _openColorPicker(target: ColorPickerTarget.darkAnchor),
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: lightThemeWidget),
                          Container(width: 1.5, color: const Color(0xFF262C3A)),
                          Expanded(child: darkThemeWidget),
                        ],
                      );
                    } else {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 740, child: lightThemeWidget),
                            Container(
                              height: 2,
                              color: const Color(0xFF262C3A),
                            ),
                            SizedBox(height: 740, child: darkThemeWidget),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Responsive configuration panel for Light anchor, Dark anchor, Primary Brand, and 4 Semantic Statuses.
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF131722),
        border: Border(
          bottom: BorderSide(color: Color(0xFF262C3A), width: 1.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;
          final isMedium = constraints.maxWidth >= 720;

          final lightCard = _buildColorPickerCard(
            title: 'Light Anchor Color',
            color: _lightAnchorColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.lightAnchor),
            indicatorColor: const Color(0xFFEF4444),
          );
          final darkCard = _buildColorPickerCard(
            title: 'Dark Anchor Color',
            color: _darkAnchorColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.darkAnchor),
            indicatorColor: const Color(0xFFFBBF24),
          );
          final primaryCard = _buildColorPickerCard(
            title: 'Primary Brand Color',
            color: _primaryColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.primary),
          );
          final successCard = _buildColorPickerCard(
            title: 'Success Status Color',
            color: _successColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.success),
          );
          final warningCard = _buildColorPickerCard(
            title: 'Warning Status Color',
            color: _warningColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.warning),
          );
          final errorCard = _buildColorPickerCard(
            title: 'Error Status Color',
            color: _errorColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.error),
          );
          final infoCard = _buildColorPickerCard(
            title: 'Info Status Color',
            color: _infoColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.info),
          );

          if (isWide) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: lightCard),
                    const SizedBox(width: 10),
                    Expanded(child: darkCard),
                    const SizedBox(width: 10),
                    Expanded(child: primaryCard),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: successCard),
                    const SizedBox(width: 10),
                    Expanded(child: warningCard),
                    const SizedBox(width: 10),
                    Expanded(child: errorCard),
                    const SizedBox(width: 10),
                    Expanded(child: infoCard),
                  ],
                ),
              ],
            );
          } else if (isMedium) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: lightCard),
                    const SizedBox(width: 10),
                    Expanded(child: darkCard),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: primaryCard),
                    const SizedBox(width: 10),
                    Expanded(child: successCard),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: warningCard),
                    const SizedBox(width: 10),
                    Expanded(child: errorCard),
                    const SizedBox(width: 10),
                    Expanded(child: infoCard),
                  ],
                ),
              ],
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                lightCard,
                const SizedBox(height: 8),
                darkCard,
                const SizedBox(height: 8),
                primaryCard,
                const SizedBox(height: 8),
                successCard,
                const SizedBox(height: 8),
                warningCard,
                const SizedBox(height: 8),
                errorCard,
                const SizedBox(height: 8),
                infoCard,
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildColorPickerCard({
    required String title,
    required Color color,
    required VoidCallback onTap,
    Color? indicatorColor,
  }) {
    final hex = ColorUtils.toHex(color);
    final oklch = OklchColor.fromColor(color);
    final dotColor = indicatorColor ?? color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF181E2B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Color Swatch with border & glow
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: oklch.l > 0.6 ? Colors.black26 : Colors.white38,
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.colorize_rounded,
                    size: 14,
                    color: oklch.l > 0.6 ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Title and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF1F5F9),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Hex: $hex • L ${oklch.l.toStringAsFixed(2)} • C ${oklch.c.toStringAsFixed(2)} • H ${oklch.h.round()}°',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Button "Pilih Warna"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF222B3D),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: color.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 12,
                      color: dotColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pilih Warna',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: dotColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable Side-by-Side Preview Card widget.
///
/// Fully consumes [LayerPalette] via `Theme.of(context).extension<LayerPalette>()!`.
class StackPreviewCard extends StatelessWidget {
  final String modeTitle;
  final bool isDark;
  final Color anchorColor;
  final VoidCallback? onOpenColorPicker;

  const StackPreviewCard({
    super.key,
    required this.modeTitle,
    required this.isDark,
    required this.anchorColor,
    this.onOpenColorPicker,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<LayerPalette>()!;

    return Container(
      color: palette.container1, // Background utama kanvas (C1)
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Bar for the Column
          _buildModeHeader(context, palette),
          const SizedBox(height: 18),

          // Layer 2: Card Penampung Lapis Kedua (container2)
          Container(
            decoration: BoxDecoration(
              color: palette.container2,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.40)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Layer 2 Label & Badge
                Row(
                  children: [
                    _buildLayerIndicator(
                      label: 'CONTAINER 2',
                      sub: 'Lapis Kedua (Card Wrapper)',
                      color: palette.container2,
                      textColor: palette.textMain,
                      isDark: isDark,
                    ),
                    const Spacer(),
                    _buildMathBadge(
                      title: 'L = ${palette.specs[1].l.toStringAsFixed(2)}',
                      subtitle: palette.specs[1].hex,
                      textColor: palette.textMain,
                      isDark: isDark,
                      primaryColor: palette.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Layer 3: Permukaan Acuan Utama (container3) - The Anchor!
                Container(
                  decoration: BoxDecoration(
                    color: palette.container3,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: palette.primary.withValues(
                        alpha: isDark ? 0.35 : 0.22,
                      ),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Layer 3 Anchor Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: palette.primary.withValues(
                                alpha: isDark ? 0.25 : 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.anchor_rounded,
                              size: 20,
                              color: palette.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Container 3 (Primary Anchor)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: palette.textMain,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Permukaan acuan utama lapis ketiga. Seluruh layer lain dihitung relatif terhadap anchorL ini.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: palette.textMain.withValues(
                                      alpha: 0.72,
                                    ),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildMathBadge(
                            title:
                                'ANCHOR L = ${palette.anchorL.toStringAsFixed(2)}',
                            subtitle: palette.specs[2].hex,
                            textColor: palette.textMain,
                            isDark: isDark,
                            primaryColor: palette.primary,
                            highlight: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Layer: Sunken TextField (textFieldFill)
                      Text(
                        'TEXT FIELD WITH SUNKEN TROUGH EFFECT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: palette.textMain.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        style: TextStyle(color: palette.textMain, fontSize: 14),
                        cursorColor: palette.textMain,
                        decoration: InputDecoration(
                          hintText: isDark
                              ? 'Efek Cekung Dark Mode (lembut & nyaman, tidak terlalu gelap)'
                              : 'Efek Cekung Light Mode (lebih gelap dari C3)',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: palette.textMain.withValues(alpha: 0.50),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: palette.textMain.withValues(alpha: 0.60),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: palette.container3.withValues(
                                  alpha: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'L: ${palette.specs[3].l.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: palette.textMain,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: palette.textFieldFill,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          // Border fisik tipis 1px penegas cekung (Default/Unfocused)
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: palette.textFieldBorder,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: palette.textFieldBorder,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: palette.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isDark
                            ? 'Rumus Cekung: ${palette.specs[3].formula} • Border: ${palette.specs[4].formula}'
                            : 'Rumus Cekung: ${palette.specs[3].formula} • Border: ${palette.specs[4].formula}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          color: palette.textMain.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 1. Divider Line (Garis pemisah tipis dengan kontras rendah)
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: palette.dividerLine,
                              thickness: 1.0,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'DIVIDER LINE',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: palette.textMain.withValues(alpha: 0.45),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: palette.dividerLine,
                              thickness: 1.0,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3, 4, 5. Disabled TextField (Rata dengan C3, tanpa cekung)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'DISABLED TEXT FIELD (FLAT SURFACE)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: palette.textMain.withValues(alpha: 0.65),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: palette.textDisabled.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: palette.textFieldDisabledBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'NON-INTERACTIVE',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: palette.textDisabled,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        enabled: false,
                        style: TextStyle(
                          color: palette.textDisabled,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Disabled TextField (isian rata = C3, tanpa efek cekung)',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: palette.textDisabled,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: palette.textDisabled,
                            size: 20,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: palette.textDisabled.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'L: ${palette.specs[2].l.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: palette.textDisabled,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: palette.textFieldDisabledFill,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          // Disabled Border: textMain dengan alpha 0.08
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: palette.textFieldDisabledBorder,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Isian: Sama persis C3 (efek cekung hilang/rata) • Border: textMain 0.08a • Teks: WCAG 0.38a',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          color: palette.textMain.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider Line
                      Divider(
                        color: palette.dividerLine,
                        thickness: 1.0,
                        height: 1,
                      ),
                      const SizedBox(height: 16),

                      // PRIMARY ACTION & FOCUS BORDER SHOWCASE
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRIMARY BRAND ACTION & FOCUS BORDER',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: palette.textMain.withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Warna brand primary terkalibrasi OKLCH dengan kontras otomatis.',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: palette.textMain.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildMathBadge(
                            title:
                                'PRI L = ${palette.specs.firstWhere((s) => s.id == 'PRI').l.toStringAsFixed(3)}',
                            subtitle:
                                palette.specs.firstWhere((s) => s.id == 'PRI').hex,
                            textColor: palette.textMain,
                            isDark: isDark,
                            primaryColor: palette.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.bolt_rounded, size: 16),
                            label: const Text('Primary Button'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.primary,
                              foregroundColor: palette.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              elevation: 0,
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.primary.withValues(
                                alpha: isDark ? 0.22 : 0.14,
                              ),
                              foregroundColor: palette.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                            child: const Text('Tonal Accent'),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: palette.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: palette.primary.withValues(alpha: 0.40),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: palette.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Focused Border: 1.5px',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: palette.textMain,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Divider Line
                      Divider(
                        color: palette.dividerLine,
                        thickness: 1.0,
                        height: 1,
                      ),
                      const SizedBox(height: 16),

                      // ERROR TEXT FIELD (VALIDATION STATE) SHOWCASE
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ERROR TEXT FIELD (VALIDATION STATE)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: palette.textMain.withValues(alpha: 0.65),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Border error, label error, dan suffix icon tersinkron dengan token palette.error.',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: palette.textMain.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildMathBadge(
                            title:
                                'ERR L = ${palette.specs.firstWhere((s) => s.id == 'ERR').l.toStringAsFixed(3)}',
                            subtitle:
                                palette.specs.firstWhere((s) => s.id == 'ERR').hex,
                            textColor: palette.textMain,
                            isDark: isDark,
                            primaryColor: palette.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        style: TextStyle(
                          color: palette.textMain,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'user@example.com',
                          errorText: 'Format alamat email tidak valid',
                          prefixIcon: Icon(
                            Icons.alternate_email_rounded,
                            color: palette.textMain.withValues(alpha: 0.60),
                            size: 20,
                          ),
                          suffixIcon: Icon(
                            Icons.error_outline_rounded,
                            color: palette.error,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider Line
                      Divider(
                        color: palette.dividerLine,
                        thickness: 1.0,
                        height: 1,
                      ),
                      const SizedBox(height: 16),

                      // SEMANTIC STATUS BADGES & ALERTS SHOWCASE
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SEMANTIC STATUS TOKENS & BADGES',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: palette.textMain.withValues(alpha: 0.65),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Derivasi OKLCH adaptif untuk status success, warning, error, dan info.',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: palette.textMain.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusChip(
                            icon: Icons.check_circle_rounded,
                            label: 'Success',
                            color: palette.success,
                            onColor: palette.onSuccess,
                            formula: palette.specs.firstWhere((s) => s.id == 'SUC').formula,
                          ),
                          _buildStatusChip(
                            icon: Icons.warning_rounded,
                            label: 'Warning',
                            color: palette.warning,
                            onColor: palette.onWarning,
                            formula: palette.specs.firstWhere((s) => s.id == 'WAR').formula,
                          ),
                          _buildStatusChip(
                            icon: Icons.cancel_rounded,
                            label: 'Error',
                            color: palette.error,
                            onColor: palette.onError,
                            formula: palette.specs.firstWhere((s) => s.id == 'ERR').formula,
                          ),
                          _buildStatusChip(
                            icon: Icons.info_rounded,
                            label: 'Info',
                            color: palette.info,
                            onColor: palette.onInfo,
                            formula: palette.specs.firstWhere((s) => s.id == 'INF').formula,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Divider Line
                      Divider(
                        color: palette.dividerLine,
                        thickness: 1.0,
                        height: 1,
                      ),
                      const SizedBox(height: 16),

                      // CONTAINER 4: DIALOG & CONTEXT MENU SURFACE
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CONTAINER 4: DIALOG & CONTEXT MENU SURFACE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: palette.textMain.withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Warna background melayang untuk Dialog, Context Menu, dan Popover.',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: palette.textMain.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildMathBadge(
                            title:
                                'C4 L = ${palette.specs.firstWhere((s) => s.id == 'C4').l.toStringAsFixed(3)}',
                            subtitle:
                                palette.specs.firstWhere((s) => s.id == 'C4').hex,
                            textColor: palette.textMain,
                            isDark: isDark,
                            primaryColor: palette.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Dialog Preview Trigger
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Uji tampilan modal dialog melayang:',
                              style: TextStyle(
                                fontSize: 11,
                                color: palette.textMain.withValues(alpha: 0.65),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _openDialogPreview(context, palette),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: palette.tonalButtonFill,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: palette.primary.withValues(
                                    alpha: isDark ? 0.35 : 0.25,
                                  ),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    size: 14,
                                    color: palette.tonalButtonText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Open Dialog Preview (C4)',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: palette.tonalButtonText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Inline Context Menu Mockup on Container 4
                      Container(
                        decoration: BoxDecoration(
                          color: palette.container4,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : palette.textMain.withValues(alpha: 0.08),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.45)
                                  : Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.menu_open_rounded,
                                  size: 16,
                                  color: palette.textMain.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Context Menu Mockup (C4)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: palette.textMain,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.textMain.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Popover',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: palette.textMain.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Menu items
                            _buildContextMenuItem(
                              icon: Icons.copy_rounded,
                              label: 'Duplicate Color Tokens',
                              shortcut: 'Ctrl+D',
                              palette: palette,
                            ),
                            const SizedBox(height: 4),
                            _buildContextMenuItem(
                              icon: Icons.palette_outlined,
                              label: 'Inspect OKLCH Gamut Boundary',
                              shortcut: 'Ctrl+G',
                              palette: palette,
                            ),
                            const SizedBox(height: 12),
                            // Tonal Buttons INSIDE Container 4 (proving contrast on C4!)
                            Text(
                              'Tonal Buttons on C4 surface:',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontStyle: FontStyle.italic,
                                color: palette.textMain.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                // Active Tonal Button (C4)
                                InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: palette.tonalButtonFill,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.06),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 13,
                                          color: palette.tonalButtonText,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Tonal Button (C4)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: palette.tonalButtonText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Disabled Tonal Button (C4)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.tonalButtonFill.withValues(
                                      alpha: 0.35,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: palette.textFieldDisabledBorder,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.block_rounded,
                                        size: 13,
                                        color: palette.textDisabled,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Disabled Button (C4)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: palette.textDisabled,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mathematical Depth Breakdown Table
          _buildDepthHierarchyTable(context, palette),
        ],
      ),
    );
  }

  Widget _buildModeHeader(BuildContext context, LayerPalette palette) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                modeTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: palette.textMain,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                isDark
                    ? 'Permukaan bertingkat cerah ke atas (C1 < C2 < C3 < C4)'
                    : 'Permukaan bertingkat bayangan ke dalam (C1 > C2 > C3 > Trough)',
                style: TextStyle(
                  fontSize: 11,
                  color: palette.textMain.withValues(alpha: 0.65),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onOpenColorPicker,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: palette.container2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: palette.textMain.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: anchorColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white70 : Colors.black45,
                      width: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Custom Anchor',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: palette.textMain,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.colorize_rounded,
                  size: 13,
                  color: palette.textMain.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: palette.container2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: palette.textMain.withValues(alpha: 0.12)),
          ),
          child: Text(
            'C1 Canvas: ${palette.specs[0].hex}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: palette.textMain,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLayerIndicator({
    required String label,
    required String sub,
    required Color color,
    required Color textColor,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.black26,
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                fontSize: 10,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMathBadge({
    required String title,
    required String subtitle,
    required Color textColor,
    required bool isDark,
    required Color primaryColor,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight
            ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.15)
            : (isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight
              ? primaryColor.withValues(alpha: isDark ? 0.70 : 0.45)
              : textColor.withValues(alpha: 0.15),
          width: highlight ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: highlight ? primaryColor : textColor,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              color: textColor.withValues(alpha: 0.6),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color onColor,
    required String formula,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              formula,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: onColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepthHierarchyTable(BuildContext context, LayerPalette palette) {
    return Container(
      decoration: BoxDecoration(
        color: palette.container2.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.textMain.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 16,
                color: palette.textMain.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                'LAYER DEPTH SPECTRUM (OKLCH FORMULAS)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: palette.textMain.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...palette.specs.map((spec) {
            final isAnchor = spec.id == 'C3';
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isAnchor
                    ? palette.primary.withValues(alpha: isDark ? 0.20 : 0.10)
                    : palette.container1.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAnchor
                      ? palette.primary.withValues(alpha: isDark ? 0.70 : 0.50)
                      : palette.textMain.withValues(alpha: 0.06),
                  width: isAnchor ? 1.2 : 0.8,
                ),
              ),
              child: Row(
                children: [
                  // Color Swatch
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: spec.color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black26,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tag & Name
                  SizedBox(
                    width: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              spec.id,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isAnchor
                                    ? palette.primary
                                    : palette.textMain,
                              ),
                            ),
                            if (isAnchor) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ANCHOR',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: palette.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          spec.role,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: palette.textMain.withValues(alpha: 0.65),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Formula
                  Expanded(
                    child: Text(
                      spec.formula,
                      style: TextStyle(
                        fontSize: 10,
                        color: palette.textMain.withValues(alpha: 0.75),
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Metrics (L and Hex)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'L: ${spec.l.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: palette.textMain,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        spec.hex,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: palette.textMain.withValues(alpha: 0.55),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContextMenuItem({
    required IconData icon,
    required String label,
    required String shortcut,
    required LayerPalette palette,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: palette.textMain.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: palette.textMain.withValues(alpha: 0.75)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: palette.textMain,
              ),
            ),
          ),
          Text(
            shortcut,
            style: TextStyle(
              fontSize: 10,
              color: palette.textMain.withValues(alpha: 0.45),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  void _openDialogPreview(BuildContext context, LayerPalette palette) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: palette.container4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : palette.textMain.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          elevation: isDark ? 16 : 4,
          shadowColor: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: palette.tonalButtonFill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.layers_rounded,
                        size: 20,
                        color: palette.tonalButtonText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dialog Surface (Container 4)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: palette.textMain,
                            ),
                          ),
                          Text(
                            'Background: C4 • L = ${palette.specs.firstWhere((s) => s.id == 'C4').l.toStringAsFixed(3)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.textMain.withValues(alpha: 0.65),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Ini adalah modal dialog yang menggunakan Container 4 sebagai surface background. Di bawah ini terdapat Tonal Button yang dirancang agar tetap kontras dan terbaca jelas baik di atas Container 4 maupun Container 3.',
                  style: TextStyle(
                    fontSize: 13,
                    color: palette.textMain.withValues(alpha: 0.80),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Tonal Button on Container 4
                    InkWell(
                      onTap: () => Navigator.of(dialogCtx).pop(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: palette.tonalButtonFill,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16,
                              color: palette.tonalButtonText,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tonal Button (C4)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: palette.tonalButtonText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Primary Confirm Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: palette.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

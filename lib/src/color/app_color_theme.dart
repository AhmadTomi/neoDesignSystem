import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'layer_spec.dart';
import 'oklch_color.dart';

/// Custom [ThemeExtension] implementing a tiered color system anchored at Container 3.
class AppColorTheme extends ThemeExtension<AppColorTheme> {
  /// Background utama kanvas (C1)
  final Color container1;

  /// Card penampung lapis kedua (C2)
  final Color container2;

  /// Permukaan acuan utama lapis ketiga (Anchor - C3)
  final Color container3;

  /// Warna isian TextField dengan efek cekung/trough (TF)
  final Color textFieldFill;

  /// Lapis teratas mengambang (Dialog, Context Menu, dan Popover Surface - C4)
  final Color container4;

  /// Warna teks berdaya kontras tinggi (High Emphasis - 100%)
  final Color textMain;

  /// Warna isian Tonal Button (kontras & harmonis di atas Container 3 dan Container 4 - TBF)
  final Color tonalButtonFill;

  /// Warna teks/ikon Tonal Button berdaya kontras tinggi (TBT)
  final Color tonalButtonText;

  /// Garis pemisah tipis dengan kontras rendah (DIV)
  final Color dividerLine;

  /// Garis tepi fisik tipis (1px) untuk menegaskan lekukan cekung sebelum elemen disentuh (TFB)
  final Color textFieldBorder;

  /// Warna isian TextField nonaktif (disamakan persis dengan Container 3 agar efek cekung hilang)
  final Color textFieldDisabledFill;

  /// Garis tepi sangat redup agar batas fisik tetap ada secara samar (8% alpha)
  final Color textFieldDisabledBorder;

  /// Standar kontras WCAG untuk menandakan status teks/ikon non-interaktif (38% alpha)
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

  const AppColorTheme({
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

  // --- GETTERS WARNA REDUP SEMANTIK (Single Source of Truth: textMain) ---
  /// Redup Sedang (72% alpha) - Subtitle, deskripsi, caption penting
  Color get textSecondary => textMain.withValues(alpha: 0.72);

  /// Redup Kuat / Muted (50% alpha) - Placeholder, footnote, jam/tanggal pudar
  Color get textMuted => textMain.withValues(alpha: 0.50);

  /// Garis redup samar (8% alpha) - Hairline border, disabled outline
  Color get subtleBorder => textMain.withValues(alpha: 0.08);

  /// Factory constructor that calculates tiered colors from a standard Flutter [Color].
  factory AppColorTheme.fromColor({
    required Color anchorColor,
    required bool isDark,
    Color? primaryColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? infoColor,
    double? c2Delta,
    double? troughDelta,
  }) {
    final oklch = OklchColor.fromColor(anchorColor);
    return AppColorTheme.fromAnchor(
      anchorL: isDark ? oklch.l.clamp(0.10, 0.40) : oklch.l.clamp(0.80, 0.98),
      c: oklch.c.clamp(0.0, 0.15),
      h: oklch.h,
      isDark: isDark,
      primaryColor: primaryColor,
      successColor: successColor,
      warningColor: warningColor,
      errorColor: errorColor,
      infoColor: infoColor,
      c2Delta: c2Delta,
      troughDelta: troughDelta,
    );
  }

  /// Factory constructor that calculates tiered colors relative to Container 3 (anchorL).
  factory AppColorTheme.fromAnchor({
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
    final effectiveC2Delta = c2Delta ?? (isDark ? 0.022 : 0.018);
    final effectiveTroughDelta = troughDelta ?? (isDark ? 0.018 : 0.030);

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
      final l1 = (anchorL + effectiveC2Delta * 2.0).clamp(0.0, 0.99);
      final c1 = c * 0.70;
      final oklch1 = OklchColor(l1, c1, h);

      final l2 = (anchorL + effectiveC2Delta).clamp(0.0, 1.0);
      final c2 = c * 0.90;
      final oklch2 = OklchColor(l2, c2, h);

      final l3 = anchorL.clamp(0.0, 1.0);
      final c3 = c;
      final oklch3 = OklchColor(l3, c3, h);

      final lField = (anchorL - effectiveTroughDelta).clamp(0.0, 1.0);
      final cField = c * 1.2;
      final oklchField = OklchColor(lField, cField, h);

      final l4 = (anchorL + 0.010).clamp(0.0, 0.985);
      final c4 = c * 0.85;
      final oklch4 = OklchColor(l4, c4, h);

      final lText = 0.20;
      final cText = 0.03;
      final oklchText = OklchColor(lText, cText, h);

      final lTbf = (anchorL - 0.055).clamp(0.0, 1.0);
      final cTbf = c > 0.001 ? math.max(c * 1.4, 0.018) : 0.0;
      final oklchTbf = OklchColor(lTbf, cTbf, h);
      final oklchTbt = oklchText;

      final lDivider = (anchorL - 0.05).clamp(0.0, 1.0);
      final cDivider = c * 0.5;
      final oklchDivider = OklchColor(lDivider, cDivider, h);

      final lTfBorder = (anchorL - 0.10).clamp(0.0, 1.0);
      const cTfBorder = 0.02;
      final oklchTfBorder = OklchColor(lTfBorder, cTfBorder, h);

      final lPri = oklchP.l.clamp(0.35, 0.65);
      final oklchPri = OklchColor(lPri, oklchP.c, oklchP.h);
      final colPrimary = oklchPri.toColor();
      final colOnPrimary = lPri > 0.62 ? const Color(0xFF0F172A) : Colors.white;

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
      final colTfDisabledFill = col3;
      final colTfDisabledBorder = colText.withValues(alpha: 0.08);
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
          formula: 'anchorL + ${(effectiveC2Delta * 2.0).toStringAsFixed(3)} (c * 0.70)',
        ),
        LayerSpec(
          id: 'C2',
          label: 'Container 2',
          role: 'Card Wrapper',
          l: l2,
          c: c2,
          color: col2,
          hex: oklch2.hexCode,
          formula: 'anchorL + ${effectiveC2Delta.toStringAsFixed(3)} (c * 0.90)',
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
          formula: 'anchorL - ${effectiveTroughDelta.toStringAsFixed(3)} (c * 1.2)',
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
          hex: '#${(colTfDisabledBorder.a * 255).round().toRadixString(16).padLeft(2, '0')}${(colTfDisabledBorder.r * 255).round().toRadixString(16).padLeft(2, '0')}${(colTfDisabledBorder.g * 255).round().toRadixString(16).padLeft(2, '0')}${(colTfDisabledBorder.b * 255).round().toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
          formula: 'textMain alpha 0.08',
        ),
        LayerSpec(
          id: 'TDT',
          label: 'Disabled Text/Icon',
          role: 'WCAG Inactive Level',
          l: lText,
          c: cText,
          color: colTextDisabled,
          hex: '#${(colTextDisabled.a * 255).round().toRadixString(16).padLeft(2, '0')}${(colTextDisabled.r * 255).round().toRadixString(16).padLeft(2, '0')}${(colTextDisabled.g * 255).round().toRadixString(16).padLeft(2, '0')}${(colTextDisabled.b * 255).round().toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
          formula: 'textMain alpha 0.38',
        ),
      ];

      return AppColorTheme(
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
      final l1 = (anchorL - effectiveC2Delta * 2.5).clamp(0.0, 1.0);
      final c1 = c * 0.82;
      final oklch1 = OklchColor(l1, c1, h);

      final l2 = (anchorL - effectiveC2Delta).clamp(0.0, 1.0);
      final c2 = c * 0.94;
      final oklch2 = OklchColor(l2, c2, h);

      final l3 = anchorL.clamp(0.0, 1.0);
      final c3 = c;
      final oklch3 = OklchColor(l3, c3, h);

      final lField = (anchorL - effectiveTroughDelta).clamp(0.0, 1.0);
      final cField = c * 0.88;
      final oklchField = OklchColor(lField, cField, h);

      final l4 = (anchorL + 0.07).clamp(0.0, 1.0);
      final c4 = c * 1.0;
      final oklch4 = OklchColor(l4, c4, h);

      final lText = 0.93;
      final cText = 0.015;
      final oklchText = OklchColor(lText, cText, h);

      final lTbf = (l4 + 0.065).clamp(0.0, 1.0);
      final cTbf = c > 0.001 ? math.max(c * 1.3, 0.025) : 0.0;
      final oklchTbf = OklchColor(lTbf, cTbf, h);
      final oklchTbt = oklchText;

      final lDivider = (anchorL + 0.05).clamp(0.0, 1.0);
      final cDivider = c * 0.5;
      final oklchDivider = OklchColor(lDivider, cDivider, h);

      final lTfBorder = (anchorL + 0.08).clamp(0.0, 1.0);
      const cTfBorder = 0.02;
      final oklchTfBorder = OklchColor(lTfBorder, cTfBorder, h);

      final lPri = (oklchP.l < 0.55 ? (oklchP.l + 0.22) : oklchP.l).clamp(0.55, 0.78);
      final oklchPri = OklchColor(lPri, oklchP.c, oklchP.h);
      final colPrimary = oklchPri.toColor();
      final colOnPrimary = lPri > 0.62 ? const Color(0xFF090D16) : Colors.white;

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
      final colTfDisabledFill = col3;
      final colTfDisabledBorder = colText.withValues(alpha: 0.08);
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
          formula: 'anchorL - ${(effectiveC2Delta * 2.5).toStringAsFixed(3)} (c * 0.82)',
        ),
        LayerSpec(
          id: 'C2',
          label: 'Container 2',
          role: 'Card Wrapper',
          l: l2,
          c: c2,
          color: col2,
          hex: oklch2.hexCode,
          formula: 'anchorL - ${effectiveC2Delta.toStringAsFixed(3)} (c * 0.94)',
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
          formula: 'anchorL - ${effectiveTroughDelta.toStringAsFixed(3)} (c * 0.88)',
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
          formula: 'C4_L + 0.065 (L = ${lTbf.toStringAsFixed(3)})',
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
          hex: '#${(colTfDisabledBorder.a * 255).round().toRadixString(16).padLeft(2, '0')}${(colTfDisabledBorder.r * 255).round().toRadixString(16).padLeft(2, '0')}${(colTfDisabledBorder.g * 255).round().toRadixString(16).padLeft(2, '0')}${(colTfDisabledBorder.b * 255).round().toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
          formula: 'textMain alpha 0.08',
        ),
        LayerSpec(
          id: 'TDT',
          label: 'Disabled Text/Icon',
          role: 'WCAG Inactive Level',
          l: lText,
          c: cText,
          color: colTextDisabled,
          hex: '#${(colTextDisabled.a * 255).round().toRadixString(16).padLeft(2, '0')}${(colTextDisabled.r * 255).round().toRadixString(16).padLeft(2, '0')}${(colTextDisabled.g * 255).round().toRadixString(16).padLeft(2, '0')}${(colTextDisabled.b * 255).round().toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
          formula: 'textMain alpha 0.38',
        ),
      ];

      return AppColorTheme(
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
  AppColorTheme copyWith({
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
    return AppColorTheme(
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
      textFieldDisabledFill: textFieldDisabledFill ?? this.textFieldDisabledFill,
      textFieldDisabledBorder: textFieldDisabledBorder ?? this.textFieldDisabledBorder,
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
  AppColorTheme lerp(ThemeExtension<AppColorTheme>? other, double t) {
    if (other is! AppColorTheme) return this;

    return AppColorTheme(
      container1: Color.lerp(container1, other.container1, t) ?? container1,
      container2: Color.lerp(container2, other.container2, t) ?? container2,
      container3: Color.lerp(container3, other.container3, t) ?? container3,
      textFieldFill: Color.lerp(textFieldFill, other.textFieldFill, t) ?? textFieldFill,
      container4: Color.lerp(container4, other.container4, t) ?? container4,
      textMain: Color.lerp(textMain, other.textMain, t) ?? textMain,
      tonalButtonFill: Color.lerp(tonalButtonFill, other.tonalButtonFill, t) ?? tonalButtonFill,
      tonalButtonText: Color.lerp(tonalButtonText, other.tonalButtonText, t) ?? tonalButtonText,
      dividerLine: Color.lerp(dividerLine, other.dividerLine, t) ?? dividerLine,
      textFieldBorder: Color.lerp(textFieldBorder, other.textFieldBorder, t) ?? textFieldBorder,
      textFieldDisabledFill: Color.lerp(textFieldDisabledFill, other.textFieldDisabledFill, t) ?? textFieldDisabledFill,
      textFieldDisabledBorder: Color.lerp(textFieldDisabledBorder, other.textFieldDisabledBorder, t) ?? textFieldDisabledBorder,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
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

  /// Converts this [AppColorTheme] into a complete, standard Flutter [ThemeData].
  ThemeData toThemeData() {
    final baseColorScheme = isDark ? const ColorScheme.dark() : const ColorScheme.light();

    final colorScheme = baseColorScheme.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      error: error,
      onError: onError,
      surface: container3,
      onSurface: textMain,
      onSurfaceVariant: textSecondary,
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
        bodySmall: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textMain, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(color: textMain.withValues(alpha: 0.75)),
        labelSmall: TextStyle(color: textMuted),
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
          borderSide: BorderSide(color: primary, width: 1.8),
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
        hintStyle: TextStyle(color: textMuted),
        labelStyle: TextStyle(color: textSecondary),
      ),

      // Button Themes
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
            color: isDark ? Colors.white.withValues(alpha: 0.12) : subtleBorder,
            width: 1.0,
          ),
        ),
      ),

      // Popup Menu Theme (Container 4)
      popupMenuTheme: PopupMenuThemeData(
        color: container4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : subtleBorder,
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
            color: isDark ? Colors.white.withValues(alpha: 0.06) : subtleBorder,
          ),
        ),
      ),

      extensions: [this],
    );
  }
}

/// Backwards compatibility alias for LayerPalette
typedef LayerPalette = AppColorTheme;

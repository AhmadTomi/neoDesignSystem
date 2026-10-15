import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';
import '../../../quantity_text_field.dart';
import 'context_menu_mockup.dart';
import 'indicator_badges.dart';

/// Form controls, sunken trough input, buttons, and semantic status chips on Container 3.
class FormControlsSection extends StatelessWidget {
  final bool isDark;
  final LayerPalette palette;

  const FormControlsSection({
    super.key,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;
    final spacing = context.spacing;
    final text = context.text;

    return Container(
      decoration: BoxDecoration(
        color: palette.container3,
        borderRadius: radius.lg.all,
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
      padding: spacing.insetMd,
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
                  borderRadius: radius.md.all,
                ),
                child: Icon(
                  Icons.anchor_rounded,
                  size: 20,
                  color: palette.primary,
                ),
              ),
              spacing.hGapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Container 3 (Primary Anchor)',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Permukaan acuan utama lapis ketiga. Seluruh layer lain dihitung relatif terhadap anchorL ini.',
                      style: text.bodySmall?.copyWith(
                        color: palette.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              MathBadge(
                title: 'ANCHOR L = ${palette.anchorL.toStringAsFixed(2)}',
                subtitle: palette.specs[2].hex,
                textColor: palette.textMain,
                isDark: isDark,
                primaryColor: palette.primary,
                highlight: true,
              ),
            ],
          ),
          spacing.vGapMd,

          // Layer: Sunken TextField (textFieldFill) & Quantity TextField
          Row(
            children: [
              Expanded(
                child: Text(
                  'TEXT FIELD WITH SUNKEN TROUGH EFFECT',
                  style: text.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: palette.textSecondary,
                  ),
                ),
              ),
              spacing.hGapSm,
              Text(
                'QUANTITY FIELD',
                style: text.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
          spacing.vGapXs,
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: isDark
                        ? 'Efek Cekung Dark Mode (lembut & nyaman, tidak terlalu gelap)'
                        : 'Efek Cekung Light Mode (lebih gelap dari C3)',
                  ),
                ),
              ),
              spacing.hGapSm,
              Expanded(
                child: QuantityTextField(
                  initialValue: 1,
                  radius: radius.md.all,
                ),
              ),
            ],
          ),
          spacing.vGapXs,
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

          // 1. Divider Line
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

          // Disabled TextField (Rata dengan C3, tanpa cekung)
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
                  borderRadius: radius.xs.all,
                  border: Border.all(
                    color: palette.textFieldDisabledBorder,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'NON-INTERACTIVE',
                  style: text.labelSmall?.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: palette.textDisabled,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          spacing.vGapXs,
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
                padding: const EdgeInsets.only(right: 8),
                child: UnconstrainedBox(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: palette.textDisabled.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: radius.xs.all,
                    ),
                    child: Text(
                      'L: ${palette.specs[2].l.toStringAsFixed(2)}',
                      style: text.labelSmall?.tabular.slashZero?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: palette.textDisabled,
                      ),
                    ),
                  ),
                ),
              ),
              fillColor: palette.textFieldDisabledFill,
            ),
          ),
          spacing.vGapXs,
          Text(
            'Isian: Sama persis C3 (efek cekung hilang/rata) • Border: textMain 0.08a • Teks: WCAG 0.38a',
            style: TextStyle(
              fontSize: 10.5,
              fontStyle: FontStyle.italic,
              color: palette.textSecondary,
            ),
          ),
          spacing.vGapMd,

          // Divider Line
          Divider(
            color: palette.dividerLine,
            thickness: 1.0,
            height: 1,
          ),
          spacing.vGapMd,

          // PRIMARY ACTION & FOCUS BORDER SHOWCASE
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRIMARY BRAND ACTION & FOCUS BORDER',
                      style: text.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Warna brand primary terkalibrasi OKLCH dengan kontras otomatis.',
                      style: text.bodySmall?.copyWith(
                        fontSize: 10.5,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MathBadge(
                title:
                    'PRI L = ${palette.specs.firstWhere((s) => s.id == 'PRI').l.toStringAsFixed(3)}',
                subtitle: palette.specs.firstWhere((s) => s.id == 'PRI').hex,
                textColor: palette.textMain,
                isDark: isDark,
                primaryColor: palette.primary,
              ),
            ],
          ),
          spacing.vGapSm,
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
                    borderRadius: radius.sm.all,
                  ),
                  padding: spacing.insetSquish,
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
                    borderRadius: radius.sm.all,
                  ),
                  padding: spacing.insetSquish,
                ),
                child: const Text('Tonal Accent'),
              ),
              Container(
                padding: spacing.insetSquish,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.10),
                  borderRadius: radius.sm.all,
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
                        color: palette.textMain.withValues(
                          alpha: 0.65,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Border error, label error, dan suffix icon tersinkron dengan token palette.error.',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: palette.textMain.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MathBadge(
                title:
                    'ERR L = ${palette.specs.firstWhere((s) => s.id == 'ERR').l.toStringAsFixed(3)}',
                subtitle: palette.specs.firstWhere((s) => s.id == 'ERR').hex,
                textColor: palette.textMain,
                isDark: isDark,
                primaryColor: palette.error,
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            style: TextStyle(color: palette.textMain, fontSize: 14),
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
                        color: palette.textMain.withValues(
                          alpha: 0.65,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Derivasi OKLCH adaptif untuk status success, warning, error, dan info.',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: palette.textMain.withValues(
                          alpha: 0.55,
                        ),
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
              SemanticStatusChip(
                icon: Icons.check_circle_rounded,
                label: 'Success',
                color: palette.success,
                onColor: palette.onSuccess,
                formula:
                    palette.specs.firstWhere((s) => s.id == 'SUC').formula,
              ),
              SemanticStatusChip(
                icon: Icons.warning_rounded,
                label: 'Warning',
                color: palette.warning,
                onColor: palette.onWarning,
                formula:
                    palette.specs.firstWhere((s) => s.id == 'WAR').formula,
              ),
              SemanticStatusChip(
                icon: Icons.cancel_rounded,
                label: 'Error',
                color: palette.error,
                onColor: palette.onError,
                formula:
                    palette.specs.firstWhere((s) => s.id == 'ERR').formula,
              ),
              SemanticStatusChip(
                icon: Icons.info_rounded,
                label: 'Info',
                color: palette.info,
                onColor: palette.onInfo,
                formula:
                    palette.specs.firstWhere((s) => s.id == 'INF').formula,
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
          ContextMenuMockup(
            isDark: isDark,
            palette: palette,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';
import '../dialogs/c4_dialog_preview.dart';
import 'indicator_badges.dart';

/// Mockup demonstrating Container 4 surface, context menu popover, and tonal buttons.
class ContextMenuMockup extends StatelessWidget {
  final bool isDark;
  final LayerPalette palette;

  const ContextMenuMockup({
    super.key,
    required this.isDark,
    required this.palette,
  });

  Widget _buildContextMenuItem({
    required IconData icon,
    required String label,
    required String shortcut,
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

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;
    final spacing = context.spacing;
    final text = context.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      color: palette.textMain.withValues(
                        alpha: 0.65,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Warna background melayang untuk Dialog, Context Menu, dan Popover.',
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
                  'C4 L = ${palette.specs.firstWhere((s) => s.id == 'C4').l.toStringAsFixed(3)}',
              subtitle: palette.specs.firstWhere((s) => s.id == 'C4').hex,
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
                style: text.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            spacing.hGapSm,
            InkWell(
              onTap: () => showC4DialogPreview(
                context: context,
                palette: palette,
                isDark: isDark,
              ),
              borderRadius: radius.sm.all,
              child: Container(
                padding: spacing.insetSquish,
                decoration: BoxDecoration(
                  color: palette.tonalButtonFill,
                  borderRadius: radius.sm.all,
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
                      style: text.labelSmall?.copyWith(
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
        spacing.vGapSm,

        // Inline Context Menu Mockup on Container 4
        Container(
          decoration: BoxDecoration(
            color: palette.container4,
            borderRadius: radius.lg.all,
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
          padding: spacing.insetMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_open_rounded,
                    size: 16,
                    color: palette.textMain.withValues(
                      alpha: 0.8,
                    ),
                  ),
                  spacing.hGapSm,
                  Expanded(
                    child: Text(
                      'Context Menu Mockup (C4)',
                      style: text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textMain,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  spacing.hGapSm,
                  Container(
                    padding: spacing.insetSquish,
                    decoration: BoxDecoration(
                      color: palette.textMain.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: radius.xs.all,
                    ),
                    child: Text(
                      'Popover',
                      style: text.labelSmall?.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              spacing.vGapSm,
              // Menu items
              _buildContextMenuItem(
                icon: Icons.copy_rounded,
                label: 'Duplicate Color Tokens',
                shortcut: 'Ctrl+D',
              ),
              const SizedBox(height: 4),
              _buildContextMenuItem(
                icon: Icons.palette_outlined,
                label: 'Inspect OKLCH Gamut Boundary',
                shortcut: 'Ctrl+G',
              ),
              spacing.vGapSm,
              // Tonal Buttons INSIDE Container 4 (proving contrast on C4!)
              Text(
                'Tonal Buttons on C4 surface:',
                style: TextStyle(
                  fontSize: 10.5,
                  fontStyle: FontStyle.italic,
                  color: palette.textSecondary,
                ),
              ),
              spacing.vGapXs,
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  // Active Tonal Button (C4)
                  InkWell(
                    onTap: () {},
                    borderRadius: radius.sm.all,
                    child: Container(
                      padding: spacing.insetSquish,
                      decoration: BoxDecoration(
                        color: palette.tonalButtonFill,
                        borderRadius: radius.sm.all,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(
                                  alpha: 0.08,
                                )
                              : Colors.black.withValues(
                                  alpha: 0.06,
                                ),
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
                            style: text.labelSmall?.copyWith(
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
                    padding: spacing.insetSquish,
                    decoration: BoxDecoration(
                      color: palette.tonalButtonFill.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: radius.sm.all,
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
                          style: text.labelSmall?.copyWith(
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
    );
  }
}

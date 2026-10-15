import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';

/// Opens the showcase modal dialog on Container 4 surface.
void showC4DialogPreview({
  required BuildContext context,
  required LayerPalette palette,
  required bool isDark,
}) {
  final radius = context.radius;
  final spacing = context.spacing;

  showDialog(
    context: context,
    builder: (dialogCtx) {
      return Dialog(
        backgroundColor: palette.container4,
        shape: RoundedRectangleBorder(
          borderRadius: radius.xl.all,
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
          padding: spacing.insetLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: spacing.insetSquish,
                    decoration: BoxDecoration(
                      color: palette.tonalButtonFill,
                      borderRadius: radius.md.all,
                    ),
                    child: Icon(
                      Icons.layers_rounded,
                      size: 20,
                      color: palette.tonalButtonText,
                    ),
                  ),
                  spacing.hGapSm,
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
              spacing.vGapSm,
              Text(
                'Ini adalah modal dialog yang menggunakan Container 4 sebagai surface background. Di bawah ini terdapat Tonal Button yang dirancang agar tetap kontras dan terbaca jelas baik di atas Container 4 maupun Container 3.',
                style: TextStyle(
                  fontSize: 13,
                  color: palette.textMain.withValues(alpha: 0.80),
                  height: 1.4,
                ),
              ),
              spacing.vGapMd,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tonal Button on Container 4
                  InkWell(
                    onTap: () => Navigator.of(dialogCtx).pop(),
                    borderRadius: radius.sm.all,
                    child: Container(
                      padding: spacing.insetSquish,
                      decoration: BoxDecoration(
                        color: palette.tonalButtonFill,
                        borderRadius: radius.sm.all,
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
                  spacing.hGapSm,
                  // Primary Confirm Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: palette.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: radius.sm.all,
                      ),
                      padding: spacing.insetSquish,
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

import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';
import 'depth_hierarchy_table.dart';
import 'form_controls_section.dart';
import 'indicator_badges.dart';
import 'mode_header.dart';

/// Reusable Side-by-Side Preview Card widget.
///
/// Fully consumes [LayerPalette] via `Theme.of(context).extension<LayerPalette>()!`.
class StackPreviewCard extends StatelessWidget {
  final String modeTitle;
  final bool isDark;
  final Color anchorColor;
  final VoidCallback? onOpenColorPicker;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const StackPreviewCard({
    super.key,
    required this.modeTitle,
    required this.isDark,
    required this.anchorColor,
    this.onOpenColorPicker,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.color;
    final radius = context.radius;
    final spacing = context.spacing;

    return Container(
      color: palette.container1, // Background utama kanvas (C1)
      child: ListView(
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: spacing.insetMd,
        children: [
          // Header Bar for the Column
          ModeHeader(
            modeTitle: modeTitle,
            isDark: isDark,
            anchorColor: anchorColor,
            palette: palette,
            onOpenColorPicker: onOpenColorPicker,
          ),
          spacing.vGapMd,

          // Layer 2: Card Penampung Lapis Kedua (container2)
          Container(
            decoration: BoxDecoration(
              color: palette.container2,
              borderRadius: radius.xl.all,
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
            padding: spacing.insetMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Layer 2 Label & Badge
                Row(
                  children: [
                    LayerIndicatorBadge(
                      label: 'CONTAINER 2',
                      sub: 'Lapis Kedua (Card Wrapper)',
                      color: palette.container2,
                      textColor: palette.textMain,
                      isDark: isDark,
                    ),
                    const Spacer(),
                    MathBadge(
                      title: 'L = ${palette.specs[1].l.toStringAsFixed(2)}',
                      subtitle: palette.specs[1].hex,
                      textColor: palette.textMain,
                      isDark: isDark,
                      primaryColor: palette.primary,
                    ),
                  ],
                ),
                spacing.vGapMd,

                // Layer 3: Permukaan Acuan Utama (container3) with form controls & C4
                FormControlsSection(
                  isDark: isDark,
                  palette: palette,
                ),
              ],
            ),
          ),
          spacing.vGapLg,

          // Mathematical Depth Breakdown Table
          DepthHierarchyTable(
            isDark: isDark,
            palette: palette,
          ),
        ],
      ),
    );
  }
}

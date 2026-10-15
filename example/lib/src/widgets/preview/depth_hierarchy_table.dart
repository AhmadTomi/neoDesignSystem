import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';

/// Table detailing the mathematical OKLCH formulas and metrics of each layer depth.
class DepthHierarchyTable extends StatelessWidget {
  final bool isDark;
  final LayerPalette palette;

  const DepthHierarchyTable({
    super.key,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
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
}

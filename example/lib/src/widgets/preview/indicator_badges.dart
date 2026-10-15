import 'package:flutter/material.dart';

/// Indicator showing layer name and role with a colored circle.
class LayerIndicatorBadge extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;
  final Color textColor;
  final bool isDark;

  const LayerIndicatorBadge({
    super.key,
    required this.label,
    required this.sub,
    required this.color,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// Badge showing mathematical metrics (e.g. L value, hex code).
class MathBadge extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color textColor;
  final bool isDark;
  final Color primaryColor;
  final bool highlight;

  const MathBadge({
    super.key,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.isDark,
    required this.primaryColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
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
              fontFeatures: const [
                FontFeature.tabularFigures(),
                FontFeature.slashedZero(),
              ],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              color: textColor.withValues(alpha: 0.6),
              fontFeatures: const [
                FontFeature.tabularFigures(),
                FontFeature.slashedZero(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip showcasing a semantic status token with icon, label, and formula.
class SemanticStatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color onColor;
  final String formula;

  const SemanticStatusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onColor,
    required this.formula,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
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
}

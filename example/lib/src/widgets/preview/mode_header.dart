import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';

/// Top banner for Light or Dark mode showcase column.
class ModeHeader extends StatelessWidget {
  final String modeTitle;
  final bool isDark;
  final Color anchorColor;
  final LayerPalette palette;
  final VoidCallback? onOpenColorPicker;

  const ModeHeader({
    super.key,
    required this.modeTitle,
    required this.isDark,
    required this.anchorColor,
    required this.palette,
    this.onOpenColorPicker,
  });

  @override
  Widget build(BuildContext context) {
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
}

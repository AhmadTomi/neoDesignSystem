import 'package:flutter/material.dart';
import 'package:neo_color_picker/neo_color_picker.dart';
import 'package:neo_design_system/neo_design_system.dart';

/// Reusable card displaying an interactive color swatch with OKLCH metrics and trigger.
class ColorPickerCard extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;
  final Color? indicatorColor;

  const ColorPickerCard({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
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
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.palette_outlined, size: 12, color: dotColor),
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

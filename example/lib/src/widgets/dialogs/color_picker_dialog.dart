import 'package:flutter/material.dart';
import 'package:neo_color_picker/neo_color_picker.dart';
import 'package:neo_design_system/neo_design_system.dart';
import '../../controllers/playground_controller.dart';
import '../../models/color_picker_target.dart';

/// Shows an interactive color picker dialog utilizing [NeoColorPicker].
Future<void> showColorPickerDialog({
  required BuildContext context,
  required PlaygroundController controller,
  required ColorPickerTarget target,
  bool? isDark,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final currentColor = controller.getColor(target, isDark: isDark);
          final currentOklch = OklchColor.fromColor(currentColor);
          final title = target.title;
          final description = target.description;
          final accentColor = target.defaultAccentColor(currentColor);

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
                            onPressed: () => Navigator.of(dialogContext).pop(),
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
                            controller.updateColor(
                              newColor,
                              target: target,
                              isDark: isDark,
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
                            onPressed: () => Navigator.of(dialogContext).pop(),
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

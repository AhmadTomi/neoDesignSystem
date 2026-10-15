import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';
import '../../controllers/playground_controller.dart';
import '../../views/single_showcase_screen.dart';
import '../dialogs/export_preset_dialog.dart';
import '../dialogs/import_preset_dialog.dart';

/// App bar for the playground providing theme preset, density, shape, and contrast controls.
class PlaygroundAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PlaygroundController controller;

  const PlaygroundAppBar({
    super.key,
    required this.controller,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF181C26),
      elevation: 0,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final showBadge = constraints.maxWidth >= 340;
          return Row(
            children: [
              if (showBadge) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252D3D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF384357)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: controller.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'NEO DESIGN SYSTEM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F5F9),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Theme Playground & Live Token Inspector',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '4-Pillar Architecture: OKLCH Color • Directional Radius • Multi-Density Spacing • Single-Font OpenType',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // 1. Preset Dropdown
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF252D3D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF384357)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.allPresets.any(
                (p) => p.id == controller.currentPreset.id,
              )
                  ? controller.currentPreset.id
                  : null,
              hint: Text(
                controller.currentPreset.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              dropdownColor: const Color(0xFF1E2536),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white70,
              ),
              items: controller.allPresets.map((preset) {
                return DropdownMenuItem<String>(
                  value: preset.id,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: preset.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        preset.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (selectedId) {
                if (selectedId != null) {
                  final match = controller.allPresets.firstWhere(
                    (p) => p.id == selectedId,
                  );
                  controller.applyPreset(match);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 2. Shape Toggle
        ActionChip(
          avatar: Icon(
            controller.shape == ShapePreset.rounded
                ? Icons.rounded_corner
                : Icons.crop_square,
            size: 16,
            color: controller.shape == ShapePreset.rounded
                ? Colors.amberAccent
                : Colors.white70,
          ),
          label: Text(
            controller.shape == ShapePreset.rounded ? 'Rounded' : 'Sharp',
            style: TextStyle(
              fontSize: 12,
              color: controller.shape == ShapePreset.rounded
                  ? Colors.amberAccent
                  : Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF252D3D),
          side: const BorderSide(color: Color(0xFF384357)),
          onPressed: () {
            controller.setShape(
              controller.shape == ShapePreset.rounded
                  ? ShapePreset.sharp
                  : ShapePreset.rounded,
            );
          },
        ),
        const SizedBox(width: 6),

        // 3. Density Toggle
        ActionChip(
          avatar: Icon(
            controller.density == DensityPreset.compact
                ? Icons.density_small
                : Icons.density_medium,
            size: 16,
            color: controller.density == DensityPreset.compact
                ? Colors.cyanAccent
                : Colors.white70,
          ),
          label: Text(
            controller.density == DensityPreset.compact
                ? 'Compact'
                : 'Comfortable',
            style: TextStyle(
              fontSize: 12,
              color: controller.density == DensityPreset.compact
                ? Colors.cyanAccent
                : Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF252D3D),
          side: const BorderSide(color: Color(0xFF384357)),
          onPressed: () {
            controller.setDensity(
              controller.density == DensityPreset.comfortable
                  ? DensityPreset.compact
                  : DensityPreset.comfortable,
            );
          },
        ),
        const SizedBox(width: 6),

        // 4. Contrast Mode Toggle
        ActionChip(
          avatar: Icon(
            controller.highContrast
                ? Icons.contrast
                : Icons.contrast_outlined,
            size: 16,
            color: controller.highContrast
                ? Colors.orangeAccent
                : Colors.white70,
          ),
          label: Text(
            controller.highContrast ? 'High Contrast' : 'Standard',
            style: TextStyle(
              fontSize: 12,
              color: controller.highContrast
                  ? Colors.orangeAccent
                  : Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF252D3D),
          side: const BorderSide(color: Color(0xFF384357)),
          onPressed: () {
            controller.toggleHighContrast();
          },
        ),
        const SizedBox(width: 6),

        // 5. Save / Export Button
        IconButton(
          tooltip: 'Simpan / Ekspor Preset JSON',
          icon: const Icon(
            Icons.bookmark_add_outlined,
            color: Colors.white70,
          ),
          onPressed: () => showExportPresetDialog(context, controller),
        ),

        // 6. Import Button
        IconButton(
          tooltip: 'Impor Preset JSON',
          icon: const Icon(
            Icons.file_upload_outlined,
            color: Colors.white70,
          ),
          onPressed: () => showImportPresetDialog(context, controller),
        ),

        // 7. Color Panel Toggle
        IconButton(
          tooltip: controller.showControls
              ? 'Sembunyikan Panel Warna'
              : 'Buka Panel Warna',
          icon: Icon(
            controller.showControls
                ? Icons.palette_rounded
                : Icons.palette_outlined,
            color: controller.showControls
                ? controller.primaryColor
                : Colors.white70,
          ),
          onPressed: () {
            controller.toggleControls();
          },
        ),

        // 8. Open Single Showcase Screen
        IconButton(
          tooltip: 'Buka Single Column Showcase Customizer',
          icon: const Icon(
            Icons.view_agenda_outlined,
            color: Colors.white70,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SingleShowcaseScreen(controller: controller),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

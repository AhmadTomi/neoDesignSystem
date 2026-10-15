import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';
import '../controllers/playground_controller.dart';
import '../models/color_picker_target.dart';
import '../widgets/controls/color_picker_card.dart';
import '../widgets/dialogs/color_picker_dialog.dart';
import '../widgets/dialogs/export_preset_dialog.dart';
import '../widgets/preview/stack_preview_card.dart';

/// Single-column showcase screen with a top Configuration Section
/// and a bottom live Showcase Widget preview.
class SingleShowcaseScreen extends StatefulWidget {
  final PlaygroundController? controller;

  const SingleShowcaseScreen({
    super.key,
    this.controller,
  });

  @override
  State<SingleShowcaseScreen> createState() => _SingleShowcaseScreenState();
}

class _SingleShowcaseScreenState extends State<SingleShowcaseScreen> {
  late final PlaygroundController _controller;
  bool _internalController = false;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = PlaygroundController();
      _internalController = true;
    }
  }

  @override
  void dispose() {
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _openColorPicker(ColorPickerTarget target) {
    showColorPickerDialog(
      context: context,
      controller: _controller,
      target: target,
      isDark: _isDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentPreset = _controller.currentPreset;
        final palette =
            _isDark ? _controller.darkPalette : _controller.lightPalette;
        final radiusTheme = _controller.radiusTheme;
        final spacingTheme = _controller.spacingTheme;
        final isCompact = _controller.density == DensityPreset.compact;

        return Scaffold(
          backgroundColor: const Color(0xFF0F1117),
          appBar: AppBar(
            backgroundColor: const Color(0xFF181C26),
            elevation: 0,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: const Row(
              children: [
                Icon(Icons.view_agenda_rounded, size: 20, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  'Showcase Customizer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              // Light / Dark Mode Switcher for the Showcase
              ActionChip(
                avatar: Icon(
                  _isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 16,
                  color: _isDark ? const Color(0xFFFBBF24) : Colors.amberAccent,
                ),
                label: Text(
                  _isDark ? 'Dark Preview' : 'Light Preview',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: const Color(0xFF252D3D),
                side: const BorderSide(color: Color(0xFF384357)),
                onPressed: () {
                  setState(() {
                    _isDark = !_isDark;
                  });
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==========================================
                  // 1. BAGIAN ATAS: CONFIG SECTION
                  // ==========================================
                  _buildConfigSection(context, currentPreset, palette),

                  const SizedBox(height: 24),

                  // Divider with section label
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Color(0xFF2E384D), thickness: 1.2),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.widgets_outlined,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SHOWCASE WIDGET PREVIEW (${_isDark ? "DARK" : "LIGHT"})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: Color(0xFF94A3B8),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Color(0xFF2E384D), thickness: 1.2),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==========================================
                  // 2. BAGIAN BAWAH: SHOWCASE WIDGET
                  // ==========================================
                  Container(
                    decoration: BoxDecoration(
                      color: palette.container1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2E384D),
                        width: 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Theme(
                      data: palette.toThemeData().copyWith(
                        inputDecorationTheme: palette
                            .toThemeData()
                            .inputDecorationTheme
                            .copyWith(
                              contentPadding: spacingTheme.insetSquish,
                              constraints: BoxConstraints(
                                minHeight: isCompact ? 30.0 : 38.0,
                              ),
                              prefixIconConstraints: BoxConstraints(
                                minWidth: isCompact ? 30.0 : 38.0,
                                minHeight: isCompact ? 30.0 : 38.0,
                              ),
                              suffixIconConstraints: BoxConstraints(
                                minWidth: isCompact ? 30.0 : 38.0,
                                minHeight: isCompact ? 30.0 : 38.0,
                              ),
                            ),
                        extensions: [
                          palette,
                          radiusTheme,
                          spacingTheme,
                        ],
                      ),
                      child: StackPreviewCard(
                        modeTitle: _isDark ? 'DARK MODE' : 'LIGHT MODE',
                        isDark: _isDark,
                        anchorColor: _isDark
                            ? _controller.darkAnchorColor
                            : _controller.lightAnchorColor,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onOpenColorPicker: () => _openColorPicker(
                          _isDark
                              ? ColorPickerTarget.darkAnchor
                              : ColorPickerTarget.lightAnchor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the top Configuration Section containing:
  /// 1. Theme dropdown
  /// 2. Color modification cards
  /// 3. Save preset button
  Widget _buildConfigSection(
    BuildContext context,
    ThemePreset currentPreset,
    LayerPalette palette,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E384D), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                'Konfigurasi Tema & Warna',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Sesuaikan tema dasar, modifikasi warna-warna utama, dan simpan preset kustom Anda.',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),

          // ------------------------------------------
          // 1. Dropdown Tema & Mode Light / Dark
          // ------------------------------------------
          const Text(
            '1. PILIH TEMA & MODE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: Color(0xFF38BDF8),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 500;

              final dropdownWidget = Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2536),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2E384D)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _controller.allPresets.any((p) => p.id == currentPreset.id)
                        ? currentPreset.id
                        : null,
                    isExpanded: true,
                    hint: Text(
                      currentPreset.name,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    dropdownColor: const Color(0xFF1E2536),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                    items: _controller.allPresets.map((preset) {
                      return DropdownMenuItem<String>(
                        value: preset.id,
                        child: Text(
                          preset.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (selectedId) {
                      if (selectedId != null) {
                        final match = _controller.allPresets.firstWhere(
                          (p) => p.id == selectedId,
                        );
                        _controller.applyPreset(match);
                      }
                    },
                  ),
                ),
              );

              final modeToggleWidget = Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2536),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2E384D)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton(
                      title: 'Light',
                      icon: Icons.light_mode_rounded,
                      isSelected: !_isDark,
                      onTap: () => setState(() => _isDark = false),
                    ),
                    _buildModeButton(
                      title: 'Dark',
                      icon: Icons.dark_mode_rounded,
                      isSelected: _isDark,
                      onTap: () => setState(() => _isDark = true),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: dropdownWidget),
                    const SizedBox(width: 12),
                    modeToggleWidget,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    dropdownWidget,
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: modeToggleWidget,
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 20),

          // ------------------------------------------
          // 2. Modifikasi Beberapa Warna
          // ------------------------------------------
          const Text(
            '2. MODIFIKASI WARNA TOKENS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: Color(0xFF38BDF8),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final cards = [
                ColorPickerCard(
                  title: 'Primary Brand',
                  color: palette.primary,
                  onTap: () => _openColorPicker(ColorPickerTarget.primary),
                ),
                ColorPickerCard(
                  title: _isDark ? 'Dark Anchor' : 'Light Anchor',
                  color: _isDark
                      ? _controller.darkAnchorColor
                      : _controller.lightAnchorColor,
                  onTap: () => _openColorPicker(
                    _isDark
                        ? ColorPickerTarget.darkAnchor
                        : ColorPickerTarget.lightAnchor,
                  ),
                  indicatorColor: _isDark
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFFEF4444),
                ),
                ColorPickerCard(
                  title: 'Success Color',
                  color: palette.success,
                  onTap: () => _openColorPicker(ColorPickerTarget.success),
                ),
                ColorPickerCard(
                  title: 'Warning Color',
                  color: palette.warning,
                  onTap: () => _openColorPicker(ColorPickerTarget.warning),
                ),
                ColorPickerCard(
                  title: 'Error Color',
                  color: palette.error,
                  onTap: () => _openColorPicker(ColorPickerTarget.error),
                ),
                ColorPickerCard(
                  title: 'Info Color',
                  color: palette.info,
                  onTap: () => _openColorPicker(ColorPickerTarget.info),
                ),
              ];

              if (isWide) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: cards.map((card) {
                    return SizedBox(
                      width: (constraints.maxWidth - 10) / 2,
                      child: card,
                    );
                  }).toList(),
                );
              } else {
                return Column(
                  children: cards.map((card) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: card,
                    );
                  }).toList(),
                );
              }
            },
          ),

          const SizedBox(height: 20),

          // ------------------------------------------
          // 3. Tombol untuk Save
          // ------------------------------------------
          const Text(
            '3. SIMPAN PRESET',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: Color(0xFF38BDF8),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () => showExportPresetDialog(context, _controller),
                icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                label: const Text(
                  'Simpan / Ekspor Preset',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _controller.applyPreset(currentPreset);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Preset "${currentPreset.name}" di-reset ke default!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Color(0xFF2E384D)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? (title == 'Dark'
                      ? const Color(0xFFFBBF24)
                      : Colors.amberAccent)
                  : Colors.white60,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

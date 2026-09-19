import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neo_color_picker/neo_color_picker.dart';
import 'package:neo_design_system/neo_design_system.dart';

void main() {
  runApp(const OklchPaletteDemoApp());
}

/// Main Application Entry Point
class OklchPaletteDemoApp extends StatefulWidget {
  const OklchPaletteDemoApp({super.key});

  @override
  State<OklchPaletteDemoApp> createState() => _OklchPaletteDemoAppState();
}

enum ColorPickerTarget {
  lightAnchor,
  darkAnchor,
  primary,
  success,
  warning,
  error,
  info,
}

class _OklchPaletteDemoAppState extends State<OklchPaletteDemoApp> {
  final AppThemeController _themeController = AppThemeController(
    initialPreset: BuiltInPresets.slate,
  );
  ShapePreset _shape = ShapePreset.rounded;
  DensityPreset _density = DensityPreset.comfortable;

  // Configurable OKLCH anchor parameters for LIGHT MODE
  // Defaults to #F4F5F7 (Cool Neutral Slate Light)
  double _lightAnchorL = 0.970;
  double _lightChroma = 0.003;
  double _lightHue = 264.5;
  final double _lightC2Delta = 0.018; // Rapat & harmonis dengan C3
  final double _lightTroughDelta = 0.030;
  Color _lightAnchorColor = const Color(0xFFF4F5F7);

  // Configurable OKLCH anchor parameters for DARK MODE
  // Defaults to #101010 (True Neutral Dark Anchor)
  static const _defaultDark = Color(0xFF181818);
  static final _darkOklch = OklchColor.fromColor(_defaultDark);

  double _darkAnchorL = _darkOklch.l;
  double _darkChroma = _darkOklch.c;
  double _darkHue = _darkOklch.h;
  final double _darkC2Delta = 0.022;
  final double _darkTroughDelta = 0.018;
  Color _darkAnchorColor = _defaultDark;

  Color _primaryColor = const Color(0xFF2563EB);
  Color _successColor = const Color(0xFF10B981);
  Color _warningColor = const Color(0xFFF59E0B);
  Color _errorColor = const Color(0xFFEF4444);
  Color _infoColor = const Color(0xFF06B6D4);

  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _applyPreset(BuiltInPresets.slate, notify: false);
  }

  void _applyPreset(ThemePreset preset, {bool notify = true}) {
    _themeController.setPreset(preset);
    _shape = preset.shape;
    _density = preset.density;
    _lightAnchorColor = preset.lightAnchor;
    _darkAnchorColor = preset.darkAnchor;
    _primaryColor = preset.primaryColor;

    final oklchL = OklchColor.fromColor(_lightAnchorColor);
    _lightHue = oklchL.h;
    _lightChroma = oklchL.c.clamp(0.0, 0.15);
    _lightAnchorL = oklchL.l.clamp(0.80, 0.98);

    final oklchD = OklchColor.fromColor(_darkAnchorColor);
    _darkHue = oklchD.h;
    _darkChroma = oklchD.c.clamp(0.0, 0.15);
    _darkAnchorL = oklchD.l.clamp(0.10, 0.40);

    if (notify) setState(() {});
  }

  void _showSaveExportModal([BuildContext? context]) {
    final effectiveContext = context ?? _navigatorKey.currentContext;
    if (effectiveContext == null) return;

    final currentPreset = ThemePreset(
      id: _themeController.currentPreset.id,
      name: _themeController.currentPreset.name,
      description: _themeController.currentPreset.description,
      lightAnchor: _lightAnchorColor,
      darkAnchor: _darkAnchorColor,
      primaryColor: _primaryColor,
      shape: _shape,
      density: _density,
    );

    final jsonString = _themeController.exportPresetJson(currentPreset);
    final nameController = TextEditingController(text: '${currentPreset.name} (Copy)');

    showDialog(
      context: effectiveContext,
      builder: (dialogCtx) => Dialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E384D)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bookmark_add_rounded, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Save & Export Theme Preset',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Beri nama untuk menyimpan preset ini ke dropdown, atau salin kode JSON untuk dibagikan.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nama Preset',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF1E2536),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1219),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF262E40)),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonString,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF38BDF8)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy JSON'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3B4863)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: jsonString));
                        ScaffoldMessenger.of(effectiveContext).showSnackBar(
                          const SnackBar(content: Text('JSON Preset disalin ke clipboard!')),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Simpan Preset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final newPreset = _themeController.saveCustomPreset(
                          nameController.text.trim().isEmpty ? 'Custom Theme' : nameController.text.trim(),
                        );
                        _applyPreset(newPreset);
                        Navigator.pop(dialogCtx);
                        ScaffoldMessenger.of(effectiveContext).showSnackBar(
                          SnackBar(content: Text('Preset "${newPreset.name}" berhasil disimpan!')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImportModal([BuildContext? context]) {
    final effectiveContext = context ?? _navigatorKey.currentContext;
    if (effectiveContext == null) return;

    final textController = TextEditingController();

    showDialog(
      context: effectiveContext,
      builder: (dialogCtx) => Dialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E384D)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.file_upload_rounded, color: Colors.amberAccent),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Import Theme Preset JSON',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Paste kode JSON preset di bawah ini untuk memuat tema secara langsung (on-the-fly):',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: textController,
                  maxLines: 7,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '{\n  "name": "My Theme",\n  "lightAnchorHex": "#F4F5F7",\n  "darkAnchorHex": "#101010",\n  ...\n}',
                    hintStyle: const TextStyle(color: Color(0xFF475569)),
                    filled: true,
                    fillColor: const Color(0xFF0F1219),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: const Text('Batal', style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Terapkan Preset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        try {
                          final imported = _themeController.importPresetJson(textController.text.trim());
                          _applyPreset(imported);
                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(effectiveContext).showSnackBar(
                            SnackBar(content: Text('Preset "${imported.name}" berhasil diterapkan!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(effectiveContext).showSnackBar(
                            SnackBar(content: Text('Gagal memuat JSON: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateColorFromPicker(
    Color newColor, {
    required ColorPickerTarget target,
  }) {
    setState(() {
      switch (target) {
        case ColorPickerTarget.primary:
          _primaryColor = newColor;
          break;
        case ColorPickerTarget.success:
          _successColor = newColor;
          break;
        case ColorPickerTarget.warning:
          _warningColor = newColor;
          break;
        case ColorPickerTarget.error:
          _errorColor = newColor;
          break;
        case ColorPickerTarget.info:
          _infoColor = newColor;
          break;
        case ColorPickerTarget.lightAnchor:
          _lightAnchorColor = newColor;
          final oklch = OklchColor.fromColor(newColor);
          _lightHue = oklch.h;
          _lightChroma = oklch.c.clamp(0.0, 0.15);
          _lightAnchorL = oklch.l.clamp(0.80, 0.98);
          break;
        case ColorPickerTarget.darkAnchor:
          _darkAnchorColor = newColor;
          final oklch = OklchColor.fromColor(newColor);
          _darkHue = oklch.h;
          _darkChroma = oklch.c.clamp(0.0, 0.15);
          _darkAnchorL = oklch.l.clamp(0.10, 0.40);
          break;
      }
    });
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _openColorPicker({
    required ColorPickerTarget target,
    BuildContext? context,
  }) {
    final targetContext = context ?? _navigatorKey.currentContext;
    if (targetContext == null) return;
    showDialog(
      context: targetContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentColor = switch (target) {
              ColorPickerTarget.lightAnchor => _lightAnchorColor,
              ColorPickerTarget.darkAnchor => _darkAnchorColor,
              ColorPickerTarget.primary => _primaryColor,
              ColorPickerTarget.success => _successColor,
              ColorPickerTarget.warning => _warningColor,
              ColorPickerTarget.error => _errorColor,
              ColorPickerTarget.info => _infoColor,
            };
            final currentOklch = OklchColor.fromColor(currentColor);

            final (title, description, accentColor) = switch (target) {
              ColorPickerTarget.lightAnchor => (
                'Light Mode Custom Anchor',
                'Pick a custom anchor color using NeoColorPicker. The OKLCH hue and chroma will dynamically anchor the light mode surfaces.',
                const Color(0xFFEF4444),
              ),
              ColorPickerTarget.darkAnchor => (
                'Dark Mode Custom Anchor',
                'Pick a custom anchor color using NeoColorPicker. The OKLCH hue and chroma will dynamically anchor the dark mode surfaces.',
                const Color(0xFFFBBF24),
              ),
              ColorPickerTarget.primary => (
                'Primary Brand Color',
                'Pick a primary brand color using NeoColorPicker. It will dynamically adapt in OKLCH for focus borders, primary buttons, and active indicators in both Light & Dark modes.',
                _primaryColor,
              ),
              ColorPickerTarget.success => (
                'Success Semantic Color',
                'Pick a base color for success state. OKLCH derivations will generate accessible contrast and surface badges in Light & Dark modes.',
                _successColor,
              ),
              ColorPickerTarget.warning => (
                'Warning Semantic Color',
                'Pick a base color for warning state. OKLCH derivations ensure appropriate luminance and legibility for alerts.',
                _warningColor,
              ),
              ColorPickerTarget.error => (
                'Error Semantic Color',
                'Pick a base color for error state. Applied to TextField error borders, error labels, and alert banners.',
                _errorColor,
              ),
              ColorPickerTarget.info => (
                'Info Semantic Color',
                'Pick a base color for info state. OKLCH derivations ensure cohesive informative callouts and badges.',
                _infoColor,
              ),
            };

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
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
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
                              _updateColorFromPicker(
                                newColor,
                                target: target,
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
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
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

  @override
  Widget build(BuildContext context) {
    // Generate Light and Dark LayerPalettes dynamically with separated anchor parameters
    final lightPalette = LayerPalette.fromAnchor(
      anchorL: _lightAnchorL,
      c: _lightChroma,
      h: _lightHue,
      isDark: false,
      c2Delta: _lightC2Delta,
      troughDelta: _lightTroughDelta,
      primaryColor: _primaryColor,
      successColor: _successColor,
      warningColor: _warningColor,
      errorColor: _errorColor,
      infoColor: _infoColor,
    );

    final darkPalette = LayerPalette.fromAnchor(
      anchorL: _darkAnchorL,
      c: _darkChroma,
      h: _darkHue,
      isDark: true,
      c2Delta: _darkC2Delta,
      troughDelta: _darkTroughDelta,
      primaryColor: _primaryColor,
      successColor: _successColor,
      warningColor: _warningColor,
      errorColor: _errorColor,
      infoColor: _infoColor,
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'OKLCH Tiered Palette System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: Builder(
        builder: (homeContext) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181C26),
          elevation: 0,
          title: Row(
            children: [
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
                        color: _primaryColor,
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
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
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
                  value: _themeController.allPresets.any((p) => p.id == _themeController.currentPreset.id)
                      ? _themeController.currentPreset.id
                      : null,
                  hint: Text(
                    _themeController.currentPreset.name,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  dropdownColor: const Color(0xFF1E2536),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  items: _themeController.allPresets.map((preset) {
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
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedId) {
                    if (selectedId != null) {
                      final match = _themeController.allPresets.firstWhere((p) => p.id == selectedId);
                      _applyPreset(match);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 2. Shape Toggle
            ActionChip(
              avatar: Icon(
                _shape == ShapePreset.rounded ? Icons.rounded_corner : Icons.crop_square,
                size: 16,
                color: _shape == ShapePreset.rounded ? Colors.amberAccent : Colors.white70,
              ),
              label: Text(
                _shape == ShapePreset.rounded ? 'Rounded' : 'Sharp',
                style: TextStyle(
                  fontSize: 12,
                  color: _shape == ShapePreset.rounded ? Colors.amberAccent : Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF252D3D),
              side: const BorderSide(color: Color(0xFF384357)),
              onPressed: () {
                setState(() {
                  _shape = _shape == ShapePreset.rounded ? ShapePreset.sharp : ShapePreset.rounded;
                  _themeController.setShape(_shape);
                });
              },
            ),
            const SizedBox(width: 6),

            // 3. Density Toggle
            ActionChip(
              avatar: Icon(
                _density == DensityPreset.compact ? Icons.density_small : Icons.density_medium,
                size: 16,
                color: _density == DensityPreset.compact ? Colors.cyanAccent : Colors.white70,
              ),
              label: Text(
                _density == DensityPreset.compact ? 'Compact' : 'Comfortable',
                style: TextStyle(
                  fontSize: 12,
                  color: _density == DensityPreset.compact ? Colors.cyanAccent : Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF252D3D),
              side: const BorderSide(color: Color(0xFF384357)),
              onPressed: () {
                setState(() {
                  _density = _density == DensityPreset.comfortable ? DensityPreset.compact : DensityPreset.comfortable;
                  _themeController.setDensity(_density);
                });
              },
            ),
            const SizedBox(width: 6),

            // 4. Save / Export Button
            IconButton(
              tooltip: 'Simpan / Ekspor Preset JSON',
              icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white70),
              onPressed: () => _showSaveExportModal(homeContext),
            ),

            // 5. Import Button
            IconButton(
              tooltip: 'Impor Preset JSON',
              icon: const Icon(Icons.file_upload_outlined, color: Colors.white70),
              onPressed: () => _showImportModal(homeContext),
            ),

            // 6. Color Panel Toggle
            IconButton(
              tooltip: _showControls ? 'Sembunyikan Panel Warna' : 'Buka Panel Warna',
              icon: Icon(
                _showControls ? Icons.palette_rounded : Icons.palette_outlined,
                color: _showControls ? _primaryColor : Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Interactive Parameter Controls Bar
              AnimatedCrossFade(
                firstChild: _buildControlPanel(),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _showControls
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 240),
              ),

              // Main Side-by-Side Showcase Area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 840;

                    final radiusTheme = _shape == ShapePreset.sharp
                        ? AppRadiusTheme.sharp()
                        : AppRadiusTheme.rounded();
                    final spacingTheme = _density == DensityPreset.compact
                        ? AppSpacingTheme.compact()
                        : AppSpacingTheme.comfortable();

                    final lightThemeWidget = Theme(
                      data: lightPalette.toThemeData().copyWith(
                        extensions: [
                          lightPalette,
                          radiusTheme,
                          spacingTheme,
                        ],
                      ),
                      child: StackPreviewCard(
                        modeTitle: 'LIGHT MODE',
                        isDark: false,
                        anchorColor: _lightAnchorColor,
                        onOpenColorPicker: () =>
                            _openColorPicker(target: ColorPickerTarget.lightAnchor),
                      ),
                    );

                    final darkThemeWidget = Theme(
                      data: darkPalette.toThemeData().copyWith(
                        extensions: [
                          darkPalette,
                          radiusTheme,
                          spacingTheme,
                        ],
                      ),
                      child: StackPreviewCard(
                        modeTitle: 'DARK MODE',
                        isDark: true,
                        anchorColor: _darkAnchorColor,
                        onOpenColorPicker: () =>
                            _openColorPicker(target: ColorPickerTarget.darkAnchor),
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: lightThemeWidget),
                          Container(width: 1.5, color: const Color(0xFF262C3A)),
                          Expanded(child: darkThemeWidget),
                        ],
                      );
                    } else {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 740, child: lightThemeWidget),
                            Container(
                              height: 2,
                              color: const Color(0xFF262C3A),
                            ),
                            SizedBox(height: 740, child: darkThemeWidget),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
);
  }

  /// Responsive configuration panel for Light anchor, Dark anchor, Primary Brand, and 4 Semantic Statuses.
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF131722),
        border: Border(
          bottom: BorderSide(color: Color(0xFF262C3A), width: 1.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;
          final isMedium = constraints.maxWidth >= 720;

          final lightCard = _buildColorPickerCard(
            title: 'Light Anchor Color',
            color: _lightAnchorColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.lightAnchor),
            indicatorColor: const Color(0xFFEF4444),
          );
          final darkCard = _buildColorPickerCard(
            title: 'Dark Anchor Color',
            color: _darkAnchorColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.darkAnchor),
            indicatorColor: const Color(0xFFFBBF24),
          );
          final primaryCard = _buildColorPickerCard(
            title: 'Primary Brand Color',
            color: _primaryColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.primary),
          );
          final successCard = _buildColorPickerCard(
            title: 'Success Status Color',
            color: _successColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.success),
          );
          final warningCard = _buildColorPickerCard(
            title: 'Warning Status Color',
            color: _warningColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.warning),
          );
          final errorCard = _buildColorPickerCard(
            title: 'Error Status Color',
            color: _errorColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.error),
          );
          final infoCard = _buildColorPickerCard(
            title: 'Info Status Color',
            color: _infoColor,
            onTap: () => _openColorPicker(target: ColorPickerTarget.info),
          );

          if (isWide) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: lightCard),
                    const SizedBox(width: 10),
                    Expanded(child: darkCard),
                    const SizedBox(width: 10),
                    Expanded(child: primaryCard),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: successCard),
                    const SizedBox(width: 10),
                    Expanded(child: warningCard),
                    const SizedBox(width: 10),
                    Expanded(child: errorCard),
                    const SizedBox(width: 10),
                    Expanded(child: infoCard),
                  ],
                ),
              ],
            );
          } else if (isMedium) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: lightCard),
                    const SizedBox(width: 10),
                    Expanded(child: darkCard),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: primaryCard),
                    const SizedBox(width: 10),
                    Expanded(child: successCard),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: warningCard),
                    const SizedBox(width: 10),
                    Expanded(child: errorCard),
                    const SizedBox(width: 10),
                    Expanded(child: infoCard),
                  ],
                ),
              ],
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                lightCard,
                const SizedBox(height: 8),
                darkCard,
                const SizedBox(height: 8),
                primaryCard,
                const SizedBox(height: 8),
                successCard,
                const SizedBox(height: 8),
                warningCard,
                const SizedBox(height: 8),
                errorCard,
                const SizedBox(height: 8),
                infoCard,
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildColorPickerCard({
    required String title,
    required Color color,
    required VoidCallback onTap,
    Color? indicatorColor,
  }) {
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
                  border: Border.all(
                    color: color.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 12,
                      color: dotColor,
                    ),
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

/// Reusable Side-by-Side Preview Card widget.
///
/// Fully consumes [LayerPalette] via `Theme.of(context).extension<LayerPalette>()!`.
class StackPreviewCard extends StatelessWidget {
  final String modeTitle;
  final bool isDark;
  final Color anchorColor;
  final VoidCallback? onOpenColorPicker;

  const StackPreviewCard({
    super.key,
    required this.modeTitle,
    required this.isDark,
    required this.anchorColor,
    this.onOpenColorPicker,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.color;
    final radius = context.radius;
    final spacing = context.spacing;
    final text = context.text;

    return Container(
      color: palette.container1, // Background utama kanvas (C1)
      child: ListView(
        padding: spacing.insetMd,
        children: [
          // Header Bar for the Column
          _buildModeHeader(context, palette),
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
                    _buildLayerIndicator(
                      label: 'CONTAINER 2',
                      sub: 'Lapis Kedua (Card Wrapper)',
                      color: palette.container2,
                      textColor: palette.textMain,
                      isDark: isDark,
                    ),
                    const Spacer(),
                    _buildMathBadge(
                      title: 'L = ${palette.specs[1].l.toStringAsFixed(2)}',
                      subtitle: palette.specs[1].hex,
                      textColor: palette.textMain,
                      isDark: isDark,
                      primaryColor: palette.primary,
                    ),
                  ],
                ),
                spacing.vGapMd,

                // Layer 3: Permukaan Acuan Utama (container3) - The Anchor!
                Container(
                  decoration: BoxDecoration(
                    color: palette.container3,
                    borderRadius: radius.lg.all,
                    border: Border.all(
                      color: palette.primary.withValues(
                        alpha: isDark ? 0.35 : 0.22,
                      ),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: spacing.insetMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Layer 3 Anchor Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: palette.primary.withValues(
                                alpha: isDark ? 0.25 : 0.12,
                              ),
                              borderRadius: radius.md.all,
                            ),
                            child: Icon(
                              Icons.anchor_rounded,
                              size: 20,
                              color: palette.primary,
                            ),
                          ),
                          spacing.hGapSm,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Container 3 (Primary Anchor)',
                                  style: text.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: palette.textMain,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Permukaan acuan utama lapis ketiga. Seluruh layer lain dihitung relatif terhadap anchorL ini.',
                                  style: text.bodySmall?.copyWith(
                                    color: palette.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildMathBadge(
                            title:
                                'ANCHOR L = ${palette.anchorL.toStringAsFixed(2)}',
                            subtitle: palette.specs[2].hex,
                            textColor: palette.textMain,
                            isDark: isDark,
                            primaryColor: palette.primary,
                            highlight: true,
                          ),
                        ],
                      ),
                      spacing.vGapMd,

                      // Layer: Sunken TextField (textFieldFill)
                      Text(
                        'TEXT FIELD WITH SUNKEN TROUGH EFFECT',
                        style: text.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: palette.textSecondary,
                        ),
                      ),
                      spacing.vGapXs,
                      TextField(
                        style: TextStyle(color: palette.textMain, fontSize: 14),
                        cursorColor: palette.textMain,
                        decoration: InputDecoration(
                          hintText: isDark
                              ? 'Efek Cekung Dark Mode (lembut & nyaman, tidak terlalu gelap)'
                              : 'Efek Cekung Light Mode (lebih gelap dari C3)',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: palette.textMuted,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: palette.textSecondary,
                          ),
                          suffixIcon: Padding(
                            padding: spacing.insetSquish,
                            child: Container(
                              padding: spacing.insetSquish,
                              decoration: BoxDecoration(
                                color: palette.container3.withValues(
                                  alpha: 0.8,
                                ),
                                borderRadius: radius.xs.all,
                              ),
                              child: Text(
                                'L: ${palette.specs[3].l.toStringAsFixed(2)}',
                                style: text.labelSmall?.tabular.slashZero?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: palette.textMain,
                                ),
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: palette.textFieldFill,
                          contentPadding: spacing.insetMd,
                          // Border fisik tipis 1px penegas cekung (Default/Unfocused)
                          border: OutlineInputBorder(
                            borderRadius: radius.md.all,
                            borderSide: BorderSide(
                              color: palette.textFieldBorder,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: radius.md.all,
                            borderSide: BorderSide(
                              color: palette.textFieldBorder,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: radius.md.all,
                            borderSide: BorderSide(
                              color: palette.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      spacing.vGapXs,
                      Text(
                        isDark
                            ? 'Rumus Cekung: ${palette.specs[3].formula} • Border: ${palette.specs[4].formula}'
                            : 'Rumus Cekung: ${palette.specs[3].formula} • Border: ${palette.specs[4].formula}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          color: palette.textMain.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 1. Divider Line (Garis pemisah tipis dengan kontras rendah)
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: palette.dividerLine,
                              thickness: 1.0,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'DIVIDER LINE',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: palette.textMain.withValues(alpha: 0.45),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: palette.dividerLine,
                              thickness: 1.0,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3, 4, 5. Disabled TextField (Rata dengan C3, tanpa cekung)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'DISABLED TEXT FIELD (FLAT SURFACE)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: palette.textMain.withValues(alpha: 0.65),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: palette.textDisabled.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: radius.xs.all,
                              border: Border.all(
                                color: palette.textFieldDisabledBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'NON-INTERACTIVE',
                              style: text.labelSmall?.copyWith(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: palette.textDisabled,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      spacing.vGapXs,
                      TextField(
                        enabled: false,
                        style: TextStyle(
                          color: palette.textDisabled,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Disabled TextField (isian rata = C3, tanpa efek cekung)',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: palette.textDisabled,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: palette.textDisabled,
                            size: 20,
                          ),
                          suffixIcon: Padding(
                            padding: spacing.insetSquish,
                            child: Container(
                              padding: spacing.insetSquish,
                              decoration: BoxDecoration(
                                color: palette.textDisabled.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: radius.xs.all,
                              ),
                              child: Text(
                                'L: ${palette.specs[2].l.toStringAsFixed(2)}',
                                style: text.labelSmall?.tabular.slashZero?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: palette.textDisabled,
                                ),
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: palette.textFieldDisabledFill,
                          contentPadding: spacing.insetMd,
                          // Disabled Border: textMain dengan alpha 0.08
                          disabledBorder: OutlineInputBorder(
                            borderRadius: radius.md.all,
                            borderSide: BorderSide(
                              color: palette.textFieldDisabledBorder,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      spacing.vGapXs,
                      Text(
                        'Isian: Sama persis C3 (efek cekung hilang/rata) • Border: textMain 0.08a • Teks: WCAG 0.38a',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          color: palette.textSecondary,
                        ),
                      ),
                      spacing.vGapMd,

                      // Divider Line
                      Divider(
                        color: palette.dividerLine,
                        thickness: 1.0,
                        height: 1,
                      ),
                      spacing.vGapMd,

                      // PRIMARY ACTION & FOCUS BORDER SHOWCASE
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRIMARY BRAND ACTION & FOCUS BORDER',
                                  style: text.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: palette.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Warna brand primary terkalibrasi OKLCH dengan kontras otomatis.',
                                  style: text.bodySmall?.copyWith(
                                    fontSize: 10.5,
                                    color: palette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildMathBadge(
                            title:
                                'PRI L = ${palette.specs.firstWhere((s) => s.id == 'PRI').l.toStringAsFixed(3)}',
                            subtitle:
                                palette.specs.firstWhere((s) => s.id == 'PRI').hex,
                            textColor: palette.textMain,
                            isDark: isDark,
                            primaryColor: palette.primary,
                          ),
                        ],
                      ),
                      spacing.vGapSm,
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.bolt_rounded, size: 16),
                            label: const Text('Primary Button'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.primary,
                              foregroundColor: palette.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: radius.sm.all,
                              ),
                              padding: spacing.insetSquish,
                              elevation: 0,
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.primary.withValues(
                                alpha: isDark ? 0.22 : 0.14,
                              ),
                              foregroundColor: palette.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: radius.sm.all,
                              ),
                              padding: spacing.insetSquish,
                            ),
                            child: const Text('Tonal Accent'),
                          ),
                          Container(
                            padding: spacing.insetSquish,
                            decoration: BoxDecoration(
                              color: palette.primary.withValues(alpha: 0.10),
                              borderRadius: radius.sm.all,
                              border: Border.all(
                                color: palette.primary.withValues(alpha: 0.40),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: palette.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Focused Border: 1.5px',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: palette.textMain,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Divider Line
                      Divider(
                        color: palette.dividerLine,
                        thickness: 1.0,
                        height: 1,
                      ),
                      const SizedBox(height: 16),

                      // ERROR TEXT FIELD (VALIDATION STATE) SHOWCASE
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ERROR TEXT FIELD (VALIDATION STATE)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: palette.textMain.withValues(alpha: 0.65),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Border error, label error, dan suffix icon tersinkron dengan token palette.error.',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: palette.textMain.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildMathBadge(
                            title:
                                'ERR L = ${palette.specs.firstWhere((s) => s.id == 'ERR').l.toStringAsFixed(3)}',
                            subtitle:
                                palette.specs.firstWhere((s) => s.id == 'ERR').hex,
                            textColor: palette.textMain,
                            isDark: isDark,
                            primaryColor: palette.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        style: TextStyle(
                          color: palette.textMain,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'user@example.com',
                          errorText: 'Format alamat email tidak valid',
                          prefixIcon: Icon(
                            Icons.alternate_email_rounded,
                            color: palette.textMain.withValues(alpha: 0.60),
                            size: 20,
                          ),
                          suffixIcon: Icon(
                            Icons.error_outline_rounded,
                            color: palette.error,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider Line
                      Divider(
                        color: palette.dividerLine,
                        thickness: 1.0,
                        height: 1,
                      ),
                      const SizedBox(height: 16),

                      // SEMANTIC STATUS BADGES & ALERTS SHOWCASE
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SEMANTIC STATUS TOKENS & BADGES',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: palette.textMain.withValues(alpha: 0.65),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Derivasi OKLCH adaptif untuk status success, warning, error, dan info.',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: palette.textMain.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusChip(
                            icon: Icons.check_circle_rounded,
                            label: 'Success',
                            color: palette.success,
                            onColor: palette.onSuccess,
                            formula: palette.specs.firstWhere((s) => s.id == 'SUC').formula,
                          ),
                          _buildStatusChip(
                            icon: Icons.warning_rounded,
                            label: 'Warning',
                            color: palette.warning,
                            onColor: palette.onWarning,
                            formula: palette.specs.firstWhere((s) => s.id == 'WAR').formula,
                          ),
                          _buildStatusChip(
                            icon: Icons.cancel_rounded,
                            label: 'Error',
                            color: palette.error,
                            onColor: palette.onError,
                            formula: palette.specs.firstWhere((s) => s.id == 'ERR').formula,
                          ),
                          _buildStatusChip(
                            icon: Icons.info_rounded,
                            label: 'Info',
                            color: palette.info,
                            onColor: palette.onInfo,
                            formula: palette.specs.firstWhere((s) => s.id == 'INF').formula,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Divider Line
                      Divider(
                        color: palette.dividerLine,
                        thickness: 1.0,
                        height: 1,
                      ),
                      const SizedBox(height: 16),

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
                                    color: palette.textMain.withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Warna background melayang untuk Dialog, Context Menu, dan Popover.',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: palette.textMain.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildMathBadge(
                            title:
                                'C4 L = ${palette.specs.firstWhere((s) => s.id == 'C4').l.toStringAsFixed(3)}',
                            subtitle:
                                palette.specs.firstWhere((s) => s.id == 'C4').hex,
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
                            onTap: () => _openDialogPreview(context, palette),
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
                                  color: palette.textMain.withValues(alpha: 0.8),
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
                                    color: palette.textMain.withValues(alpha: 0.08),
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
                              palette: palette,
                            ),
                            const SizedBox(height: 4),
                            _buildContextMenuItem(
                              icon: Icons.palette_outlined,
                              label: 'Inspect OKLCH Gamut Boundary',
                              shortcut: 'Ctrl+G',
                              palette: palette,
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
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.06),
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
                  ),
                ),
              ],
            ),
          ),
          spacing.vGapLg,

          // Mathematical Depth Breakdown Table
          _buildDepthHierarchyTable(context, palette),
        ],
      ),
    );
  }

  Widget _buildModeHeader(BuildContext context, LayerPalette palette) {
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

  Widget _buildLayerIndicator({
    required String label,
    required String sub,
    required Color color,
    required Color textColor,
    required bool isDark,
  }) {
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

  Widget _buildMathBadge({
    required String title,
    required String subtitle,
    required Color textColor,
    required bool isDark,
    required Color primaryColor,
    bool highlight = false,
  }) {
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

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color onColor,
    required String formula,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.0,
        ),
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

  Widget _buildDepthHierarchyTable(BuildContext context, LayerPalette palette) {
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

  Widget _buildContextMenuItem({
    required IconData icon,
    required String label,
    required String shortcut,
    required LayerPalette palette,
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

  void _openDialogPreview(BuildContext context, LayerPalette palette) {
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
}

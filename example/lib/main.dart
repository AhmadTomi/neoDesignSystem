import 'package:flutter/material.dart';
import 'src/theme/neo_trading_theme.dart';
import 'src/views/playground_screen.dart';

export 'src/controllers/playground_controller.dart';
export 'src/models/color_picker_target.dart';
export 'src/theme/neo_trading_theme.dart';
export 'src/views/playground_screen.dart';
export 'src/views/single_showcase_screen.dart';

void main() {
  runApp(const OklchPaletteDemoApp());
}

/// Main Application Entry Point for the OKLCH Palette Showcase and Playground.
class OklchPaletteDemoApp extends StatelessWidget {
  /// Specialized Neo Trading Preset configured for the showcase.
  static const neoTradingPreset = NeoTradingTheme.preset;

  const OklchPaletteDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OKLCH Tiered Palette System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: const PlaygroundScreen(),
    );
  }
}

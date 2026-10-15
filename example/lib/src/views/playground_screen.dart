import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';
import '../controllers/playground_controller.dart';
import '../models/color_picker_target.dart';
import '../widgets/controls/control_panel.dart';
import '../widgets/controls/playground_app_bar.dart';
import '../widgets/dialogs/color_picker_dialog.dart';
import '../widgets/preview/stack_preview_card.dart';

/// Main interactive playground screen for inspecting themes and token derivations.
class PlaygroundScreen extends StatefulWidget {
  final PlaygroundController? controller;

  const PlaygroundScreen({
    super.key,
    this.controller,
  });

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  late final PlaygroundController _controller;
  bool _internalController = false;

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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final lightPalette = _controller.lightPalette;
        final darkPalette = _controller.darkPalette;
        final radiusTheme = _controller.radiusTheme;
        final spacingTheme = _controller.spacingTheme;
        final isCompact = _controller.density == DensityPreset.compact;

        return Scaffold(
          backgroundColor: const Color(0xFF0F1117),
          appBar: PlaygroundAppBar(controller: _controller),
          body: SafeArea(
            child: Column(
              children: [
                // Interactive Parameter Controls Bar
                AnimatedCrossFade(
                  firstChild: ControlPanel(controller: _controller),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState: _controller.showControls
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 240),
                ),

                // Main Side-by-Side Showcase Area
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 840;

                      final lightThemeWidget = Theme(
                        data: lightPalette.toThemeData().copyWith(
                          inputDecorationTheme: lightPalette
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
                            lightPalette,
                            radiusTheme,
                            spacingTheme,
                          ],
                        ),
                        child: StackPreviewCard(
                          modeTitle: 'LIGHT MODE',
                          isDark: false,
                          anchorColor: _controller.lightAnchorColor,
                          onOpenColorPicker: () => showColorPickerDialog(
                            context: context,
                            controller: _controller,
                            target: ColorPickerTarget.lightAnchor,
                          ),
                        ),
                      );

                      final darkThemeWidget = Theme(
                        data: darkPalette.toThemeData().copyWith(
                          inputDecorationTheme: darkPalette
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
                            darkPalette,
                            radiusTheme,
                            spacingTheme,
                          ],
                        ),
                        child: StackPreviewCard(
                          modeTitle: 'DARK MODE',
                          isDark: true,
                          anchorColor: _controller.darkAnchorColor,
                          onOpenColorPicker: () => showColorPickerDialog(
                            context: context,
                            controller: _controller,
                            target: ColorPickerTarget.darkAnchor,
                          ),
                        ),
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: lightThemeWidget),
                            Container(
                              width: 1.5,
                              color: const Color(0xFF262C3A),
                            ),
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
    );
  }
}

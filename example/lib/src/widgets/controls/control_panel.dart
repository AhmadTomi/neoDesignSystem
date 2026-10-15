import 'package:flutter/material.dart';
import '../../controllers/playground_controller.dart';
import '../../models/color_picker_target.dart';
import '../dialogs/color_picker_dialog.dart';
import 'color_picker_card.dart';

/// Responsive configuration panel for Light/Dark anchors, Primary Brand, and Semantic Status colors.
class ControlPanel extends StatelessWidget {
  final PlaygroundController controller;

  const ControlPanel({
    super.key,
    required this.controller,
  });

  void _openPicker(BuildContext context, ColorPickerTarget target) {
    showColorPickerDialog(
      context: context,
      controller: controller,
      target: target,
    );
  }

  @override
  Widget build(BuildContext context) {
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

          final lightCard = ColorPickerCard(
            title: 'Light Anchor Color',
            color: controller.lightAnchorColor,
            onTap: () => _openPicker(context, ColorPickerTarget.lightAnchor),
            indicatorColor: const Color(0xFFEF4444),
          );
          final darkCard = ColorPickerCard(
            title: 'Dark Anchor Color',
            color: controller.darkAnchorColor,
            onTap: () => _openPicker(context, ColorPickerTarget.darkAnchor),
            indicatorColor: const Color(0xFFFBBF24),
          );
          final primaryCard = ColorPickerCard(
            title: 'Primary Brand Color',
            color: controller.primaryColor,
            onTap: () => _openPicker(context, ColorPickerTarget.primary),
          );
          final successCard = ColorPickerCard(
            title: 'Success Status Color',
            color: controller.successColor,
            onTap: () => _openPicker(context, ColorPickerTarget.success),
          );
          final warningCard = ColorPickerCard(
            title: 'Warning Status Color',
            color: controller.warningColor,
            onTap: () => _openPicker(context, ColorPickerTarget.warning),
          );
          final errorCard = ColorPickerCard(
            title: 'Error Status Color',
            color: controller.errorColor,
            onTap: () => _openPicker(context, ColorPickerTarget.error),
          );
          final infoCard = ColorPickerCard(
            title: 'Info Status Color',
            color: controller.infoColor,
            onTap: () => _openPicker(context, ColorPickerTarget.info),
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
}

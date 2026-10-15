import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_color_picker/neo_color_picker.dart';
import 'package:neo_design_system_example/main.dart';

void main() {
  testWidgets('Renders Light and Dark Mode showcase with color picker and dialogs', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const OklchPaletteDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('LIGHT MODE'), findsOneWidget);
    expect(find.text('DARK MODE'), findsOneWidget);
    expect(find.text('Light Anchor Color'), findsOneWidget);
    expect(find.text('Dark Anchor Color'), findsOneWidget);
    expect(find.text('Primary Brand Color'), findsOneWidget);
    expect(find.text('Success Status Color'), findsOneWidget);
    expect(find.text('Warning Status Color'), findsOneWidget);
    expect(find.text('Error Status Color'), findsOneWidget);
    expect(find.text('Info Status Color'), findsOneWidget);
    expect(find.text('Pilih Warna'), findsNWidgets(7));
    expect(find.text('Container 3 (Primary Anchor)'), findsNWidgets(2));
    expect(find.text('Custom Anchor'), findsNWidgets(2));

    // Verify TextFields: 2 sunken trough + 2 quantity + 2 disabled + 2 error validation = 8 TextFields
    expect(find.byType(TextField), findsNWidgets(8));

    // Verify presence of Divider widgets
    expect(find.byType(Divider), findsWidgets);
    expect(find.text('DIVIDER LINE'), findsNWidgets(2));
    expect(find.text('DISABLED TEXT FIELD (FLAT SURFACE)'), findsNWidgets(2));
    expect(find.text('ERROR TEXT FIELD (VALIDATION STATE)'), findsNWidgets(2));
    expect(find.text('SEMANTIC STATUS TOKENS & BADGES'), findsNWidgets(2));

    // Verify Primary Brand Button and Tonal Button are rendered
    expect(find.text('Primary Button'), findsNWidgets(2));
    expect(find.text('Tonal Button (C4)'), findsNWidgets(2));
    expect(find.text('Disabled Button (C4)'), findsNWidgets(2));
    expect(find.text('Open Dialog Preview (C4)'), findsNWidgets(2));
    expect(find.text('Context Menu Mockup (C4)'), findsNWidgets(2));

    // Tap on Light mode Custom Anchor button to open NeoColorPicker dialog
    await tester.tap(find.text('Custom Anchor').first);
    await tester.pumpAndSettle();

    expect(find.text('Light Mode Custom Anchor'), findsOneWidget);
    final picker = tester.widget<NeoColorPicker>(find.byType(NeoColorPicker));
    expect(picker.mode, NeoColorPickerMode.hsl);
    expect(find.text('Apply'), findsOneWidget);

    // Dismiss picker dialog
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Light Mode Custom Anchor'), findsNothing);

    // Tap on Primary Brand Color card to open NeoColorPicker dialog
    await tester.tap(find.text('Primary Brand Color'));
    await tester.pumpAndSettle();

    expect(find.text('Primary Brand Color'), findsWidgets);
    expect(find.text('Apply'), findsOneWidget);

    // Dismiss primary picker dialog
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    // Tap on Success Status Color card to open NeoColorPicker dialog
    await tester.tap(find.text('Success Status Color'));
    await tester.pumpAndSettle();

    expect(find.text('Success Semantic Color'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);

    // Dismiss success picker dialog
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Success Semantic Color'), findsNothing);

    // Open Dialog Preview (C4)
    await tester.ensureVisible(find.text('Open Dialog Preview (C4)').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Dialog Preview (C4)').first);
    await tester.pumpAndSettle();

    expect(find.text('Dialog Surface (Container 4)'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // Dismiss C4 Dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog Surface (Container 4)'), findsNothing);

    // Verify Save / Export Toolbar Button opens modal without MaterialLocalizations error
    await tester.tap(find.byTooltip('Simpan / Ekspor Preset JSON'));
    await tester.pumpAndSettle();
    expect(find.text('Save & Export Theme Preset'), findsOneWidget);
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byIcon(Icons.close)));
    await tester.pumpAndSettle();
    expect(find.text('Save & Export Theme Preset'), findsNothing);

    // Verify Import Toolbar Button opens modal without MaterialLocalizations error
    await tester.tap(find.byTooltip('Impor Preset JSON'));
    await tester.pumpAndSettle();
    expect(find.text('Import Theme Preset JSON'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Import Theme Preset JSON'), findsNothing);
  });

  testWidgets('Can select Neo Trading preset from dropdown and apply its tokens', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const OklchPaletteDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('Neo Trading'), findsWidgets);

    // Open preset dropdown
    await tester.tap(find.text('Neo Trading').first);
    await tester.pumpAndSettle();

    expect(find.text('Default Slate'), findsWidgets);

    // Tap Default Slate option
    await tester.tap(find.text('Default Slate').last);
    await tester.pumpAndSettle();

    // Verify Default Slate is now selected
    expect(find.text('Default Slate'), findsWidgets);
  });

  testWidgets('Can toggle High Contrast mode from AppBar ActionChip', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const OklchPaletteDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('Standard'), findsOneWidget);

    await tester.tap(find.text('Standard'));
    await tester.pumpAndSettle();

    expect(find.text('High Contrast'), findsOneWidget);

    await tester.tap(find.text('High Contrast'));
    await tester.pumpAndSettle();

    expect(find.text('Standard'), findsOneWidget);
  });

  testWidgets('SingleShowcaseScreen renders 1-column layout with config section and showcase widget', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MaterialApp(home: SingleShowcaseScreen()));
    await tester.pumpAndSettle();

    // Verify AppBar & Title
    expect(find.text('Showcase Customizer'), findsOneWidget);

    // Verify Config Section
    expect(find.text('1. PILIH TEMA & MODE'), findsOneWidget);
    expect(find.text('2. MODIFIKASI WARNA TOKENS'), findsOneWidget);
    expect(find.text('3. SIMPAN PRESET'), findsOneWidget);
    expect(find.text('Simpan / Ekspor Preset'), findsOneWidget);

    // Verify In-section Light / Dark mode buttons
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    // Verify Showcase Section
    expect(find.textContaining('SHOWCASE WIDGET PREVIEW'), findsOneWidget);
    expect(find.text('LIGHT MODE'), findsOneWidget);

    // Toggle Preview Mode via in-section button
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(find.text('DARK MODE'), findsOneWidget);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(find.text('LIGHT MODE'), findsOneWidget);

    // Open Color Picker from SingleShowcaseScreen
    await tester.tap(find.text('Primary Brand'));
    await tester.pumpAndSettle();
    expect(find.text('Primary Brand Color'), findsWidgets);
    expect(find.text('Apply'), findsOneWidget);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    // Open Save Preset Dialog from SingleShowcaseScreen
    await tester.tap(find.text('Simpan / Ekspor Preset'));
    await tester.pumpAndSettle();
    expect(find.text('Save & Export Theme Preset'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.text('Save & Export Theme Preset'), findsNothing);
  });

  testWidgets('SingleShowcaseScreen updates all config color cards and preview when switching preset or mode', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final controller = PlaygroundController();
    await tester.pumpWidget(MaterialApp(home: SingleShowcaseScreen(controller: controller)));
    await tester.pumpAndSettle();

    // 1. Initial State: Neo Trading in Light Mode
    expect(find.text('Light Anchor'), findsOneWidget);
    expect(find.text('Dark Anchor'), findsNothing);
    final lightSuccess = controller.lightPalette.success;
    final darkSuccess = controller.darkPalette.success;
    // NeoTradingTheme has different success color override for light vs dark
    expect(lightSuccess != darkSuccess, isTrue);

    // 2. Toggle to Dark Mode
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    // Verify Anchor Card changed to Dark Anchor
    expect(find.text('Dark Anchor'), findsOneWidget);
    expect(find.text('Light Anchor'), findsNothing);
    expect(find.text('DARK MODE'), findsOneWidget);

    // 3. Switch Theme Preset via Controller or Dropdown
    final slatePreset = controller.allPresets.firstWhere((p) => p.id == 'default_slate');
    controller.applyPreset(slatePreset);
    await tester.pumpAndSettle();

    expect(find.text('Default Slate'), findsWidgets);
    // Slate has slate anchor and primary
    expect(controller.currentPreset.id, 'default_slate');

    // 4. Update color in dark mode
    const customTestColor = Color(0xFFFF5722);
    controller.updateColor(customTestColor, target: ColorPickerTarget.primary, isDark: true);
    await tester.pumpAndSettle();

    expect(controller.darkPalette.primary, customTestColor);

    // 5. Toggle back to Light Mode
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(find.text('Light Anchor'), findsOneWidget);
    expect(find.text('LIGHT MODE'), findsOneWidget);
  });
}


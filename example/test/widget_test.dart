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

    // Verify TextFields: 2 active search + 2 disabled + 2 error validation = 6 TextFields
    expect(find.byType(TextField), findsNWidgets(6));

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
}

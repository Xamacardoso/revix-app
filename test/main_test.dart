import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revix/core/theme/revix_palette.dart';
import 'package:revix/main.dart';

void main() {
  testWidgets('uses the bundled Inter font without a network request', (
    tester,
  ) async {
    await tester.pumpWidget(const RevixApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(app.theme?.colorScheme.primary, RevixPalette.primary);
    expect(app.theme?.colorScheme.secondary, RevixPalette.accent);
    expect(app.theme?.scaffoldBackgroundColor, RevixPalette.canvas);
    expect(app.theme?.colorScheme.onSurface, RevixPalette.ink);
    final fontBytes = await rootBundle.load('assets/fonts/InterVariable.ttf');
    expect(fontBytes.lengthInBytes, greaterThan(0));
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:bella_canvas/main.dart';

void main() {
  testWidgets('Bella Canvas smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BellaCanvasApp());

    // Verify that the title appears.
    expect(find.text('🐾 Bella the Therapy Dog Art Studio'), findsOneWidget);
  });
}
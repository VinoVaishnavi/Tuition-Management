import 'package:flutter_test/flutter_test.dart';

import 'package:tuition_app/app/tuition_app.dart';

void main() {
  testWidgets('shows home screen title and welcome message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TuitionApp());

    expect(find.text('Tuition App'), findsOneWidget);
    expect(find.text('Welcome to Tuition App'), findsOneWidget);
  });
}

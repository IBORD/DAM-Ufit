import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ufit/src/pages/agenda_page.dart';

void main() {
  testWidgets('AgendaPage builds without crashing', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: AgendaPage()));

    expect(find.byType(AgendaPage), findsOneWidget);
  });
}

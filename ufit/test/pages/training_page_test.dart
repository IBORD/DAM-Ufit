import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ufit/src/pages/training_page.dart';

void main() {
  testWidgets('TrainingPage should display its title and main buttons', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: TrainingPage()));

    await tester.pumpAndSettle();

    expect(find.text('TREINO PERSONALIZADO'), findsOneWidget);
    expect(find.text('Com base nas suas preferências'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'INICIAR'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'CRIAR TREINO'), findsOneWidget);
  });
}

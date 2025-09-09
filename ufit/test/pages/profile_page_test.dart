import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ufit/src/pages/profile_page.dart';

void main() {
  testWidgets('ProfilePage should display its title and sections', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.pumpAndSettle();

    expect(find.text('Meu Perfil'), findsOneWidget);
    expect(find.text('Usuário'), findsOneWidget);
    expect(find.text('Suas Estatísticas'), findsOneWidget);
    expect(find.text('Calendário de Treinos'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });
}

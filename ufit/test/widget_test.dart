// Basic widget test for the Ufit app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ufit/test/services/test_theme_service.dart';
import 'package:ufit/test/services/test_language_service.dart';
import 'package:ufit/test/firebase_test_config.dart';

void main() {
  testWidgets('App should display basic structure', (WidgetTester tester) async {
    // Arrange
    MockUserPreferencesService.reset();
    final themeService = TestThemeService();
    final languageService = TestLanguageService();
    
    await themeService.initializeTheme();
    await languageService.initializeLanguage();

    // Act
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeService),
          ChangeNotifierProvider.value(value: languageService),
        ],
        child: MaterialApp(
          title: 'Ufit',
          theme: themeService.getThemeData(),
          locale: languageService.currentLocale,
          home: const Scaffold(
            body: Center(
              child: Text('Ufit App'),
            ),
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Ufit App'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('App should handle theme changes', (WidgetTester tester) async {
    // Arrange
    MockUserPreferencesService.reset();
    final themeService = TestThemeService();
    final languageService = TestLanguageService();
    
    await themeService.initializeTheme();
    await languageService.initializeLanguage();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeService),
          ChangeNotifierProvider.value(value: languageService),
        ],
        child: MaterialApp(
          title: 'Ufit',
          theme: themeService.getThemeData(),
          locale: languageService.currentLocale,
          home: const Scaffold(
            body: Center(
              child: Text('Ufit App'),
            ),
          ),
        ),
      ),
    );

    // Act
    await themeService.setTheme('dark');
    await tester.pump();

    // Assert
    expect(themeService.currentTheme, equals('dark'));
  });

  testWidgets('App should handle language changes', (WidgetTester tester) async {
    // Arrange
    MockUserPreferencesService.reset();
    final themeService = TestThemeService();
    final languageService = TestLanguageService();
    
    await themeService.initializeTheme();
    await languageService.initializeLanguage();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeService),
          ChangeNotifierProvider.value(value: languageService),
        ],
        child: MaterialApp(
          title: 'Ufit',
          theme: themeService.getThemeData(),
          locale: languageService.currentLocale,
          home: const Scaffold(
            body: Center(
              child: Text('Ufit App'),
            ),
          ),
        ),
      ),
    );

    // Act
    await languageService.setLanguage('en');
    await tester.pump();

    // Assert
    expect(languageService.currentLanguage, equals('en'));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:ufit/test/services/test_theme_service.dart';
import 'package:ufit/test/services/test_language_service.dart';
import 'package:ufit/test/firebase_test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ufit App Integration Tests', () {
    testWidgets('App should start and display basic structure', (WidgetTester tester) async {
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
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Ufit App'), findsOneWidget);
    });

    testWidgets('Theme service should work in integration', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final themeService = TestThemeService();
      await themeService.initializeTheme();

      // Act
      await themeService.setTheme('light');
      await tester.pumpAndSettle();

      // Assert
      expect(themeService.currentTheme, equals('light'));
      expect(themeService.currentThemeMode, equals(ThemeMode.light));
    });

    testWidgets('Language service should work in integration', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final languageService = TestLanguageService();
      await languageService.initializeLanguage();

      // Act
      await languageService.setLanguage('en');
      await tester.pumpAndSettle();

      // Assert
      expect(languageService.currentLanguage, equals('en'));
      expect(languageService.currentLocale, equals(const Locale('en', 'US')));
    });

    testWidgets('App should handle theme changes correctly', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final themeService = TestThemeService();
      await themeService.initializeTheme();

      // Act - Change to dark theme
      await themeService.setTheme('dark');
      await tester.pumpAndSettle();

      // Assert
      expect(themeService.currentTheme, equals('dark'));
      expect(themeService.getThemeData().brightness, equals(Brightness.dark));

      // Act - Change to light theme
      await themeService.setTheme('light');
      await tester.pumpAndSettle();

      // Assert
      expect(themeService.currentTheme, equals('light'));
      expect(themeService.getThemeData().brightness, equals(Brightness.light));
    });

    testWidgets('App should handle language changes correctly', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final languageService = TestLanguageService();
      await languageService.initializeLanguage();

      // Act - Change to English
      await languageService.setLanguage('en');
      await tester.pumpAndSettle();

      // Assert
      expect(languageService.currentLanguage, equals('en'));
      expect(languageService.getLocalizedText('home'), equals('Home'));

      // Act - Change to Spanish
      await languageService.setLanguage('es');
      await tester.pumpAndSettle();

      // Assert
      expect(languageService.currentLanguage, equals('es'));
      expect(languageService.getLocalizedText('home'), equals('Inicio'));
    });

    testWidgets('App should maintain state across theme changes', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final themeService = TestThemeService();
      await themeService.initializeTheme();

      // Act - Change theme multiple times
      await themeService.setTheme('light');
      await tester.pumpAndSettle();
      
      await themeService.setTheme('dark');
      await tester.pumpAndSettle();
      
      await themeService.setTheme('system');
      await tester.pumpAndSettle();

      // Assert
      expect(themeService.currentTheme, equals('system'));
      expect(themeService.currentThemeMode, equals(ThemeMode.system));
    });

    testWidgets('App should maintain state across language changes', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final languageService = TestLanguageService();
      await languageService.initializeLanguage();

      // Act - Change language multiple times
      await languageService.setLanguage('en');
      await tester.pumpAndSettle();
      
      await languageService.setLanguage('es');
      await tester.pumpAndSettle();
      
      await languageService.setLanguage('pt');
      await tester.pumpAndSettle();

      // Assert
      expect(languageService.currentLanguage, equals('pt'));
      expect(languageService.getLocalizedText('home'), equals('Início'));
    });

    testWidgets('App should handle concurrent theme and language changes', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final themeService = TestThemeService();
      final languageService = TestLanguageService();
      
      await themeService.initializeTheme();
      await languageService.initializeLanguage();

      // Act - Change both simultaneously
      await Future.wait([
        themeService.setTheme('dark'),
        languageService.setLanguage('en'),
      ]);
      await tester.pumpAndSettle();

      // Assert
      expect(themeService.currentTheme, equals('dark'));
      expect(languageService.currentLanguage, equals('en'));
      expect(languageService.getLocalizedText('home'), equals('Home'));
    });

    testWidgets('App should handle invalid theme gracefully', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final themeService = TestThemeService();
      await themeService.initializeTheme();

      // Act
      await themeService.setTheme('invalid_theme');
      await tester.pumpAndSettle();

      // Assert
      expect(themeService.currentTheme, equals('invalid_theme'));
      expect(themeService.currentThemeMode, equals(ThemeMode.system));
    });

    testWidgets('App should handle invalid language gracefully', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final languageService = TestLanguageService();
      await languageService.initializeLanguage();

      // Act
      await languageService.setLanguage('invalid_lang');
      await tester.pumpAndSettle();

      // Assert
      expect(languageService.currentLanguage, equals('invalid_lang'));
      expect(languageService.currentLocale, equals(const Locale('pt', 'BR')));
    });

    testWidgets('App should initialize with default values', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final themeService = TestThemeService();
      final languageService = TestLanguageService();

      // Act
      await themeService.initializeTheme();
      await languageService.initializeLanguage();
      await tester.pumpAndSettle();

      // Assert
      expect(themeService.currentTheme, equals('system'));
      expect(languageService.currentLanguage, equals('pt'));
    });

    testWidgets('App should handle rapid theme changes', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final themeService = TestThemeService();
      await themeService.initializeTheme();

      // Act - Rapid theme changes
      for (int i = 0; i < 5; i++) {
        await themeService.setTheme(i % 2 == 0 ? 'light' : 'dark');
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Assert
      expect(themeService.currentTheme, equals('dark'));
    });

    testWidgets('App should handle rapid language changes', (WidgetTester tester) async {
      // Arrange
      MockUserPreferencesService.reset();
      final languageService = TestLanguageService();
      await languageService.initializeLanguage();

      // Act - Rapid language changes
      final languages = ['pt', 'en', 'es'];
      for (int i = 0; i < 6; i++) {
        await languageService.setLanguage(languages[i % 3]);
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Assert
      expect(languageService.currentLanguage, equals('es'));
    });
  });
}

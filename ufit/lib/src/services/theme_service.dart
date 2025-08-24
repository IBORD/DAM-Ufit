import 'package:flutter/material.dart';
import 'package:ufit/src/services/user_preferences_service.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  ThemeMode _currentThemeMode = ThemeMode.system;
  String _currentTheme = 'system';

  ThemeMode get currentThemeMode => _currentThemeMode;
  String get currentTheme => _currentTheme;

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue[800],
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue[800]!),
      ),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue[400],
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey[850],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue[400]!),
      ),
    ),
  );

  // Initialize theme from preferences
  Future<void> initializeTheme() async {
    try {
      final theme = await UserPreferencesService.getPreference<String>(
        UserPreferencesService.themeKey,
        defaultValue: 'system',
      );
      await setTheme(theme ?? 'system');
    } catch (e) {
      print('Error initializing theme: $e');
      // Fallback to system theme
      await setTheme('system');
    }
  }

  // Set theme and save to preferences
  Future<void> setTheme(String theme) async {
    _currentTheme = theme;
    
    switch (theme) {
      case 'light':
        _currentThemeMode = ThemeMode.light;
        break;
      case 'dark':
        _currentThemeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _currentThemeMode = ThemeMode.system;
        break;
    }

    // Save to preferences
    await UserPreferencesService.savePreference(
      UserPreferencesService.themeKey,
      theme,
    );

    notifyListeners();
  }

  // Get current theme data
  ThemeData getThemeData() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
      default:
        // Use system theme
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.light ? lightTheme : darkTheme;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:ufit/src/repositories/user_preferences_repository.dart';
import 'package:ufit/src/services/theme_service.dart';
import 'package:ufit/src/services/language_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final IUserPreferencesRepository _userPreferencesRepository;
  
  bool _isLoading = true;
  Map<String, dynamic> _preferences = {};
  String? _errorMessage;

  SettingsViewModel({IUserPreferencesRepository? userPreferencesRepository})
      : _userPreferencesRepository = userPreferencesRepository ?? UserPreferencesRepository();

  // User preferences
  bool _notificationsEnabled = true;
  bool _workoutRemindersEnabled = true;
  String _theme = 'system';
  String _language = 'pt';
  String _measurementUnit = 'metric';
  int _defaultWorkoutDuration = 30;
  String _preferredWorkoutType = 'FORÇA';
  String _preferredWorkoutLocation = 'CASA';
  List<String> _targetAreas = ['Superiores'];
  String _fitnessLevel = 'beginner';
  bool _autoStartWorkout = false;
  bool _restTimerEnabled = true;
  int _defaultRestTime = 60;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get preferences => _preferences;

  // User preferences getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get workoutRemindersEnabled => _workoutRemindersEnabled;
  String get theme => _theme;
  String get language => _language;
  String get measurementUnit => _measurementUnit;
  int get defaultWorkoutDuration => _defaultWorkoutDuration;
  String get preferredWorkoutType => _preferredWorkoutType;
  String get preferredWorkoutLocation => _preferredWorkoutLocation;
  List<String> get targetAreas => _targetAreas;
  String get fitnessLevel => _fitnessLevel;
  bool get autoStartWorkout => _autoStartWorkout;
  bool get restTimerEnabled => _restTimerEnabled;
  int get defaultRestTime => _defaultRestTime;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  // Initialize preferences
  Future<void> loadPreferences() async {
    _setLoading(true);
    _clearError();

    try {
      final preferences = await _userPreferencesRepository.getUserPreferences();
      if (preferences != null) {
        _preferences = preferences;
        _loadPreferencesFromMap();
      }
    } catch (e) {
      _setError('Erro ao carregar preferências: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save preference
  Future<void> savePreference(String key, dynamic value) async {
    try {
      await _userPreferencesRepository.savePreference(key, value);
      _preferences[key] = value;
      _updateLocalPreference(key, value);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao salvar preferência: $e');
    }
  }

  // Save theme preference
  Future<void> saveThemePreference(String theme) async {
    try {
      await savePreference('theme', theme);
      _theme = theme;
      
      // Apply theme change
      final themeService = ThemeService();
      await themeService.setTheme(theme);
    } catch (e) {
      _setError('Erro ao salvar tema: $e');
    }
  }

  // Save language preference
  Future<void> saveLanguagePreference(String language) async {
    try {
      await savePreference('language', language);
      _language = language;
      
      // Apply language change
      final languageService = LanguageService();
      await languageService.setLanguage(language);
    } catch (e) {
      _setError('Erro ao salvar idioma: $e');
    }
  }

  // Reset all preferences
  Future<void> resetPreferences() async {
    try {
      await _userPreferencesRepository.clearAllPreferences();
      await loadPreferences();
    } catch (e) {
      _setError('Erro ao resetar preferências: $e');
    }
  }

  // Private methods
  void _loadPreferencesFromMap() {
    _notificationsEnabled = _preferences['notifications_enabled'] ?? true;
    _workoutRemindersEnabled = _preferences['workout_reminders_enabled'] ?? true;
    _theme = _preferences['theme'] ?? 'system';
    _language = _preferences['language'] ?? 'pt';
    _measurementUnit = _preferences['measurement_unit'] ?? 'metric';
    _defaultWorkoutDuration = _preferences['default_workout_duration'] ?? 30;
    _preferredWorkoutType = _preferences['preferred_workout_type'] ?? 'FORÇA';
    _preferredWorkoutLocation = _preferences['preferred_workout_location'] ?? 'CASA';
    _targetAreas = List<String>.from(_preferences['target_areas'] ?? ['Superiores']);
    _fitnessLevel = _preferences['fitness_level'] ?? 'beginner';
    _autoStartWorkout = _preferences['auto_start_workout'] ?? false;
    _restTimerEnabled = _preferences['rest_timer_enabled'] ?? true;
    _defaultRestTime = _preferences['default_rest_time'] ?? 60;
    _soundEnabled = _preferences['sound_enabled'] ?? true;
    _vibrationEnabled = _preferences['vibration_enabled'] ?? true;
  }

  void _updateLocalPreference(String key, dynamic value) {
    switch (key) {
      case 'notifications_enabled':
        _notificationsEnabled = value;
        break;
      case 'workout_reminders_enabled':
        _workoutRemindersEnabled = value;
        break;
      case 'theme':
        _theme = value;
        break;
      case 'language':
        _language = value;
        break;
      case 'measurement_unit':
        _measurementUnit = value;
        break;
      case 'default_workout_duration':
        _defaultWorkoutDuration = value;
        break;
      case 'preferred_workout_type':
        _preferredWorkoutType = value;
        break;
      case 'preferred_workout_location':
        _preferredWorkoutLocation = value;
        break;
      case 'target_areas':
        _targetAreas = List<String>.from(value);
        break;
      case 'fitness_level':
        _fitnessLevel = value;
        break;
      case 'auto_start_workout':
        _autoStartWorkout = value;
        break;
      case 'rest_timer_enabled':
        _restTimerEnabled = value;
        break;
      case 'default_rest_time':
        _defaultRestTime = value;
        break;
      case 'sound_enabled':
        _soundEnabled = value;
        break;
      case 'vibration_enabled':
        _vibrationEnabled = value;
        break;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

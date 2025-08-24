import 'package:flutter/material.dart';
import 'package:ufit/src/services/user_preferences_service.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Locale _currentLocale = const Locale('pt', 'BR');
  String _currentLanguage = 'pt';

  Locale get currentLocale => _currentLocale;
  String get currentLanguage => _currentLanguage;

  // Supported languages
  static const Map<String, Locale> supportedLocales = {
    'pt': Locale('pt', 'BR'),
    'en': Locale('en', 'US'),
    'es': Locale('es', 'ES'),
  };

  // Initialize language from preferences
  Future<void> initializeLanguage() async {
    try {
      final language = await UserPreferencesService.getPreference<String>(
        UserPreferencesService.languageKey,
        defaultValue: 'pt',
      );
      await setLanguage(language ?? 'pt');
    } catch (e) {
      print('Error initializing language: $e');
      // Fallback to Portuguese
      await setLanguage('pt');
    }
  }

  // Set language and save to preferences
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    _currentLocale = supportedLocales[language] ?? const Locale('pt', 'BR');

    // Save to preferences
    await UserPreferencesService.savePreference(
      UserPreferencesService.languageKey,
      language,
    );

    notifyListeners();
  }

  // Get supported locales for MaterialApp
  static List<Locale> get supportedLocalesList {
    return supportedLocales.values.toList();
  }

  // Get language name
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'pt':
        return 'Português';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Português';
    }
  }

  // Get localized text (simple implementation)
  static String getText(String key, String language) {
    final translations = {
      'pt': {
        'app_title': 'Ufit',
        'home': 'Início',
        'training': 'Treinos',
        'agenda': 'Agenda',
        'profile': 'Perfil',
        'settings': 'Configurações',
        'notifications': 'Notificações',
        'appearance': 'Aparência',
        'theme': 'Tema',
        'language': 'Idioma',
        'system': 'Sistema',
        'light': 'Claro',
        'dark': 'Escuro',
        'workouts': 'Treinos',
        'default_duration': 'Duração Padrão',
        'preferred_type': 'Tipo Preferido',
        'preferred_location': 'Local Preferido',
        'target_areas': 'Áreas Alvo',
        'fitness_level': 'Nível de Fitness',
        'beginner': 'Iniciante',
        'intermediate': 'Intermediário',
        'advanced': 'Avançado',
        'training_execution': 'Execução de Treino',
        'rest_timer': 'Timer de Descanso',
        'auto_start': 'Iniciar Automaticamente',
        'sound': 'Som',
        'vibration': 'Vibração',
        'system_settings': 'Configurações do Sistema',
        'reset_preferences': 'Resetar Preferências',
        'save': 'Salvar',
        'cancel': 'Cancelar',
        'ok': 'OK',
        'error': 'Erro',
        'success': 'Sucesso',
        'loading': 'Carregando...',
        'completed': 'Concluído',
        'duration': 'Duração',
        'exercises': 'Exercícios',
        'sets': 'Sets',
        'calories': 'Calorias',
        'minutes': 'minutos',
        'seconds': 'segundos',
        'kcal': 'kcal',
      },
      'en': {
        'app_title': 'Ufit',
        'home': 'Home',
        'training': 'Training',
        'agenda': 'Agenda',
        'profile': 'Profile',
        'settings': 'Settings',
        'notifications': 'Notifications',
        'appearance': 'Appearance',
        'theme': 'Theme',
        'language': 'Language',
        'system': 'System',
        'light': 'Light',
        'dark': 'Dark',
        'workouts': 'Workouts',
        'default_duration': 'Default Duration',
        'preferred_type': 'Preferred Type',
        'preferred_location': 'Preferred Location',
        'target_areas': 'Target Areas',
        'fitness_level': 'Fitness Level',
        'beginner': 'Beginner',
        'intermediate': 'Intermediate',
        'advanced': 'Advanced',
        'training_execution': 'Training Execution',
        'rest_timer': 'Rest Timer',
        'auto_start': 'Auto Start',
        'sound': 'Sound',
        'vibration': 'Vibration',
        'system_settings': 'System Settings',
        'reset_preferences': 'Reset Preferences',
        'save': 'Save',
        'cancel': 'Cancel',
        'ok': 'OK',
        'error': 'Error',
        'success': 'Success',
        'loading': 'Loading...',
        'completed': 'Completed',
        'duration': 'Duration',
        'exercises': 'Exercises',
        'sets': 'Sets',
        'calories': 'Calories',
        'minutes': 'minutes',
        'seconds': 'seconds',
        'kcal': 'kcal',
      },
      'es': {
        'app_title': 'Ufit',
        'home': 'Inicio',
        'training': 'Entrenamiento',
        'agenda': 'Agenda',
        'profile': 'Perfil',
        'settings': 'Configuración',
        'notifications': 'Notificaciones',
        'appearance': 'Apariencia',
        'theme': 'Tema',
        'language': 'Idioma',
        'system': 'Sistema',
        'light': 'Claro',
        'dark': 'Oscuro',
        'workouts': 'Entrenamientos',
        'default_duration': 'Duración Predeterminada',
        'preferred_type': 'Tipo Preferido',
        'preferred_location': 'Ubicación Preferida',
        'target_areas': 'Áreas Objetivo',
        'fitness_level': 'Nivel de Fitness',
        'beginner': 'Principiante',
        'intermediate': 'Intermedio',
        'advanced': 'Avanzado',
        'training_execution': 'Ejecución de Entrenamiento',
        'rest_timer': 'Temporizador de Descanso',
        'auto_start': 'Inicio Automático',
        'sound': 'Sonido',
        'vibration': 'Vibración',
        'system_settings': 'Configuración del Sistema',
        'reset_preferences': 'Restablecer Preferencias',
        'save': 'Guardar',
        'cancel': 'Cancelar',
        'ok': 'OK',
        'error': 'Error',
        'success': 'Éxito',
        'loading': 'Cargando...',
        'completed': 'Completado',
        'duration': 'Duración',
        'exercises': 'Ejercicios',
        'sets': 'Series',
        'calories': 'Calorías',
        'minutes': 'minutos',
        'seconds': 'segundos',
        'kcal': 'kcal',
      },
    };

    return translations[language]?[key] ?? key;
  }

  // Get localized text for current language
  String getText(String key) {
    return LanguageService.getText(key, _currentLanguage);
  }
}

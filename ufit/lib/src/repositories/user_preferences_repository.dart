import 'package:ufit/src/services/user_preferences_service.dart';

abstract class IUserPreferencesRepository {
  Future<Map<String, dynamic>?> getUserPreferences();
  Future<void> savePreference(String key, dynamic value);
  Future<T?> getPreference<T>(String key, {T? defaultValue});
  Future<void> clearAllPreferences();
  Future<bool> hasPreferences();
}

class UserPreferencesRepository implements IUserPreferencesRepository {
  @override
  Future<Map<String, dynamic>?> getUserPreferences() async {
    final userPrefs = await UserPreferencesService.getUserPreferences();
    return userPrefs?.preferences;
  }

  @override
  Future<void> savePreference(String key, dynamic value) async {
    await UserPreferencesService.savePreference(key, value);
  }

  @override
  Future<T?> getPreference<T>(String key, {T? defaultValue}) async {
    return await UserPreferencesService.getPreference<T>(key, defaultValue: defaultValue);
  }

  @override
  Future<void> clearAllPreferences() async {
    await UserPreferencesService.clearAllPreferences();
  }

  @override
  Future<bool> hasPreferences() async {
    return await UserPreferencesService.hasPreferences();
  }
}

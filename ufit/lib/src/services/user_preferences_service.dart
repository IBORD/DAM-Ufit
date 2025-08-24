import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPreferences {
  final String userId;
  final Map<String, dynamic> preferences;
  final DateTime lastUpdated;

  UserPreferences({
    required this.userId,
    required this.preferences,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'preferences': preferences,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    DateTime lastUpdated;
    if (map['lastUpdated'] is String) {
      lastUpdated = DateTime.parse(map['lastUpdated']);
    } else if (map['lastUpdated'] is Timestamp) {
      lastUpdated = (map['lastUpdated'] as Timestamp).toDate();
    } else {
      lastUpdated = DateTime.now();
    }
    
    return UserPreferences(
      userId: map['userId'],
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      lastUpdated: lastUpdated,
    );
  }
}

class UserPreferencesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _collectionName = 'user_preferences';

  // Get current user ID
  static String? get _currentUserId => _auth.currentUser?.uid;

  // Save user preference
  static Future<void> savePreference(String key, dynamic value) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final docRef = _firestore.collection(_collectionName).doc(userId);
      
      await docRef.set({
        'userId': userId,
        'preferences.$key': value,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('✅ Preference saved: $key = $value for user $userId');
    } catch (e) {
      print('❌ Error saving preference: $e');
      throw Exception('Failed to save preference: $e');
    }
  }

  // Save multiple preferences at once
  static Future<void> savePreferences(Map<String, dynamic> preferences) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final docRef = _firestore.collection(_collectionName).doc(userId);
      
      final Map<String, dynamic> data = {
        'userId': userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      
      // Add each preference with the 'preferences.' prefix
      preferences.forEach((key, value) {
        data['preferences.$key'] = value;
      });
      
      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save preferences: $e');
    }
  }

  // Get a specific preference
  static Future<T?> getPreference<T>(String key, {T? defaultValue}) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('⚠️ No user ID found, returning default value for $key');
      return defaultValue;
    }

    try {
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      
      if (!doc.exists) {
        print('📄 No preferences document found for user $userId, returning default for $key');
        return defaultValue;
      }

      final data = doc.data();
      if (data == null) {
        print('📄 No data in preferences document for user $userId');
        return defaultValue;
      }

      final preferences = data['preferences'] as Map<String, dynamic>?;
      if (preferences == null || !preferences.containsKey(key)) {
        print('🔍 Preference $key not found for user $userId, returning default: $defaultValue');
        return defaultValue;
      }

      final value = preferences[key] as T?;
      print('✅ Preference loaded: $key = $value for user $userId');
      return value;
    } catch (e) {
      print('❌ Error getting preference $key: $e');
      return defaultValue;
    }
  }

  // Get all user preferences
  static Future<UserPreferences?> getUserPreferences() async {
    final userId = _currentUserId;
    if (userId == null) {
      return null;
    }

    try {
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      
      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) {
        return null;
      }

      return UserPreferences.fromMap(data);
    } catch (e) {
      print('Error getting user preferences: $e');
      return null;
    }
  }

  // Delete a specific preference
  static Future<void> deletePreference(String key) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final docRef = _firestore.collection(_collectionName).doc(userId);
      await docRef.update({
        'preferences.$key': FieldValue.delete(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete preference: $e');
    }
  }

  // Clear all user preferences
  static Future<void> clearAllPreferences() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to clear preferences: $e');
    }
  }

  // Listen to preference changes in real-time
  static Stream<UserPreferences?> watchUserPreferences() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) {
        return null;
      }

      return UserPreferences.fromMap(data);
    });
  }

  // Check if user has any preferences
  static Future<bool> hasPreferences() async {
    final userId = _currentUserId;
    if (userId == null) {
      return false;
    }

    try {
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking preferences: $e');
      return false;
    }
  }

  // Debug method to print all preferences
  static Future<void> debugPrintPreferences() async {
    final userId = _currentUserId;
    if (userId == null) {
      print('⚠️ No user ID found for debugging preferences');
      return;
    }

    try {
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      if (!doc.exists) {
        print('📄 No preferences document found for user $userId');
        return;
      }

      final data = doc.data();
      print('🔍 All preferences for user $userId:');
      print(data);
    } catch (e) {
      print('❌ Error debugging preferences: $e');
    }
  }

  // Common preference keys
  static const String themeKey = 'theme';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications';
  static const String workoutRemindersKey = 'workout_reminders';
  static const String defaultWorkoutDurationKey = 'default_workout_duration';
  static const String preferredWorkoutTypeKey = 'preferred_workout_type';
  static const String preferredWorkoutLocationKey = 'preferred_workout_location';
  static const String targetAreasKey = 'target_areas';
  static const String fitnessLevelKey = 'fitness_level';
  static const String goalsKey = 'goals';
  static const String measurementUnitKey = 'measurement_unit'; // 'metric' or 'imperial'
  static const String autoStartWorkoutKey = 'auto_start_workout';
  static const String restTimerEnabledKey = 'rest_timer_enabled';
  static const String defaultRestTimeKey = 'default_rest_time';
  static const String soundEnabledKey = 'sound_enabled';
  static const String vibrationEnabledKey = 'vibration_enabled';
}

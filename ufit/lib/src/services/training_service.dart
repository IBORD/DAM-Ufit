import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/pages/equipment_page.dart';

class TrainingService {
  static const String _trainingsKey = 'user_trainings';
  static const String _sessionsKey = 'training_sessions';

  // Save training
  static Future<void> saveTraining(Training training) async {
    final prefs = await SharedPreferences.getInstance();
    final trainings = await getTrainings();
    trainings.add(training);
    
    final trainingsJson = jsonEncode(trainings.map((t) => t.toMap()).toList());
    await prefs.setString(_trainingsKey, trainingsJson);
  }

  // Get all trainings
  static Future<List<Training>> getTrainings() async {
    final prefs = await SharedPreferences.getInstance();
    final trainingsJson = prefs.getString(_trainingsKey);
    
    if (trainingsJson != null) {
      final List<dynamic> trainingsList = jsonDecode(trainingsJson);
      return trainingsList.map((t) => Training.fromMap(t)).toList();
    }
    
    return [];
  }

  // Get training by ID
  static Future<Training?> getTrainingById(String id) async {
    final trainings = await getTrainings();
    try {
      return trainings.firstWhere((training) => training.id == id);
    } catch (e) {
      return null;
    }
  }

  // Delete training
  static Future<void> deleteTraining(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final trainings = await getTrainings();
    trainings.removeWhere((training) => training.id == id);
    
    final trainingsJson = jsonEncode(trainings.map((t) => t.toMap()).toList());
    await prefs.setString(_trainingsKey, trainingsJson);
  }

  // Save training session
  static Future<void> saveTrainingSession(TrainingSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getTrainingSessions();
    sessions.add(session);
    
    final sessionsJson = jsonEncode(sessions.map((s) => s.toMap()).toList());
    await prefs.setString(_sessionsKey, sessionsJson);
  }

  // Get all training sessions
  static Future<List<TrainingSession>> getTrainingSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_sessionsKey);
    
    if (sessionsJson != null) {
      final List<dynamic> sessionsList = jsonDecode(sessionsJson);
      return sessionsList.map((s) => TrainingSession.fromMap(s)).toList();
    }
    
    return [];
  }

  // Get sessions for a specific date
  static Future<List<TrainingSession>> getSessionsForDate(DateTime date) async {
    final sessions = await getTrainingSessions();
    return sessions.where((session) {
      return session.date.year == date.year &&
             session.date.month == date.month &&
             session.date.day == date.day;
    }).toList();
  }

  // Get sessions for a specific training
  static Future<List<TrainingSession>> getSessionsForTraining(String trainingId) async {
    final sessions = await getTrainingSessions();
    return sessions.where((session) => session.trainingId == trainingId).toList();
  }

  // Update training session
  static Future<void> updateTrainingSession(TrainingSession updatedSession) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getTrainingSessions();
    
    final index = sessions.indexWhere((session) => session.id == updatedSession.id);
    if (index != -1) {
      sessions[index] = updatedSession;
      
      final sessionsJson = jsonEncode(sessions.map((s) => s.toMap()).toList());
      await prefs.setString(_sessionsKey, sessionsJson);
    }
  }

  // Generate sample exercises based on training type and target areas
  static List<Exercise> generateExercises(String type, List<String> targetAreas, List<Equipamento> equipment) {
    final List<Exercise> exercises = [];
    
    // Sample exercises database
    final Map<String, List<Map<String, dynamic>>> exerciseDatabase = {
      'Superiores': [
        {
          'name': 'Flexão de Braço',
          'description': 'Deite-se de barriga para baixo, apoie as mãos no chão e empurre o corpo para cima',
          'sets': 3,
          'reps': 12,
          'restSeconds': 60,
          'equipment': null,
          'category': 'Superiores',
        },
        {
          'name': 'Tríceps no Banco',
          'description': 'Apoie as mãos no banco atrás do corpo e faça flexões de tríceps',
          'sets': 3,
          'reps': 15,
          'restSeconds': 45,
          'equipment': 'Banco',
          'category': 'Superiores',
        },
        {
          'name': 'Prancha',
          'description': 'Mantenha o corpo em linha reta apoiado nos cotovelos e pontas dos pés',
          'sets': 3,
          'reps': 30, // seconds
          'restSeconds': 30,
          'equipment': null,
          'category': 'Superiores',
        },
      ],
      'Inferiores': [
        {
          'name': 'Agachamento',
          'description': 'Flexione os joelhos e quadris como se fosse sentar em uma cadeira',
          'sets': 4,
          'reps': 15,
          'restSeconds': 90,
          'equipment': null,
          'category': 'Inferiores',
        },
        {
          'name': 'Lunges',
          'description': 'Dê um passo à frente e desça até o joelho de trás quase tocar o chão',
          'sets': 3,
          'reps': 12,
          'restSeconds': 60,
          'equipment': null,
          'category': 'Inferiores',
        },
        {
          'name': 'Elevação de Panturrilha',
          'description': 'Fique na ponta dos pés e desça lentamente',
          'sets': 3,
          'reps': 20,
          'restSeconds': 30,
          'equipment': null,
          'category': 'Inferiores',
        },
      ],
      'Abs': [
        {
          'name': 'Abdominal Crunch',
          'description': 'Deite-se de costas, flexione os joelhos e levante o tronco',
          'sets': 3,
          'reps': 20,
          'restSeconds': 45,
          'equipment': null,
          'category': 'Abs',
        },
        {
          'name': 'Prancha Lateral',
          'description': 'Mantenha o corpo lateral apoiado em um braço',
          'sets': 3,
          'reps': 30, // seconds
          'restSeconds': 30,
          'equipment': null,
          'category': 'Abs',
        },
        {
          'name': 'Bicicleta no Ar',
          'description': 'Deite-se de costas e simule pedalar no ar',
          'sets': 3,
          'reps': 20,
          'restSeconds': 45,
          'equipment': null,
          'category': 'Abs',
        },
      ],
    };

    // Add exercises for each target area
    for (String area in targetAreas) {
      if (exerciseDatabase.containsKey(area)) {
        final areaExercises = exerciseDatabase[area]!;
        for (int i = 0; i < 2 && i < areaExercises.length; i++) {
          final exerciseData = areaExercises[i];
          exercises.add(Exercise(
            name: exerciseData['name'],
            description: exerciseData['description'],
            sets: exerciseData['sets'],
            reps: exerciseData['reps'],
            restSeconds: exerciseData['restSeconds'],
            equipment: exerciseData['equipment'],
            category: exerciseData['category'],
          ));
        }
      }
    }

    return exercises;
  }

  // Clear all data (for logout)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_trainingsKey);
    await prefs.remove(_sessionsKey);
  }
}

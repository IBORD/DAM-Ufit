import 'package:ufit/src/pages/equipment_page.dart';

class Training {
  final String id;
  final String name;
  final String type; // 'FORÇA', 'CARDIO', 'HIPERTROFIA', 'FUNCIONAL'
  final String location; // 'CASA', 'ACADEMIA'
  final int duration; // in minutes
  final List<String> targetAreas; // ['Superiores', 'Inferiores', 'Abs']
  final List<Equipamento> equipment;
  final List<Exercise> exercises;
  final DateTime createdAt;
  final bool isWarmupEnabled;

  Training({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.duration,
    required this.targetAreas,
    required this.equipment,
    required this.exercises,
    required this.createdAt,
    this.isWarmupEnabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
      'duration': duration,
      'targetAreas': targetAreas,
      'equipment': equipment.map((e) => e.toMap()).toList(),
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isWarmupEnabled': isWarmupEnabled,
    };
  }

  factory Training.fromMap(Map<String, dynamic> map) {
    return Training(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      location: map['location'],
      duration: map['duration'],
      targetAreas: List<String>.from(map['targetAreas']),
      equipment: (map['equipment'] as List)
          .map((e) => Equipamento.fromMap(e))
          .toList(),
      exercises: (map['exercises'] as List)
          .map((e) => Exercise.fromMap(e))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
      isWarmupEnabled: map['isWarmupEnabled'] ?? false,
    );
  }
}

class Exercise {
  final String name;
  final String description;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? equipment;
  final String? imageUrl;
  final String category; // 'Superiores', 'Inferiores', 'Abs', 'Cardio'

  Exercise({
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.equipment,
    this.imageUrl,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'equipment': equipment,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'],
      description: map['description'],
      sets: map['sets'],
      reps: map['reps'],
      restSeconds: map['restSeconds'],
      equipment: map['equipment'],
      imageUrl: map['imageUrl'],
      category: map['category'],
    );
  }
}

class TrainingSession {
  final String id;
  final String trainingId;
  final DateTime date;
  final int duration; // planned duration in minutes
  final List<ExerciseSession> exercises;
  bool isCompleted;
  DateTime? completedAt;
  int? actualDuration; // actual duration in minutes
  int? totalSets;
  double? caloriesBurned;

  TrainingSession({
    required this.id,
    required this.trainingId,
    required this.date,
    required this.duration,
    required this.exercises,
    this.isCompleted = false,
    this.completedAt,
    this.actualDuration,
    this.totalSets,
    this.caloriesBurned,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainingId': trainingId,
      'date': date.toIso8601String(),
      'duration': duration,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'actualDuration': actualDuration,
      'totalSets': totalSets,
      'caloriesBurned': caloriesBurned,
    };
  }

  factory TrainingSession.fromMap(Map<String, dynamic> map) {
    return TrainingSession(
      id: map['id'],
      trainingId: map['trainingId'],
      date: DateTime.parse(map['date']),
      duration: map['duration'],
      exercises: (map['exercises'] as List)
          .map((e) => ExerciseSession.fromMap(e))
          .toList(),
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      actualDuration: map['actualDuration'],
      totalSets: map['totalSets'],
      caloriesBurned: map['caloriesBurned']?.toDouble(),
    );
  }
}

class ExerciseSession {
  final String exerciseName;
  final int sets;
  final int reps;
  final int restSeconds;
  bool isCompleted;
  final List<SetSession> setSessions;

  ExerciseSession({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.isCompleted = false,
    required this.setSessions,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'isCompleted': isCompleted,
      'setSessions': setSessions.map((s) => s.toMap()).toList(),
    };
  }

  factory ExerciseSession.fromMap(Map<String, dynamic> map) {
    return ExerciseSession(
      exerciseName: map['exerciseName'],
      sets: map['sets'],
      reps: map['reps'],
      restSeconds: map['restSeconds'],
      isCompleted: map['isCompleted'] ?? false,
      setSessions: (map['setSessions'] as List)
          .map((s) => SetSession.fromMap(s))
          .toList(),
    );
  }
}

class SetSession {
  final int setNumber;
  final int reps;
  bool isCompleted;
  DateTime? completedAt;

  SetSession({
    required this.setNumber,
    required this.reps,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory SetSession.fromMap(Map<String, dynamic> map) {
    return SetSession(
      setNumber: map['setNumber'],
      reps: map['reps'],
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
    );
  }
}

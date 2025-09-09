import 'package:flutter_test/flutter_test.dart';
import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/pages/equipment_page.dart';

void main() {
  group('Training Model Tests', () {
    late Training training;
    late Exercise exercise;
    late TrainingSession session;
    late ExerciseSession exerciseSession;
    late SetSession setSession;

    setUp(() {
      // Create sample equipment
      final equipment = Equipamento(
        nome: 'Halteres',
        categoria: 'Peso Livre',
      );

      // Create sample exercise
      exercise = Exercise(
        name: 'Flexão de Braço',
        description: 'Exercício para peitoral',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        equipment: 'Nenhum',
        category: 'Superiores',
      );

      // Create sample training
      training = Training(
        id: 'training_1',
        name: 'Treino de Peito',
        type: 'FORÇA',
        location: 'CASA',
        duration: 45,
        targetAreas: ['Superiores'],
        equipment: [equipment],
        exercises: [exercise],
        createdAt: DateTime(2024, 1, 1),
        isWarmupEnabled: true,
      );

      // Create sample set session
      setSession = SetSession(
        setNumber: 1,
        reps: 12,
        isCompleted: true,
        completedAt: DateTime(2024, 1, 1, 10, 0),
      );

      // Create sample exercise session
      exerciseSession = ExerciseSession(
        exerciseName: 'Flexão de Braço',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        isCompleted: true,
        setSessions: [setSession],
      );

      // Create sample training session
      session = TrainingSession(
        id: 'session_1',
        trainingId: 'training_1',
        date: DateTime(2024, 1, 1),
        duration: 45,
        exercises: [exerciseSession],
        isCompleted: true,
        completedAt: DateTime(2024, 1, 1, 10, 45),
        actualDuration: 50,
        totalSets: 3,
        caloriesBurned: 250.0,
      );
    });

    group('Exercise Tests', () {
      test('should create exercise with correct properties', () {
        expect(exercise.name, 'Flexão de Braço');
        expect(exercise.description, 'Exercício para peitoral');
        expect(exercise.sets, 3);
        expect(exercise.reps, 12);
        expect(exercise.restSeconds, 60);
        expect(exercise.equipment, 'Nenhum');
        expect(exercise.category, 'Superiores');
      });

      test('should convert exercise to map correctly', () {
        final map = exercise.toMap();
        
        expect(map['name'], 'Flexão de Braço');
        expect(map['description'], 'Exercício para peitoral');
        expect(map['sets'], 3);
        expect(map['reps'], 12);
        expect(map['restSeconds'], 60);
        expect(map['equipment'], 'Nenhum');
        expect(map['category'], 'Superiores');
      });

      test('should create exercise from map correctly', () {
        final map = {
          'name': 'Agachamento',
          'description': 'Exercício para pernas',
          'sets': 4,
          'reps': 15,
          'restSeconds': 90,
          'equipment': null,
          'imageUrl': null,
          'category': 'Inferiores',
        };

        final newExercise = Exercise.fromMap(map);
        
        expect(newExercise.name, 'Agachamento');
        expect(newExercise.description, 'Exercício para pernas');
        expect(newExercise.sets, 4);
        expect(newExercise.reps, 15);
        expect(newExercise.restSeconds, 90);
        expect(newExercise.equipment, null);
        expect(newExercise.category, 'Inferiores');
      });
    });

    group('Training Tests', () {
      test('should create training with correct properties', () {
        expect(training.id, 'training_1');
        expect(training.name, 'Treino de Peito');
        expect(training.type, 'FORÇA');
        expect(training.location, 'CASA');
        expect(training.duration, 45);
        expect(training.targetAreas, ['Superiores']);
        expect(training.equipment.length, 1);
        expect(training.exercises.length, 1);
        expect(training.isWarmupEnabled, true);
      });

      test('should convert training to map correctly', () {
        final map = training.toMap();
        
        expect(map['id'], 'training_1');
        expect(map['name'], 'Treino de Peito');
        expect(map['type'], 'FORÇA');
        expect(map['location'], 'CASA');
        expect(map['duration'], 45);
        expect(map['targetAreas'], ['Superiores']);
        expect(map['equipment'], isA<List>());
        expect(map['exercises'], isA<List>());
        expect(map['isWarmupEnabled'], true);
      });

      test('should create training from map correctly', () {
        final map = {
          'id': 'training_2',
          'name': 'Treino de Pernas',
          'type': 'HIPERTROFIA',
          'location': 'ACADEMIA',
          'duration': 60,
          'targetAreas': ['Inferiores'],
          'equipment': [],
          'exercises': [],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'isWarmupEnabled': false,
        };

        final newTraining = Training.fromMap(map);
        
        expect(newTraining.id, 'training_2');
        expect(newTraining.name, 'Treino de Pernas');
        expect(newTraining.type, 'HIPERTROFIA');
        expect(newTraining.location, 'ACADEMIA');
        expect(newTraining.duration, 60);
        expect(newTraining.targetAreas, ['Inferiores']);
        expect(newTraining.isWarmupEnabled, false);
      });
    });

    group('SetSession Tests', () {
      test('should create set session with correct properties', () {
        expect(setSession.setNumber, 1);
        expect(setSession.reps, 12);
        expect(setSession.isCompleted, true);
        expect(setSession.completedAt, DateTime(2024, 1, 1, 10, 0));
      });

      test('should convert set session to map correctly', () {
        final map = setSession.toMap();
        
        expect(map['setNumber'], 1);
        expect(map['reps'], 12);
        expect(map['isCompleted'], true);
        expect(map['completedAt'], '2024-01-01T10:00:00.000');
      });

      test('should create set session from map correctly', () {
        final map = {
          'setNumber': 2,
          'reps': 10,
          'isCompleted': false,
          'completedAt': null,
        };

        final newSetSession = SetSession.fromMap(map);
        
        expect(newSetSession.setNumber, 2);
        expect(newSetSession.reps, 10);
        expect(newSetSession.isCompleted, false);
        expect(newSetSession.completedAt, null);
      });
    });

    group('ExerciseSession Tests', () {
      test('should create exercise session with correct properties', () {
        expect(exerciseSession.exerciseName, 'Flexão de Braço');
        expect(exerciseSession.sets, 3);
        expect(exerciseSession.reps, 12);
        expect(exerciseSession.restSeconds, 60);
        expect(exerciseSession.isCompleted, true);
        expect(exerciseSession.setSessions.length, 1);
      });

      test('should convert exercise session to map correctly', () {
        final map = exerciseSession.toMap();
        
        expect(map['exerciseName'], 'Flexão de Braço');
        expect(map['sets'], 3);
        expect(map['reps'], 12);
        expect(map['restSeconds'], 60);
        expect(map['isCompleted'], true);
        expect(map['setSessions'], isA<List>());
      });

      test('should create exercise session from map correctly', () {
        final map = {
          'exerciseName': 'Agachamento',
          'sets': 4,
          'reps': 15,
          'restSeconds': 90,
          'isCompleted': false,
          'setSessions': [],
        };

        final newExerciseSession = ExerciseSession.fromMap(map);
        
        expect(newExerciseSession.exerciseName, 'Agachamento');
        expect(newExerciseSession.sets, 4);
        expect(newExerciseSession.reps, 15);
        expect(newExerciseSession.restSeconds, 90);
        expect(newExerciseSession.isCompleted, false);
        expect(newExerciseSession.setSessions, isEmpty);
      });
    });

    group('TrainingSession Tests', () {
      test('should create training session with correct properties', () {
        expect(session.id, 'session_1');
        expect(session.trainingId, 'training_1');
        expect(session.date, DateTime(2024, 1, 1));
        expect(session.duration, 45);
        expect(session.exercises.length, 1);
        expect(session.isCompleted, true);
        expect(session.completedAt, DateTime(2024, 1, 1, 10, 45));
        expect(session.actualDuration, 50);
        expect(session.totalSets, 3);
        expect(session.caloriesBurned, 250.0);
      });

      test('should convert training session to map correctly', () {
        final map = session.toMap();
        
        expect(map['id'], 'session_1');
        expect(map['trainingId'], 'training_1');
        expect(map['date'], '2024-01-01T00:00:00.000');
        expect(map['duration'], 45);
        expect(map['exercises'], isA<List>());
        expect(map['isCompleted'], true);
        expect(map['completedAt'], '2024-01-01T10:45:00.000');
        expect(map['actualDuration'], 50);
        expect(map['totalSets'], 3);
        expect(map['caloriesBurned'], 250.0);
      });

      test('should create training session from map correctly', () {
        final map = {
          'id': 'session_2',
          'trainingId': 'training_2',
          'date': '2024-01-02T00:00:00.000',
          'duration': 60,
          'exercises': [],
          'isCompleted': false,
          'completedAt': null,
          'actualDuration': null,
          'totalSets': null,
          'caloriesBurned': null,
        };

        final newSession = TrainingSession.fromMap(map);
        
        expect(newSession.id, 'session_2');
        expect(newSession.trainingId, 'training_2');
        expect(newSession.date, DateTime(2024, 1, 2));
        expect(newSession.duration, 60);
        expect(newSession.exercises, isEmpty);
        expect(newSession.isCompleted, false);
        expect(newSession.completedAt, null);
        expect(newSession.actualDuration, null);
        expect(newSession.totalSets, null);
        expect(newSession.caloriesBurned, null);
      });
    });
  });
}

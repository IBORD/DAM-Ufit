import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/repositories/training_repository.dart';
import 'package:ufit/src/repositories/user_preferences_repository.dart';

class TrainingExecutionViewModel extends ChangeNotifier {
  final ITrainingRepository _trainingRepository;
  final IUserPreferencesRepository _userPreferencesRepository;
  
  Training? _training;
  TrainingSession? _session;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  bool _isResting = false;
  int _restTimer = 0;
  Timer? _timer;
  DateTime _startTime = DateTime.now();
  bool _isCompleted = false;
  String? _errorMessage;

  TrainingExecutionViewModel({
    ITrainingRepository? trainingRepository,
    IUserPreferencesRepository? userPreferencesRepository,
  }) : _trainingRepository = trainingRepository ?? TrainingRepository(),
       _userPreferencesRepository = userPreferencesRepository ?? UserPreferencesRepository();

  // Getters
  Training? get training => _training;
  TrainingSession? get session => _session;
  int get currentExerciseIndex => _currentExerciseIndex;
  int get currentSetIndex => _currentSetIndex;
  bool get isResting => _isResting;
  int get restTimer => _restTimer;
  DateTime get startTime => _startTime;
  bool get isCompleted => _isCompleted;
  String? get errorMessage => _errorMessage;

  // Initialize training session
  Future<void> initializeSession(TrainingSession session) async {
    _session = session;
    _startTime = DateTime.now();
    
    try {
      final training = await _trainingRepository.getTrainingById(session.trainingId);
      _training = training;
    } catch (e) {
      _setError('Erro ao carregar treino: $e');
    }
    
    notifyListeners();
  }

  // Complete current set
  Future<void> completeSet() async {
    if (_session == null || _training == null) return;

    final currentExercise = _session!.exercises[_currentExerciseIndex];
    final currentSet = currentExercise.setSessions[_currentSetIndex];

    // Mark set as completed
    currentSet.isCompleted = true;
    currentSet.completedAt = DateTime.now();

    // Check if we need to move to next set or exercise
    if (_currentSetIndex < currentExercise.sets - 1) {
      // Move to next set
      _currentSetIndex++;
      await _startRestTimer(currentExercise.restSeconds);
    } else {
      // Exercise completed, move to next exercise
      currentExercise.isCompleted = true;
      
      if (_currentExerciseIndex < _session!.exercises.length - 1) {
        // Move to next exercise
        _currentExerciseIndex++;
        _currentSetIndex = 0;
        final nextExercise = _session!.exercises[_currentExerciseIndex];
        await _startRestTimer(nextExercise.restSeconds);
      } else {
        // Training completed
        await _completeTraining();
      }
    }

    // Save session
    await _trainingRepository.updateTrainingSession(_session!);
    notifyListeners();
  }

  // Start rest timer
  Future<void> _startRestTimer(int seconds) async {
    // Check if rest timer is enabled in user preferences
    final restTimerEnabled = await _userPreferencesRepository.getPreference<bool>(
      'rest_timer_enabled',
      defaultValue: true,
    );

    if (restTimerEnabled == false) {
      // Skip rest timer if disabled
      return;
    }

    _isResting = true;
    _restTimer = seconds;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _restTimer--;
      notifyListeners();

      if (_restTimer <= 0) {
        timer.cancel();
        _isResting = false;
        notifyListeners();
      }
    });
  }

  // Complete training
  Future<void> _completeTraining() async {
    final duration = DateTime.now().difference(_startTime);
    final totalSets = _getTotalSetsCompleted();
    final caloriesBurned = _calculateCaloriesBurned(duration, totalSets);

    _isCompleted = true;

    // Save completion data to session
    _session!.isCompleted = true;
    _session!.completedAt = DateTime.now();
    _session!.actualDuration = duration.inMinutes;
    _session!.totalSets = totalSets;
    _session!.caloriesBurned = caloriesBurned;
    
    await _trainingRepository.updateTrainingSession(_session!);
    notifyListeners();
  }

  // Get total sets completed
  int _getTotalSetsCompleted() {
    if (_session == null) return 0;
    
    int total = 0;
    for (var exercise in _session!.exercises) {
      for (var set in exercise.setSessions) {
        if (set.isCompleted) total++;
      }
    }
    return total;
  }

  // Calculate calories burned
  double _calculateCaloriesBurned(Duration duration, int totalSets) {
    // Basic calorie calculation based on:
    // - Duration of workout (more time = more calories)
    // - Number of sets completed (more sets = more calories)
    // - Average person burns ~5-8 calories per minute during strength training
    
    final baseCaloriesPerMinute = 6.5; // Average for strength training
    final caloriesPerSet = 15; // Additional calories per set completed
    
    final timeCalories = duration.inMinutes * baseCaloriesPerMinute;
    final setCalories = totalSets * caloriesPerSet;
    
    return timeCalories + setCalories;
  }

  // Get training completion summary
  TrainingCompletionSummary? getCompletionSummary() {
    if (!_isCompleted || _session == null) return null;

    final duration = DateTime.now().difference(_startTime);
    final totalExercises = _session!.exercises.length;
    final completedExercises = _session!.exercises
        .where((exercise) => exercise.isCompleted)
        .length;
    final totalSets = _getTotalSetsCompleted();
    final caloriesBurned = _calculateCaloriesBurned(duration, totalSets);

    return TrainingCompletionSummary(
      duration: duration,
      totalExercises: totalExercises,
      completedExercises: completedExercises,
      totalSets: totalSets,
      caloriesBurned: caloriesBurned,
    );
  }

  // Get current exercise
  ExerciseSession? get currentExercise {
    if (_session == null || _currentExerciseIndex >= _session!.exercises.length) {
      return null;
    }
    return _session!.exercises[_currentExerciseIndex];
  }

  // Get current set
  SetSession? get currentSet {
    final exercise = currentExercise;
    if (exercise == null || _currentSetIndex >= exercise.setSessions.length) {
      return null;
    }
    return exercise.setSessions[_currentSetIndex];
  }

  // Get progress percentage
  double get progressPercentage {
    if (_session == null) return 0.0;
    
    final totalExercises = _session!.exercises.length;
    final completedExercises = _session!.exercises
        .where((exercise) => exercise.isCompleted)
        .length;
    
    return totalExercises > 0 ? completedExercises / totalExercises : 0.0;
  }

  // Dispose resources
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Private methods
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
}

// Data class for training completion summary
class TrainingCompletionSummary {
  final Duration duration;
  final int totalExercises;
  final int completedExercises;
  final int totalSets;
  final double caloriesBurned;

  TrainingCompletionSummary({
    required this.duration,
    required this.totalExercises,
    required this.completedExercises,
    required this.totalSets,
    required this.caloriesBurned,
  });
}

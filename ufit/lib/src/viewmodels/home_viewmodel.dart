import 'package:flutter/material.dart';
import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/repositories/training_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ITrainingRepository _trainingRepository;
  
  List<Training> _trainings = [];
  List<TrainingSession> _todaySessions = [];
  bool _isLoading = true;
  String? _errorMessage;

  HomeViewModel({ITrainingRepository? trainingRepository}) 
      : _trainingRepository = trainingRepository ?? TrainingRepository();

  // Getters
  List<Training> get trainings => _trainings;
  List<TrainingSession> get todaySessions => _todaySessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize data
  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      final trainings = await _trainingRepository.getTrainings();
      final todaySessions = await _trainingRepository.getSessionsForDate(DateTime.now());

      _trainings = trainings;
      _todaySessions = todaySessions;
    } catch (e) {
      _setError('Erro ao carregar dados: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }

  // Get training by ID
  Future<Training?> getTrainingById(String id) async {
    try {
      return await _trainingRepository.getTrainingById(id);
    } catch (e) {
      _setError('Erro ao buscar treino: $e');
      return null;
    }
  }

  // Get calendar data for current week
  List<CalendarDay> getCurrentWeekCalendar() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final daysOfWeek = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    List<CalendarDay> calendarDays = [];
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayName = daysOfWeek[i];
      final isToday = date.day == now.day && 
                     date.month == now.month && 
                     date.year == now.year;
      
      // Check if there are training sessions for this date
      final hasTraining = _todaySessions.any((session) =>
        session.date.day == date.day &&
        session.date.month == date.month &&
        session.date.year == date.year
      );

      calendarDays.add(CalendarDay(
        dayName: dayName,
        dayNumber: date.day,
        isToday: isToday,
        hasTraining: hasTraining,
      ));
    }

    return calendarDays;
  }

  // Private methods
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

// Data class for calendar days
class CalendarDay {
  final String dayName;
  final int dayNumber;
  final bool isToday;
  final bool hasTraining;

  CalendarDay({
    required this.dayName,
    required this.dayNumber,
    required this.isToday,
    required this.hasTraining,
  });
}

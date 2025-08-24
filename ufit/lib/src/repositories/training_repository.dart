import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/services/training_service.dart';

abstract class ITrainingRepository {
  Future<List<Training>> getTrainings();
  Future<Training?> getTrainingById(String id);
  Future<void> saveTraining(Training training);
  Future<void> deleteTraining(String id);
  Future<List<TrainingSession>> getTrainingSessions();
  Future<List<TrainingSession>> getSessionsForDate(DateTime date);
  Future<List<TrainingSession>> getSessionsForTraining(String trainingId);
  Future<void> saveTrainingSession(TrainingSession session);
  Future<void> updateTrainingSession(TrainingSession session);
  Future<void> clearAllData();
}

class TrainingRepository implements ITrainingRepository {
  @override
  Future<List<Training>> getTrainings() async {
    return await TrainingService.getTrainings();
  }

  @override
  Future<Training?> getTrainingById(String id) async {
    return await TrainingService.getTrainingById(id);
  }

  @override
  Future<void> saveTraining(Training training) async {
    await TrainingService.saveTraining(training);
  }

  @override
  Future<void> deleteTraining(String id) async {
    await TrainingService.deleteTraining(id);
  }

  @override
  Future<List<TrainingSession>> getTrainingSessions() async {
    return await TrainingService.getTrainingSessions();
  }

  @override
  Future<List<TrainingSession>> getSessionsForDate(DateTime date) async {
    return await TrainingService.getSessionsForDate(date);
  }

  @override
  Future<List<TrainingSession>> getSessionsForTraining(String trainingId) async {
    return await TrainingService.getSessionsForTraining(trainingId);
  }

  @override
  Future<void> saveTrainingSession(TrainingSession session) async {
    await TrainingService.saveTrainingSession(session);
  }

  @override
  Future<void> updateTrainingSession(TrainingSession session) async {
    await TrainingService.updateTrainingSession(session);
  }

  @override
  Future<void> clearAllData() async {
    await TrainingService.clearAllData();
  }
}

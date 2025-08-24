import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/services/training_service.dart';
import 'package:ufit/src/services/user_preferences_service.dart';

class TrainingExecutionPage extends StatefulWidget {
  final TrainingSession session;

  const TrainingExecutionPage({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  State<TrainingExecutionPage> createState() => _TrainingExecutionPageState();
}

class _TrainingExecutionPageState extends State<TrainingExecutionPage> {
  Training? _training;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  bool _isResting = false;
  int _restTimer = 0;
  Timer? _timer;
  DateTime _startTime = DateTime.now();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadTraining();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTraining() async {
    final training = await TrainingService.getTrainingById(widget.session.trainingId);
    setState(() {
      _training = training;
    });
  }

  void _startRestTimer(int seconds) async {
    // Check if rest timer is enabled in user preferences
    final restTimerEnabled = await UserPreferencesService.getPreference<bool>(
      UserPreferencesService.restTimerEnabledKey,
      defaultValue: true,
    );

    if (restTimerEnabled == false) {
      // Skip rest timer if disabled
      return;
    }

    setState(() {
      _isResting = true;
      _restTimer = seconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restTimer--;
      });

      if (_restTimer <= 0) {
        timer.cancel();
        setState(() {
          _isResting = false;
        });
      }
    });
  }

  void _completeSet() {
    if (_training == null) return;

    final currentExercise = widget.session.exercises[_currentExerciseIndex];
    final currentSet = currentExercise.setSessions[_currentSetIndex];

    // Mark set as completed
    currentSet.isCompleted = true;
    currentSet.completedAt = DateTime.now();

    // Check if we need to move to next set or exercise
    if (_currentSetIndex < currentExercise.sets - 1) {
      // Move to next set
      _currentSetIndex++;
      _startRestTimer(currentExercise.restSeconds);
    } else {
      // Exercise completed, move to next exercise
      currentExercise.isCompleted = true;
      
      if (_currentExerciseIndex < widget.session.exercises.length - 1) {
        // Move to next exercise
        _currentExerciseIndex++;
        _currentSetIndex = 0;
        final nextExercise = widget.session.exercises[_currentExerciseIndex];
        _startRestTimer(nextExercise.restSeconds);
      } else {
        // Training completed
        _completeTraining();
      }
    }

    // Save session
    TrainingService.updateTrainingSession(widget.session);
  }

  void _completeTraining() {
    final duration = DateTime.now().difference(_startTime);
    final totalSets = _getTotalSetsCompleted();
    final caloriesBurned = _calculateCaloriesBurned(duration, totalSets);

    setState(() {
      _isCompleted = true;
    });

    // Save completion data to session
    widget.session.isCompleted = true;
    widget.session.completedAt = DateTime.now();
    widget.session.actualDuration = duration.inMinutes;
    widget.session.totalSets = totalSets;
    widget.session.caloriesBurned = caloriesBurned;
    
    TrainingService.updateTrainingSession(widget.session);

    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    final duration = DateTime.now().difference(_startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final totalExercises = widget.session.exercises.length;
    final completedExercises = widget.session.exercises
        .where((exercise) => exercise.isCompleted)
        .length;
    final totalSets = _getTotalSetsCompleted();
    final caloriesBurned = _calculateCaloriesBurned(duration, totalSets);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Treino Concluído! 🎉'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              
              // Time and duration
              _buildSummaryCard(
                icon: Icons.timer,
                title: 'Tempo Total',
                value: '${minutes}min ${seconds}s',
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              
              // Exercises completed
              _buildSummaryCard(
                icon: Icons.fitness_center,
                title: 'Exercícios',
                value: '$completedExercises/$totalExercises',
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              
              // Sets completed
              _buildSummaryCard(
                icon: Icons.repeat,
                title: 'Sets Completados',
                value: '$totalSets',
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              
              // Calories burned
              _buildSummaryCard(
                icon: Icons.local_fire_department,
                title: 'Calorias Queimadas',
                value: '${caloriesBurned.toStringAsFixed(0)} kcal',
                color: Colors.red,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to agenda
            },
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  int _getTotalSetsCompleted() {
    int total = 0;
    for (var exercise in widget.session.exercises) {
      for (var set in exercise.setSessions) {
        if (set.isCompleted) total++;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_training == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isCompleted) {
      final duration = DateTime.now().difference(_startTime);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      final totalExercises = widget.session.exercises.length;
      final completedExercises = widget.session.exercises
          .where((exercise) => exercise.isCompleted)
          .length;
      final totalSets = _getTotalSetsCompleted();
      final caloriesBurned = _calculateCaloriesBurned(duration, totalSets);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Treino Concluído'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Congratulations header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Parabéns! 🎉',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Treino concluído com sucesso!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Summary cards
              _buildSummaryCard(
                icon: Icons.timer,
                title: 'Tempo Total',
                value: '${minutes}min ${seconds}s',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              
              _buildSummaryCard(
                icon: Icons.fitness_center,
                title: 'Exercícios',
                value: '$completedExercises/$totalExercises',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              
              _buildSummaryCard(
                icon: Icons.repeat,
                title: 'Sets Completados',
                value: '$totalSets',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              
              _buildSummaryCard(
                icon: Icons.local_fire_department,
                title: 'Calorias Queimadas',
                value: '${caloriesBurned.toStringAsFixed(0)} kcal',
                color: Colors.red,
              ),
              const SizedBox(height: 32),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Voltar ao Início'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentExercise = widget.session.exercises[_currentExerciseIndex];
    final currentSet = currentExercise.setSessions[_currentSetIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(_training!.name),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _showProgress,
            child: const Text(
              'Progresso',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Current exercise info
          _buildCurrentExerciseInfo(currentExercise),
          
          // Rest timer or set completion
          if (_isResting) _buildRestTimer() else _buildSetCompletion(currentSet),
          
          // Exercise list
          Expanded(child: _buildExerciseList()),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalExercises = widget.session.exercises.length;
    final completedExercises = widget.session.exercises
        .where((exercise) => exercise.isCompleted)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Exercício ${_currentExerciseIndex + 1} de $totalExercises'),
              Text('${completedExercises}/$totalExercises completados'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: totalExercises > 0 ? completedExercises / totalExercises : 0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExerciseInfo(ExerciseSession exercise) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Text(
            exercise.exerciseName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoChip('Sets', '${exercise.sets}'),
              _buildInfoChip('Reps', '${exercise.reps}'),
              _buildInfoChip('Descanso', '${exercise.restSeconds}s'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimer() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.timer,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Descanso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_restTimer',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          const Text('segundos'),
        ],
      ),
    );
  }

  Widget _buildSetCompletion(SetSession set) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Set ${set.setNumber}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _completeSet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Completar Set',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.session.exercises.length,
      itemBuilder: (context, index) {
        final exercise = widget.session.exercises[index];
        final isCurrent = index == _currentExerciseIndex;
        final isCompleted = exercise.isCompleted;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isCurrent ? Colors.blue[50] : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCompleted 
                  ? Colors.green 
                  : isCurrent 
                      ? Colors.blue 
                      : Colors.grey,
              child: Icon(
                isCompleted ? Icons.check : Icons.fitness_center,
                color: Colors.white,
              ),
            ),
            title: Text(
              exercise.exerciseName,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              '${exercise.sets} sets × ${exercise.reps} reps',
            ),
            trailing: isCurrent 
                ? const Icon(Icons.play_arrow, color: Colors.blue)
                : null,
          ),
        );
      },
    );
  }

  void _showProgress() {
    final duration = DateTime.now().difference(_startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final totalExercises = widget.session.exercises.length;
    final completedExercises = widget.session.exercises
        .where((exercise) => exercise.isCompleted)
        .length;
    final totalSets = _getTotalSetsCompleted();
    final caloriesBurned = _calculateCaloriesBurned(duration, totalSets);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Progresso do Treino'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProgressSummaryCard(
              icon: Icons.fitness_center,
              title: 'Exercícios',
              value: '${_currentExerciseIndex + 1}/$totalExercises',
              subtitle: '$completedExercises completados',
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildProgressSummaryCard(
              icon: Icons.repeat,
              title: 'Sets',
              value: '$totalSets',
              subtitle: 'completados',
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            _buildProgressSummaryCard(
              icon: Icons.timer,
              title: 'Tempo',
              value: '${minutes}min ${seconds}s',
              subtitle: 'de treino',
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildProgressSummaryCard(
              icon: Icons.local_fire_department,
              title: 'Calorias',
              value: '${caloriesBurned.toStringAsFixed(0)} kcal',
              subtitle: 'queimadas',
              color: Colors.red,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

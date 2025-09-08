import 'package:flutter/material.dart';
import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/services/training_service.dart';
import 'package:ufit/src/pages/training_execution_page.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({Key? key}) : super(key: key);

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _selectedDate = DateTime.now();
  List<Training> _trainings = [];
  List<TrainingSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final trainings = await TrainingService.getTrainings();
    final sessions = await TrainingService.getSessionsForDate(_selectedDate);

    setState(() {
      _trainings = trainings;
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agenda de Treinos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        titleSpacing: 20.0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendar(),
                const SizedBox(height: 16),
                _buildSessionsList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(),
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
            });
            _loadData();
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
            });
            _loadData();
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysOfWeek = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    
    final firstDisplayDay = startOfMonth.subtract(
      Duration(days: startOfMonth.weekday - 1)
    );
    
    final lastDisplayDay = endOfMonth.add(
      Duration(days: 7 - endOfMonth.weekday)
    );
    
    final daysToShow = lastDisplayDay.difference(firstDisplayDay).inDays + 1;

    return Column(
      children: [
        // Days of week header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysOfWeek.map((day) => 
            SizedBox(
              width: 40,
              child: Text(
                day,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ).toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: daysToShow,
          itemBuilder: (context, index) {
            final date = firstDisplayDay.add(Duration(days: index));
            final isCurrentMonth = date.month == _selectedDate.month;
            final isSelected = date.day == _selectedDate.day && 
                             date.month == _selectedDate.month && 
                             date.year == _selectedDate.year;
            final isToday = date.day == DateTime.now().day && 
                           date.month == DateTime.now().month && 
                           date.year == DateTime.now().year;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                _loadData();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Colors.blue.withOpacity(0.2)
                    : isToday 
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected 
                    ? Border.all(color: Colors.blue, width: 2)
                    : isToday 
                      ? Border.all(color: Colors.orange, width: 1)
                      : null,
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentMonth 
                        ? (isSelected ? Colors.blue : Colors.black)
                        : Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSessionsList() {
    if (_sessions.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum treino agendado\npara ${_getDayName(_selectedDate)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showScheduleDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Agendar Treino'),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return _buildSessionCard(session);
        },
      ),
    );
  }

  Widget _buildSessionCard(TrainingSession session) {
    return FutureBuilder<Training?>(
      future: TrainingService.getTrainingById(session.trainingId),
      builder: (context, snapshot) {
        final training = snapshot.data;
        if (training == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[800],
              child: Icon(
                Icons.fitness_center,
                color: Colors.white,
              ),
            ),
            title: Text(
              training.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${training.type} • ${training.duration}min'),
                Text('${training.exercises.length} exercícios'),
              ],
            ),
            trailing: session.isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _startTraining(session),
                  ),
            onTap: () => _startTraining(session),
          ),
        );
      },
    );
  }

  void _showScheduleDialog() {
    if (_trainings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa criar um treino primeiro!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agendar Treino'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecione um treino para agendar:'),
            const SizedBox(height: 16),
            ...(_trainings.map((training) => ListTile(
              title: Text(training.name),
              subtitle: Text('${training.type} • ${training.duration}min'),
              onTap: () {
                Navigator.pop(context);
                _scheduleTraining(training);
              },
            )).toList()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _scheduleTraining(Training training) async {
    final session = TrainingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      trainingId: training.id,
      date: _selectedDate,
      duration: training.duration,
      exercises: training.exercises.map((exercise) => ExerciseSession(
        exerciseName: exercise.name,
        sets: exercise.sets,
        reps: exercise.reps,
        restSeconds: exercise.restSeconds,
        setSessions: List.generate(exercise.sets, (index) => SetSession(
          setNumber: index + 1,
          reps: exercise.reps,
        )),
      )).toList(),
    );

    await TrainingService.saveTrainingSession(session);
    _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Treino "${training.name}" agendado para ${_getDayName(_selectedDate)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startTraining(TrainingSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingExecutionPage(session: session),
      ),
    ).then((_) => _loadData());
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  String _getDayName(DateTime date) {
    const days = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    return days[date.weekday - 1];
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ufit/src/viewmodels/home_viewmodel.dart';
import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/pages/agenda_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.loadData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.errorMessage != null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Início'),
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.refreshData(),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Build calendar days
          final calendarDays = viewModel.getCurrentWeekCalendar()
              .map((day) => _buildDayWithDate(
                    day.dayName,
                    day.dayNumber,
                    isToday: day.isToday,
                    hasTraining: day.hasTraining,
                  ))
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Início',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              titleSpacing: 20.0,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendário dinâmico
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: calendarDays,
                    ),
                    const SizedBox(height: 32.0),
                    
                    // Today's trainings
                    if (viewModel.todaySessions.isNotEmpty) ...[
                      const Text(
                        'Treinos de Hoje',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16.0),
                      _buildTodayTrainings(viewModel),
                      const SizedBox(height: 32.0),
                    ],

                    // Available trainings
                    const Text(
                      'Seus Treinos',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16.0),
                    _buildAvailableTrainings(viewModel),
                    const SizedBox(height: 32.0),

                    // Título "Sua atividade"
                    const Text(
                      'Sua atividade',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16.0),
                    // Card "Início fácil"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Início fácil:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'em casa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 32.0),
              // Título "Desafio"
              const Text(
                'Desafio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16.0),
              // Card "Rotina matinal"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rotina',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'matinal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      '0/7 dias',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'INICIAR',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
        },
      ),
    );
  }

  Widget _buildDayWithDate(String day, int date, {bool isToday = false, bool hasTraining = false}) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isToday ? Colors.blue : Colors.black,
            fontSize: 16,
          ),
        ),
        Text(
          date.toString(),
          style: TextStyle(
            color: isToday ? Colors.blue : Colors.black,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTrainings(HomeViewModel viewModel) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.todaySessions.length,
        itemBuilder: (context, index) {
          final session = viewModel.todaySessions[index];
          return FutureBuilder<Training?>(
            future: viewModel.getTrainingById(session.trainingId),
            builder: (context, snapshot) {
              final training = snapshot.data;
              if (training == null) return const SizedBox.shrink();

              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: session.isCompleted ? Colors.green : Colors.blue[800],
                      child: Icon(
                        session.isCompleted ? Icons.check : Icons.fitness_center,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      training.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      session.isCompleted 
                        ? 'Concluído • ${session.caloriesBurned?.toStringAsFixed(0) ?? '0'} kcal'
                        : '${training.duration}min',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AgendaPage(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAvailableTrainings(HomeViewModel viewModel) {
    if (viewModel.trainings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino criado ainda',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie seu primeiro treino na aba "Treinos"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.trainings.length,
        itemBuilder: (context, index) {
          final training = viewModel.trainings[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${training.type} • ${training.duration}min',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgendaPage(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

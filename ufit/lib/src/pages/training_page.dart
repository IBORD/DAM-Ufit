import 'package:flutter/material.dart';
import 'package:ufit/src/pages/equipment_page.dart';
import 'package:ufit/src/pages/create_training.dart';
import 'package:ufit/src/services/training_service.dart';
import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/pages/training_execution_page.dart'; // certifique-se que essa página exista

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  bool _isWarmupEnabled = false;
  DateTime _selectedDate = DateTime.now();
  List<Equipamento> _equipamentosSelecionados = [];
  List<Training> _trainings = [];

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    final trainings = await TrainingService.getTrainings();
    setState(() {
      _trainings = trainings;
    });
  }

  void _startTraining(TrainingSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingExecutionPage(session: session),
      ),
    ).then((_) => _loadTrainings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TREINO PERSONALIZADO',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        titleSpacing: 20.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Com base nas suas preferências',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16.0),
              _buildStats(),
              const SizedBox(height: 64.0),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('36min', 'Duração'),
          _buildStatColumn('139', 'Calorias'),
          _buildStatColumn('22', 'Exercícios'),
        ],
      ),
    );
  }

  static Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Equipamentos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const Text(
          'Adicionar equipamentos irá ajudar a variá-los seu treino',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EquipmentPage(),
                ),
              );

              if (resultado != null && resultado is List<Equipamento>) {
                setState(() {
                  _equipamentosSelecionados = resultado;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ADICIONAR EQUIPAMENTO'),
          ),
        ),
      ],
    );
  }

  Widget _buildWarmupSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AQUECIMENTO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '+3 minutos antes do treino',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        Switch(
          value: _isWarmupEnabled,
          onChanged: (bool value) {
            setState(() {
              _isWarmupEnabled = value;
            });
          },
          activeColor: Colors.blue[800],
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {
            _showTrainingsModal();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('INICIAR'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateTrainingPage(
                  equipamentosSelecionados: _equipamentosSelecionados,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue[800],
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.blue.shade800),
            ),
          ),
          child: const Text('CRIAR TREINO'),
        ),
      ],
    );
  }

  void _showTrainingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        if (_trainings.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Nenhum treino disponível',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          );
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: _trainings.length,
            itemBuilder: (context, index) {
              final training = _trainings[index];
              return ListTile(
                title: Text(training.name),
                subtitle: Text('${training.type} • ${training.duration}min'),
                leading: const Icon(Icons.fitness_center, color: Colors.blue),
                onTap: () async {
                  Navigator.pop(context); // fecha o modal

                  // Criar sessão de treino
                  final session =  TrainingSession(
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

                  // Abrir tela de execução do treino
                  _startTraining(session);
                },
              );
            },
          ),
        );
      },
    );
  }
}

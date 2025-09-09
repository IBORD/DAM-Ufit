import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufit/src/models/training_model.dart';

// Widget customizado para lista de exercícios
class ExerciseList extends StatelessWidget {
  final List<Exercise> exercises;
  final Function(Exercise)? onExerciseTap;
  final bool showCompleted;

  const ExerciseList({
    super.key,
    required this.exercises,
    this.onExerciseTap,
    this.showCompleted = true,
  });

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return const Center(
        child: Text('Nenhum exercício encontrado'),
      );
    }

    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ExerciseCard(
          exercise: exercise,
          onTap: onExerciseTap != null ? () => onExerciseTap!(exercise) : null,
        );
      },
    );
  }
}

// Widget para card de exercício
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(exercise.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.description),
            const SizedBox(height: 4),
            Text('${exercise.sets} séries x ${exercise.reps} repetições'),
            if (exercise.equipment != null)
              Text('Equipamento: ${exercise.equipment}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${exercise.restSeconds}s'),
            const Text('descanso'),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

void main() {
  group('ExerciseList Widget Tests', () {
    late List<Exercise> sampleExercises;

    setUp(() {
      sampleExercises = [
        Exercise(
          name: 'Flexão de Braço',
          description: 'Exercício para peitoral',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          equipment: 'Nenhum',
          category: 'Superiores',
        ),
        Exercise(
          name: 'Agachamento',
          description: 'Exercício para pernas',
          sets: 4,
          reps: 15,
          restSeconds: 90,
          equipment: 'Nenhum',
          category: 'Inferiores',
        ),
        Exercise(
          name: 'Prancha',
          description: 'Exercício para core',
          sets: 3,
          reps: 30,
          restSeconds: 30,
          equipment: 'Nenhum',
          category: 'Abs',
        ),
      ];
    });

    testWidgets('should display list of exercises', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseList(
              exercises: sampleExercises,
            ),
          ),
        ),
      );

      expect(find.text('Flexão de Braço'), findsOneWidget);
      expect(find.text('Agachamento'), findsOneWidget);
      expect(find.text('Prancha'), findsOneWidget);
      expect(find.byType(ExerciseCard), findsNWidgets(3));
    });

    testWidgets('should display empty message when no exercises', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseList(
              exercises: [],
            ),
          ),
        ),
      );

      expect(find.text('Nenhum exercício encontrado'), findsOneWidget);
      expect(find.byType(ExerciseCard), findsNothing);
    });

    testWidgets('should call onExerciseTap when exercise is tapped', (WidgetTester tester) async {
      Exercise? tappedExercise;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseList(
              exercises: sampleExercises,
              onExerciseTap: (exercise) {
                tappedExercise = exercise;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Flexão de Braço'));
      await tester.pump();

      expect(tappedExercise, isNotNull);
      expect(tappedExercise!.name, 'Flexão de Braço');
    });

    testWidgets('should display exercise details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseList(
              exercises: [sampleExercises.first],
            ),
          ),
        ),
      );

      // Check exercise name
      expect(find.text('Flexão de Braço'), findsOneWidget);
      
      // Check description
      expect(find.text('Exercício para peitoral'), findsOneWidget);
      
      // Check sets and reps
      expect(find.text('3 séries x 12 repetições'), findsOneWidget);
      
      // Check equipment
      expect(find.text('Equipamento: Nenhum'), findsOneWidget);
      
      // Check rest time
      expect(find.text('60s'), findsOneWidget);
      expect(find.text('descanso'), findsOneWidget);
    });

    testWidgets('should handle exercise without equipment', (WidgetTester tester) async {
      final exerciseWithoutEquipment = Exercise(
        name: 'Exercício sem equipamento',
        description: 'Descrição do exercício',
        sets: 2,
        reps: 10,
        restSeconds: 45,
        equipment: null,
        category: 'Teste',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseList(
              exercises: [exerciseWithoutEquipment],
            ),
          ),
        ),
      );

      expect(find.text('Exercício sem equipamento'), findsOneWidget);
      expect(find.text('Equipamento: null'), findsNothing);
    });

    testWidgets('should scroll through exercises', (WidgetTester tester) async {
      // Create a long list of exercises
      final longExerciseList = List.generate(10, (index) => Exercise(
        name: 'Exercício ${index + 1}',
        description: 'Descrição do exercício ${index + 1}',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        equipment: 'Nenhum',
        category: 'Teste',
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseList(
              exercises: longExerciseList,
            ),
          ),
        ),
      );

      // Check that first exercise is visible
      expect(find.text('Exercício 1'), findsOneWidget);
      
      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      
      // Check that later exercises are visible
      expect(find.text('Exercício 5'), findsOneWidget);
    });

    testWidgets('should handle multiple taps on different exercises', (WidgetTester tester) async {
      final List<Exercise> tappedExercises = [];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseList(
              exercises: sampleExercises,
              onExerciseTap: (exercise) {
                tappedExercises.add(exercise);
              },
            ),
          ),
        ),
      );

      // Tap first exercise
      await tester.tap(find.text('Flexão de Braço'));
      await tester.pump();
      
      // Tap second exercise
      await tester.tap(find.text('Agachamento'));
      await tester.pump();
      
      // Tap third exercise
      await tester.tap(find.text('Prancha'));
      await tester.pump();

      expect(tappedExercises.length, 3);
      expect(tappedExercises[0].name, 'Flexão de Braço');
      expect(tappedExercises[1].name, 'Agachamento');
      expect(tappedExercises[2].name, 'Prancha');
    });

    testWidgets('should display correct card styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseList(
              exercises: [sampleExercises.first],
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should work with different themes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.green,
            brightness: Brightness.light,
          ),
          home: Scaffold(
            body: ExerciseList(
              exercises: [sampleExercises.first],
            ),
          ),
        ),
      );

      expect(find.text('Flexão de Braço'), findsOneWidget);
      expect(find.byType(ExerciseCard), findsOneWidget);
    });
  });

  group('ExerciseCard Widget Tests', () {
    late Exercise sampleExercise;

    setUp(() {
      sampleExercise = Exercise(
        name: 'Teste Exercício',
        description: 'Descrição do teste',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        equipment: 'Halteres',
        category: 'Teste',
      );
    });

    testWidgets('should display exercise information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseCard(
              exercise: sampleExercise,
            ),
          ),
        ),
      );

      expect(find.text('Teste Exercício'), findsOneWidget);
      expect(find.text('Descrição do teste'), findsOneWidget);
      expect(find.text('3 séries x 12 repetições'), findsOneWidget);
      expect(find.text('Equipamento: Halteres'), findsOneWidget);
      expect(find.text('60s'), findsOneWidget);
      expect(find.text('descanso'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool wasTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseCard(
              exercise: sampleExercise,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ExerciseCard));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('should not call onTap when onTap is null', (WidgetTester tester) async {
      bool wasTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseCard(
              exercise: sampleExercise,
              onTap: null,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ExerciseCard));
      await tester.pump();

      expect(wasTapped, false);
    });
  });
}

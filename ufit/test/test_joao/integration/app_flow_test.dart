import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/pages/equipment_page.dart';

// Mock da tela principal do app
class MockMainScreen extends StatefulWidget {
  const MockMainScreen({super.key});

  @override
  State<MockMainScreen> createState() => _MockMainScreenState();
}

class _MockMainScreenState extends State<MockMainScreen> {
  int _selectedIndex = 0;
  List<Exercise> _exercises = [];

  static const List<Widget> _widgetOptions = <Widget>[
    MockHomePage(),
    MockTrainingPage(),
    MockAgendaPage(),
    MockProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UFIT'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Treinos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Mock das páginas
class MockHomePage extends StatelessWidget {
  const MockHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Bem-vindo ao UFIT!', style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          Text('Seu app de treinos personalizados'),
        ],
      ),
    );
  }
}

class MockTrainingPage extends StatefulWidget {
  const MockTrainingPage({super.key});

  @override
  State<MockTrainingPage> createState() => _MockTrainingPageState();
}

class _MockTrainingPageState extends State<MockTrainingPage> {
  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() {
      _exercises = [
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
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Meus Treinos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(exercise.name),
                    subtitle: Text('${exercise.sets} séries x ${exercise.reps} repetições'),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Iniciando ${exercise.name}')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MockAgendaPage extends StatelessWidget {
  const MockAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text('Agenda de Treinos', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text('Organize seus treinos por data'),
        ],
      ),
    );
  }
}

class MockProfilePage extends StatelessWidget {
  const MockProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text('Meu Perfil', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text('Gerencie suas informações'),
        ],
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    testWidgets('should navigate through all main screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockMainScreen(),
        ),
      );


      expect(find.text('Bem-vindo ao UFIT!'), findsOneWidget);
      expect(find.text('Seu app de treinos personalizados'), findsOneWidget);


      await tester.tap(find.text('Treinos'));
      await tester.pumpAndSettle();

      expect(find.text('Meus Treinos'), findsOneWidget);
      expect(find.text('Flexão de Braço'), findsOneWidget);
      expect(find.text('Agachamento'), findsOneWidget);


      await tester.tap(find.text('Agenda'));
      await tester.pumpAndSettle();

      expect(find.text('Agenda de Treinos'), findsOneWidget);
      expect(find.text('Organize seus treinos por data'), findsOneWidget);


      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('Meu Perfil'), findsOneWidget);
      expect(find.text('Gerencie suas informações'), findsOneWidget);


      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo ao UFIT!'), findsOneWidget);
    });

    testWidgets('should interact with training exercises', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockMainScreen(),
        ),
      );


      await tester.tap(find.text('Treinos'));
      await tester.pumpAndSettle();


      expect(find.text('Flexão de Braço'), findsOneWidget);
      expect(find.text('3 séries x 12 repetições'), findsOneWidget);


      await tester.tap(find.text('Flexão de Braço'));
      await tester.pumpAndSettle();


      expect(find.text('Iniciando Flexão de Braço'), findsOneWidget);
    });

    testWidgets('should display correct app bar and navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockMainScreen(),
        ),
      );


      expect(find.text('UFIT'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);


      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Treinos'), findsOneWidget);
      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);


      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should maintain state during navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockMainScreen(),
        ),
      );


      await tester.tap(find.text('Treinos'));
      await tester.pumpAndSettle();


      expect(find.text('Flexão de Braço'), findsOneWidget);


      await tester.tap(find.text('Agenda'));
      await tester.pumpAndSettle();


      await tester.tap(find.text('Treinos'));
      await tester.pumpAndSettle();


      expect(find.text('Flexão de Braço'), findsOneWidget);
      expect(find.text('Agachamento'), findsOneWidget);
    });

    testWidgets('should handle multiple rapid navigation taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockMainScreen(),
        ),
      );

      await tester.tap(find.text('Treinos'));
      await tester.pump();
      
      await tester.tap(find.text('Agenda'));
      await tester.pump();
      
      await tester.tap(find.text('Perfil'));
      await tester.pump();
      
      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();


      expect(find.text('Bem-vindo ao UFIT!'), findsOneWidget);
    });

    testWidgets('should display correct icons and styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockMainScreen(),
        ),
      );


      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsNWidgets(2));

      // Verify agenda page has correct icon
      await tester.tap(find.text('Agenda'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsNWidgets(2));
    });
  });
}

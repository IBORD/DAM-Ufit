import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ufit/src/models/training_model.dart';
import 'package:ufit/src/pages/home_page.dart';
import 'package:ufit/src/viewmodels/home_viewmodel.dart';

@GenerateMocks([HomeViewModel])
import 'home_page_test.mocks.dart';

void main() {
  late MockHomeViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockHomeViewModel();
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.errorMessage).thenReturn(null);
    when(mockViewModel.trainings).thenReturn([]);
    when(mockViewModel.todaySessions).thenReturn([]);
    when(mockViewModel.getCurrentWeekCalendar()).thenReturn([]);
    when(mockViewModel.addListener(any)).thenReturn(null);
  });

  Future<void> pumpHomePage(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<HomeViewModel>.value(
        value: mockViewModel,
        child: const MaterialApp(home: HomePage()),
      ),
    );
  }

  testWidgets('HomePage should display loading indicator when loading', (
    WidgetTester tester,
  ) async {
    when(mockViewModel.isLoading).thenReturn(true);

    await pumpHomePage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomePage should display main content when data is loaded', (
    WidgetTester tester,
  ) async {
    final training = Training(
      id: '1',
      name: 'Treino A',
      type: 'FORÇA',
      location: 'ACADEMIA',
      duration: 60,
      targetAreas: ['Superiores'],
      equipment: [],
      exercises: [],
      createdAt: DateTime.now(),
    );

    final session = TrainingSession(
      id: 's1',
      trainingId: '1',
      date: DateTime.now(),
      duration: 60,
      exercises: [],
    );

    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.trainings).thenReturn([training]);
    when(mockViewModel.todaySessions).thenReturn([session]);
    when(mockViewModel.getTrainingById('1')).thenAnswer((_) async => training);

    await pumpHomePage(tester);
    await tester.pump();

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Seus Treinos'), findsOneWidget);
    expect(find.text('Treinos de Hoje'), findsOneWidget);
    expect(find.text('Treino A'), findsNWidgets(2));
  });

  testWidgets('HomePage should display error message on error', (
    WidgetTester tester,
  ) async {
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.errorMessage).thenReturn('Falha ao carregar dados');

    await pumpHomePage(tester);
    await tester.pump();

    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.text('Falha ao carregar dados'), findsOneWidget);
    expect(find.text('Tentar Novamente'), findsOneWidget);
  });
}

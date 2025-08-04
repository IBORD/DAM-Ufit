import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém o dia atual
    final now = DateTime.now();
    final today = now.day;
    final weekday = now.weekday;

    // Constrói a lista de widgets para o calendário de forma dinâmica
    final List<Widget> calendarDays = [];
    final daysOfWeek = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    // Encontra o primeiro dia da semana (segunda-feira)
    final startOfWeek = now.subtract(Duration(days: weekday - 1));

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayName = daysOfWeek[i];
      final isToday = date.day == today && date.month == now.month && date.year == now.year;

      calendarDays.add(_buildDayWithDate(dayName, date.day, isToday: isToday));
    }

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
                    const SizedBox(height: 8.0),
                    const Text(
                      'Personalizado para você',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const Text(
                      'tempo estimado: 3min',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('INICIAR', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
                      child: const Text('INICIAR', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayWithDate(String day, int date, {bool isToday = false}) {
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
}
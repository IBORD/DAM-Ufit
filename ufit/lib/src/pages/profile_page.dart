import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ufit/src/pages/auth.pages/auth_service.dart';
import 'package:ufit/src/pages/auth.pages/user_service.dart';
import 'package:ufit/src/pages/register_pages/log_in_page.dart';
import 'package:ufit/src/pages/training_page.dart';
import 'package:ufit/src/services/training_service.dart';
import 'package:ufit/src/pages/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User data
  String userName = 'Usuário';
  final int totalActivities = 24;
  final int totalMinutes = 720; // 12 hours total
  final List<DateTime> trainingDays = [
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now().subtract(const Duration(days: 3)),
    DateTime.now().subtract(const Duration(days: 5)),
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now().subtract(const Duration(days: 10)),
    DateTime.now().subtract(const Duration(days: 12)),
    DateTime.now().subtract(const Duration(days: 15)),
    DateTime.now().subtract(const Duration(days: 18)),
    DateTime.now().subtract(const Duration(days: 20)),
    DateTime.now().subtract(const Duration(days: 22)),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserService.getUserData();
    if (userData != null && userData.nome.isNotEmpty) {
      setState(() {
        userName = userData.nome;
      });
    }
  }

  Future<void> _logOut(BuildContext context) async {
    try {
      await authService.value.signOut();
      await UserService.clearUserData();
      await TrainingService.clearAllData();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        titleSpacing: 20.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logOut(context),
            tooltip: 'Sair da conta',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              _buildUserInfoCard(),
              const SizedBox(height: 24.0),

              // Statistics Cards
              _buildStatisticsSection(),
              const SizedBox(height: 24.0),

              // Quick Training Button
              _buildQuickTrainingButton(),
              const SizedBox(height: 24.0),

              // Training Calendar
              _buildTrainingCalendar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suas Estatísticas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.fitness_center,
                value: totalActivities.toString(),
                label: 'Atividades',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildStatCard(
                icon: Icons.timer,
                value: '${totalMinutes}min',
                label: 'Tempo Total',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                value: trainingDays.length.toString(),
                label: 'Dias Treinados',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                value: '${(totalMinutes / trainingDays.length).round()}min',
                label: 'Média/Dia',
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
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
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTrainingButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[600]!, Colors.orange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pronto para treinar?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Acesse seus treinos personalizados',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TrainingPage(),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('IR PARA TREINOS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange[600],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calendário de Treinos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16.0),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
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
              const SizedBox(height: 16.0),
              _buildCalendarGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    final daysOfWeek = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return Row(
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
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // Find the first day to display (Monday of the week containing the 1st)
    final firstDisplayDay = startOfMonth.subtract(
      Duration(days: startOfMonth.weekday - 1)
    );
    
    // Find the last day to display (Sunday of the week containing the last day)
    final lastDisplayDay = endOfMonth.add(
      Duration(days: 7 - endOfMonth.weekday)
    );
    
    final daysToShow = lastDisplayDay.difference(firstDisplayDay).inDays + 1;
    
    return GridView.builder(
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
        final isCurrentMonth = date.month == now.month;
        final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
        final hasTrained = trainingDays.any((trainingDay) => 
          trainingDay.day == date.day && 
          trainingDay.month == date.month && 
          trainingDay.year == date.year
        );
        
        return Container(
          decoration: BoxDecoration(
            color: hasTrained 
              ? Colors.green.withOpacity(0.2)
              : isToday 
                ? Colors.blue.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: hasTrained 
              ? Border.all(color: Colors.green, width: 2)
              : isToday 
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentMonth 
                      ? (hasTrained ? Colors.green : Colors.black)
                      : Colors.grey,
                  ),
                ),
                if (hasTrained)
                  const Icon(
                    Icons.fitness_center,
                    size: 12,
                    color: Colors.green,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Keep the original SignOutPage for backward compatibility
class SignOutPage extends StatelessWidget {
  const SignOutPage({Key? key}) : super(key: key);

  Future<void> _logOut(BuildContext context) async {
    try {
      await authService.value.signOut();
      await UserService.clearUserData();
      if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      }
    } on FirebaseAuthException catch (e) {
      print("Erro ao fazer logout: $e");
      if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer logout: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sair da Conta'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _logOut(context),
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

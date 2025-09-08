import 'package:flutter/material.dart';
import 'package:ufit/src/services/daily_challenge_service.dart';

class DailyChallengePage extends StatefulWidget {
  const DailyChallengePage({super.key});

  @override
  State<DailyChallengePage> createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends State<DailyChallengePage> {
  bool _isCompleted = false;
  String _challenge = 'Carregando desafio...';

  @override
  void initState() {
    super.initState();
    _loadChallenge();
    _checkChallengeStatus();
  }

  Future<void> _loadChallenge() async {
    final challenge = await DailyChallengeService.getDailyChallenge();
    if (mounted) {
      setState(() {
        _challenge = challenge;
      });
    }
  }

  Future<void> _checkChallengeStatus() async {
    final completed = await DailyChallengeService.isChallengeCompletedToday();
    if (mounted) {
      setState(() {
        _isCompleted = completed;
      });
    }
  }

  Future<void> _completeChallenge() async {
    await DailyChallengeService.completeChallenge();
    if (mounted) {
      setState(() {
        _isCompleted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desafio diário concluído! Parabéns!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desafio Diário'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 80, color: Colors.blue[800]),
              const SizedBox(height: 24),
              const Text(
                'Seu desafio de hoje é:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _challenge,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCompleted ? null : _completeChallenge,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(
                    _isCompleted ? 'DESAFIO CONCLUÍDO' : 'MARCAR COMO FEITO',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              if (_isCompleted)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Você já completou o desafio de hoje. Volte amanhã!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

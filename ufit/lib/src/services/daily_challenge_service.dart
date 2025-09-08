import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class DailyChallengeService {
  static const String _challengeDateKey = 'daily_challenge_date';
  static const String _challengeProgressKey = 'daily_challenge_progress';
  static const String _challengeWeekKey = 'daily_challenge_week';
  static const String _currentChallengeKey = 'current_daily_challenge';
  static const String _challengeSelectionDateKey = 'challenge_selection_date';

  static final List<String> _challenges = [
    '10 Flexões',
    '20 Agachamentos',
    '30 Segundos de Prancha',
    '15 Abdominais',
    '10 Burpees',
    '20 Polichinelos',
    '1 minuto de Corrida no Lugar',
    '15 Elevações de Panturrilha',
    '10 Afundos (cada perna)',
    '20 Saltos no lugar',
    '15 Abdominais bicicleta',
    '30 Segundos de Prancha Lateral (cada lado)',
    '10 Agachamentos com Salto',
    '1 minuto de pular corda imaginária',
  ];

  static Future<String> getDailyChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayDateStr =
        DateTime(today.year, today.month, today.day).toIso8601String();
    final lastSelectionDateStr = prefs.getString(_challengeSelectionDateKey);

    String? challenge;

    if (lastSelectionDateStr == todayDateStr) {
      challenge = prefs.getString(_currentChallengeKey);
    }

    if (challenge == null) {
      final random = Random();
      challenge = _challenges[random.nextInt(_challenges.length)];
      await prefs.setString(_currentChallengeKey, challenge);
      await prefs.setString(_challengeSelectionDateKey, todayDateStr);
    }

    return challenge;
  }

  static Future<bool> isChallengeCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCompletionDateStr = prefs.getString(_challengeDateKey);
    if (lastCompletionDateStr == null) {
      return false;
    }
    final lastCompletionDate = DateTime.parse(lastCompletionDateStr);
    final now = DateTime.now();
    return lastCompletionDate.year == now.year &&
        lastCompletionDate.month == now.month &&
        lastCompletionDate.day == now.day;
  }

  static Future<void> completeChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_challengeDateKey, DateTime.now().toIso8601String());
    final progress = await getChallengeProgress();
    await prefs.setInt(_challengeProgressKey, progress + 1);
  }

  static Future<int> getChallengeProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekNumber = (now.day / 7).ceil();
    final storedWeek = prefs.getInt(_challengeWeekKey);

    if (storedWeek == null || storedWeek != weekNumber) {
      await prefs.setInt(_challengeWeekKey, weekNumber);
      await prefs.setInt(_challengeProgressKey, 0);
      return 0;
    }

    return prefs.getInt(_challengeProgressKey) ?? 0;
  }

  // Adicionado para reiniciar o desafio para testes
  static Future<void> resetChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_challengeDateKey);
    await prefs.remove(_challengeProgressKey);
    await prefs.remove(_challengeWeekKey);
    await prefs.remove(_currentChallengeKey);
    await prefs.remove(_challengeSelectionDateKey);
  }
}
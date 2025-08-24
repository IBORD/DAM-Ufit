import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ufit/src/viewmodels/settings_viewmodel.dart';
import 'package:ufit/src/services/user_preferences_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel();
    _viewModel.loadPreferences();
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
      child: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.errorMessage != null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Configurações'),
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
                      onPressed: () => viewModel.loadPreferences(),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Configurações'),
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Notificações'),
                  _buildSwitchTile(
                    'Notificações',
                    'Receber notificações do app',
                    viewModel.notificationsEnabled,
                    (value) async {
                      await viewModel.savePreference('notifications_enabled', value);
                    },
                  ),
                  _buildSwitchTile(
                    'Lembretes de Treino',
                    'Lembrar sobre treinos agendados',
                    viewModel.workoutRemindersEnabled,
                    (value) async {
                      await viewModel.savePreference('workout_reminders_enabled', value);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Aparência'),
                  _buildDropdownTile(
                    'Tema',
                    'Escolha o tema do app',
                    viewModel.theme,
                    {
                      'system': 'Sistema',
                      'light': 'Claro',
                      'dark': 'Escuro',
                    },
                    (value) async {
                      await viewModel.saveThemePreference(value);
                    },
                  ),
                  _buildDropdownTile(
                    'Idioma',
                    'Escolha o idioma do app',
                    viewModel.language,
                    {
                      'pt': 'Português',
                      'en': 'English',
                      'es': 'Español',
                    },
                    (value) async {
                      await viewModel.saveLanguagePreference(value);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Treinos'),
                  _buildDropdownTile(
                    'Duração Padrão',
                    'Duração padrão dos treinos',
                    viewModel.defaultWorkoutDuration.toString(),
                    {
                      '15': '15 minutos',
                      '20': '20 minutos',
                      '30': '30 minutos',
                      '45': '45 minutos',
                      '60': '60 minutos',
                    },
                    (value) async {
                      await viewModel.savePreference('default_workout_duration', int.parse(value));
                    },
                  ),
                  _buildDropdownTile(
                    'Tipo Preferido',
                    'Tipo de treino preferido',
                    viewModel.preferredWorkoutType,
                    {
                      'FORÇA': 'Força',
                      'CARDIO': 'Cardio',
                      'HIPERTROFIA': 'Hipertrofia',
                      'FUNCIONAL': 'Funcional',
                    },
                    (value) async {
                      await viewModel.savePreference('preferred_workout_type', value);
                    },
                  ),
                  _buildDropdownTile(
                    'Local Preferido',
                    'Local de treino preferido',
                    viewModel.preferredWorkoutLocation,
                    {
                      'CASA': 'Casa',
                      'ACADEMIA': 'Academia',
                    },
                    (value) async {
                      await viewModel.savePreference('preferred_workout_location', value);
                    },
                  ),
                  _buildDropdownTile(
                    'Nível de Fitness',
                    'Seu nível atual de fitness',
                    viewModel.fitnessLevel,
                    {
                      'beginner': 'Iniciante',
                      'intermediate': 'Intermediário',
                      'advanced': 'Avançado',
                    },
                    (value) async {
                      await viewModel.savePreference('fitness_level', value);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Execução de Treinos'),
                  _buildSwitchTile(
                    'Iniciar Automaticamente',
                    'Iniciar treino automaticamente',
                    viewModel.autoStartWorkout,
                    (value) async {
                      await viewModel.savePreference('auto_start_workout', value);
                    },
                  ),
                  _buildSwitchTile(
                    'Timer de Descanso',
                    'Mostrar timer entre sets',
                    viewModel.restTimerEnabled,
                    (value) async {
                      await viewModel.savePreference('rest_timer_enabled', value);
                    },
                  ),
                  _buildDropdownTile(
                    'Tempo de Descanso Padrão',
                    'Tempo padrão entre sets',
                    viewModel.defaultRestTime.toString(),
                    {
                      '30': '30 segundos',
                      '45': '45 segundos',
                      '60': '1 minuto',
                      '90': '1 minuto 30',
                      '120': '2 minutos',
                    },
                    (value) async {
                      await viewModel.savePreference('default_rest_time', int.parse(value));
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Sistema'),
                  _buildDropdownTile(
                    'Unidade de Medida',
                    'Sistema de medidas preferido',
                    viewModel.measurementUnit,
                    {
                      'metric': 'Métrico (kg, cm)',
                      'imperial': 'Imperial (lb, in)',
                    },
                    (value) async {
                      await viewModel.savePreference('measurement_unit', value);
                    },
                  ),
                  _buildSwitchTile(
                    'Som',
                    'Ativar sons do app',
                    viewModel.soundEnabled,
                    (value) async {
                      await viewModel.savePreference('sound_enabled', value);
                    },
                  ),
                  _buildSwitchTile(
                    'Vibração',
                    'Ativar vibração do app',
                    viewModel.vibrationEnabled,
                    (value) async {
                      await viewModel.savePreference('vibration_enabled', value);
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  _buildResetButton(viewModel),
                  const SizedBox(height: 16),
                  _buildDebugButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue[800],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String currentValue,
    Map<String, String> options,
    ValueChanged<String> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: DropdownButton<String>(
          value: currentValue,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          items: options.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResetButton(SettingsViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _resetPreferences(viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Resetar Todas as Configurações'),
      ),
    );
  }

  Widget _buildDebugButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _debugPreferences,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Debug Preferências (Console)'),
      ),
    );
  }

  Future<void> _debugPreferences() async {
    await UserPreferencesService.debugPrintPreferences();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifique o console para debug das preferências')),
      );
    }
  }

  Future<void> _resetPreferences(SettingsViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Configurações'),
        content: const Text('Tem certeza que deseja resetar todas as configurações? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await viewModel.resetPreferences();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configurações resetadas com sucesso')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao resetar configurações: $e')),
          );
        }
      }
    }
  }
}

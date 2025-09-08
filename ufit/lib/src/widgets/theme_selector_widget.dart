import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ufit/src/services/theme_service.dart';

class ThemeSelectorWidget extends StatelessWidget {
  const ThemeSelectorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tema do App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildThemeOption(
                        context,
                        themeService,
                        'system',
                        'Sistema',
                        Icons.brightness_auto,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeOption(
                        context,
                        themeService,
                        'light',
                        'Claro',
                        Icons.light_mode,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeOption(
                        context,
                        themeService,
                        'dark',
                        'Escuro',
                        Icons.dark_mode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tema atual: ${_getThemeDisplayName(themeService.currentTheme)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeService themeService,
    String themeValue,
    String displayName,
    IconData icon,
  ) {
    final isSelected = themeService.currentTheme == themeValue;
    
    return GestureDetector(
      onTap: () => themeService.setTheme(themeValue),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 12,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Claro';
      case 'dark':
        return 'Escuro';
      case 'system':
      default:
        return 'Sistema';
    }
  }
}

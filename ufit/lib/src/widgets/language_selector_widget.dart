import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ufit/src/services/language_service.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Idioma do App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: languageService.currentLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Selecione o idioma',
                    border: OutlineInputBorder(),
                  ),
                  items: LanguageService.supportedLocales.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          _getLanguageFlag(entry.key),
                          const SizedBox(width: 8),
                          Text(LanguageService.getLanguageName(entry.key)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      languageService.setLanguage(newValue);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Idioma atual: ${LanguageService.getLanguageName(languageService.currentLanguage)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Exemplo: ${languageService.getLocalizedText('home')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getLanguageFlag(String languageCode) {
    String flag;
    switch (languageCode) {
      case 'pt':
        flag = '🇧🇷';
        break;
      case 'en':
        flag = '🇺🇸';
        break;
      case 'es':
        flag = '🇪🇸';
        break;
      default:
        flag = '🌐';
    }
    
    return Text(
      flag,
      style: const TextStyle(fontSize: 20),
    );
  }
}

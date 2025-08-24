import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ufit/src/pages/auth.pages/auth_layout.dart';
import 'package:ufit/src/pages/auth.pages/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:ufit/src/services/theme_service.dart';
import 'package:ufit/src/services/language_service.dart';

// void main() {//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize services
  final themeService = ThemeService();
  final languageService = LanguageService();
  
  await themeService.initializeTheme();
  await languageService.initializeLanguage();

  runApp(MyApp(
    themeService: themeService,
    languageService: languageService,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  final LanguageService languageService;

  const MyApp({
    super.key,
    required this.themeService,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: languageService),
      ],
      child: Consumer2<ThemeService, LanguageService>(
        builder: (context, themeService, languageService, child) {
          return MaterialApp(
            title: 'Ufit',
            theme: themeService.getThemeData(),
            locale: languageService.currentLocale,
            supportedLocales: LanguageService.supportedLocalesList,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            home: const AuthLayout(),
          );
        },
      ),
    );
  }
}

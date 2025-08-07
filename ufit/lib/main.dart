import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ufit/src/pages/auth.pages/auth_layout.dart';
import 'package:ufit/src/pages/auth.pages/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/pages/register_pages/log_in_page.dart';

// void main() {//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ufit',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const AuthLayout(),
    );
  }
}

import 'package:ufit/src/pages/auth.pages/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:ufit/src/pages/main_page.dart';
import 'package:ufit/src/pages/register_pages/log_in_page.dart';
import 'package:ufit/src/pages/register_pages/register_user_page.dart';
import 'package:ufit/src/pages/app_loading_page.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = const AppLoadingPage();
            } else if (snapshot.hasData) {
              widget = const MainScreen();
            } else {
              widget = pageIfNotConnected ?? const LoginPage();
            }
            return widget;
          },
        );
      },
    );
  }
}

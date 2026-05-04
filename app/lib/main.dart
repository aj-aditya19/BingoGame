import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/register_page.dart';

void main() => runApp(const BingoApp());

class BingoApp extends StatelessWidget {
  const BingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bingo Game',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Segoe UI'),
      routes: {
        '/': (c) => LandingPage(
          onLogin: () => Navigator.of(c).pushNamed('/login'),
          onCreate: () => Navigator.of(c).pushNamed('/register'),
        ),
        '/login': (c) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (c) {
          final args = ModalRoute.of(c)!.settings.arguments;
          return HomePage(user: args is Map ? args : null);
        },
      },
      initialRoute: '/',
    );
  }
}

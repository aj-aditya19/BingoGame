import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.user});

  final Map? user;

  @override
  Widget build(BuildContext context) {
    final name = (user?['name'] ?? 'Player').toString();
    return Scaffold(
      appBar: AppBar(title: const Text('Bingo Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome, $name', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

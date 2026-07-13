import 'package:flutter/material.dart';
import 'dart:math';

class CreateBotScreen extends StatefulWidget {
  final Function(Map<String, dynamic>, List<List<Map<String, dynamic>>>)
  onBotReady;

  const CreateBotScreen({super.key, required this.onBotReady});

  @override
  State<CreateBotScreen> createState() => _CreateBotScreenState();
}

class _CreateBotScreenState extends State<CreateBotScreen> {
  @override
  void initState() {
    super.initState();
    _initializeBot();
  }

  void _initializeBot() {
    // Create bot player
    final botPlayer = {'_id': 'bot', 'name': 'Bingo Bot', 'role': 'Bot'};

    // Create bot grid with random numbers 1-25
    final used = <int>{};
    final random = Random();
    final grid = List<List<Map<String, dynamic>>>.generate(
      5,
      (_) => List<Map<String, dynamic>>.generate(5, (_) {
        int num;
        do {
          num = random.nextInt(25) + 1;
        } while (used.contains(num));
        used.add(num);

        return {'value': num, 'chosen': false};
      }),
    );

    // Notify parent that bot is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onBotReady(botPlayer, grid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creating Bot...'), centerTitle: true),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Preparing Bot...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

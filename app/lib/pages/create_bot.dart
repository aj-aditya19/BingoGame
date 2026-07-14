import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_theme.dart';

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
    final botPlayer = {'_id': 'bot', 'name': 'Bingo Bot', 'role': 'Bot'};

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

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onBotReady(botPlayer, grid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creating Bot...')),
      body: AppBackground(
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accent2),
              SizedBox(height: 20),
              Text(
                'Preparing Bot...',
                style: TextStyle(fontSize: 16, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

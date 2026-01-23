import 'package:flutter/material.dart';
import 'dart:async';

class ResultScreen extends StatefulWidget {
  final String? winner;
  final bool isDraw;
  final VoidCallback onPlayAgain;

  const ResultScreen({
    super.key,
    required this.winner,
    required this.isDraw,
    required this.onPlayAgain,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 7), () {
      widget.onPlayAgain();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Result")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!widget.isDraw) ...[
              const Text(
                "🏆 Winner",
                style: TextStyle(color: Color(0xFF22C55E), fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                widget.winner ?? "",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text("BINGO completed 🎉"),
            ] else ...[
              const Text(
                "🤝 Draw",
                style: TextStyle(color: Color(0xFFF97316), fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text("Both players completed BINGO"),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onPlayAgain,
                child: const Text("Play Again"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

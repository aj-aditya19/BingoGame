import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  int countdown = 7;

  String copyStatus = "";

  Timer? countdownTimer;
  Timer? restartTimer;

  // Replace with your deployed website
  final String websiteUrl = "https://your-bingo-website.com";

  @override
  void initState() {
    super.initState();

    restartTimer = Timer(const Duration(seconds: 7), () {
      widget.onPlayAgain();
    });

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    restartTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> copyWebsiteLink() async {
    try {
      await Clipboard.setData(ClipboardData(text: websiteUrl));

      setState(() {
        copyStatus = "Link copied";
      });
    } catch (_) {
      setState(() {
        copyStatus = "Copy failed";
      });
    }

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      setState(() {
        copyStatus = "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWin = widget.winner == "You";

    return Scaffold(
      appBar: AppBar(title: const Text("Game Result")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Game Result",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  if (!widget.isDraw) ...[
                    Text(
                      isWin ? "🏆 You Win" : "😞 You Lose",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: isWin ? Colors.green : Colors.red,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      widget.winner ?? "",
                      style: const TextStyle(fontSize: 22),
                    ),

                    const SizedBox(height: 8),

                    const Text("BINGO completed 🎉"),
                  ] else ...[
                    const Text(
                      "🤝 Draw",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    const Text("Both players completed BINGO"),
                  ],

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onPlayAgain,
                      child: const Text("Play Again"),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Share this website with more friends",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  SelectableText(websiteUrl, textAlign: TextAlign.center),

                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    onPressed: copyWebsiteLink,
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy Link"),
                  ),

                  if (copyStatus.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(copyStatus),
                    ),

                  const SizedBox(height: 25),

                  Text(
                    "Auto restarting in ${countdown}s...",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

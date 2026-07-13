import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  final VoidCallback onPlayWithBot;
  final VoidCallback onPlayWithFriends;

  const LandingScreen({
    super.key,
    required this.onPlayWithBot,
    required this.onPlayWithFriends,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFE0F2FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Live multiplayer bingo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Play bingo with friends in a bright, animated game room.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Create a room, join a match, and track every move in real time with smooth visuals and fast interactions.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPlayWithBot,
                    icon: const Icon(Icons.smart_toy),
                    label: const Text("Play Offline with Bot"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPlayWithFriends,
                    icon: const Icon(Icons.people),
                    label: const Text("Play with Friends"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statCard("2", "ways to start"),
                    _statCard("24/7", "app access"),
                    _statCard("Live", "room updates"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

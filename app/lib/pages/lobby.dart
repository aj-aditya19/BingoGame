import 'package:flutter/material.dart';

import '../services/socket_service.dart';

class LobbyScreen extends StatelessWidget {
  final String roomId;
  final bool isHost;

  final dynamic player1;
  final dynamic player2;

  final VoidCallback onStartGame;

  const LobbyScreen({
    super.key,
    required this.roomId,
    required this.isHost,
    required this.player1,
    required this.player2,
    required this.onStartGame,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Lobby")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "🎮 Game Lobby",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              "Room ID: $roomId",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 24),

            _sectionTitle("Players"),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "✅ ${player1?["name"] ?? "Player 1"} "
                      "(${player1?["role"] ?? "Player"})",
                    ),

                    const SizedBox(height: 10),

                    Text(
                      player2 != null
                          ? "✅ ${player2["name"]} "
                                "(${player2["role"] ?? "Player"})"
                          : "⏳ Waiting for Player 2...",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Grids Preview"),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GridPreview(title: "Player 1", grid: player1?["grid"]),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: GridPreview(title: "Player 2", grid: player2?["grid"]),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _sectionTitle("Rules"),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("• Players take turns"),
                    ),
                    SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("• Strike numbers one by one"),
                    ),
                    SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("• Complete BINGO to win"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (isHost && player2 != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStartGame,
                  child: const Text("🚀 Let's Play"),
                ),
              ),

            if (isHost && player2 == null)
              const Text(
                "Waiting for another player...",
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class GridPreview extends StatelessWidget {
  final String title;
  final dynamic grid;

  const GridPreview({super.key, required this.title, required this.grid});

  @override
  Widget build(BuildContext context) {
    if (grid == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Not Ready"),
            ],
          ),
        ),
      );
    }

    final cells = (grid as List).expand((row) => row).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cells.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                final cell = cells[index];

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(child: Text(cell["value"].toString())),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

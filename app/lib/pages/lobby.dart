import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  const Text(
                    "🎮 Game Lobby",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Room ID: $roomId",
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.muted,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Players"),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _playerRow(
                            "✅ ${player1?["name"] ?? "Player 1"} "
                            "(${player1?["role"] ?? "Player"})",
                          ),
                          const SizedBox(height: 8),
                          _playerRow(
                            player2 != null
                                ? "✅ ${player2["name"]} "
                                      "(${player2["role"] ?? "Player"})"
                                : "⏳ Waiting for Player 2...",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  _sectionTitle("Grids Preview"),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GridPreview(
                          title: "Player 1",
                          grid: player1?["grid"],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GridPreview(
                          title: "Player 2",
                          grid: player2?["grid"],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _sectionTitle("Rules"),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "• Players take turns",
                            style: TextStyle(color: AppColors.muted),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "• Strike numbers one by one",
                            style: TextStyle(color: AppColors.muted),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "• Complete BINGO to win",
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (isHost && player2 != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onStartGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                        child: const Text("🚀 Let's Play"),
                      ),
                    ),

                  if (isHost && player2 == null)
                    const Text(
                      "Waiting for another player...",
                      style: TextStyle(fontSize: 15, color: AppColors.muted),
                    ),

                  if (!isHost)
                    const Text(
                      "Waiting for the host to start the game...",
                      style: TextStyle(fontSize: 15, color: AppColors.muted),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _playerRow(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.text)),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
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
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              const Text("Not Ready", style: TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      );
    }

    final cells = (grid as List).expand((row) => row).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
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
                    color: AppColors.bgSoft,
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      cell["value"].toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

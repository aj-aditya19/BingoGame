import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/cell_model.dart';
import '../services/socket_service.dart';

class LobbyScreen extends StatefulWidget {
  final String roomId;
  final bool isHost;
  final Map<String, dynamic> user;
  final List<List<CellModel>> myGrid;
  final Function(String)? onStartGame;

  const LobbyScreen({
    super.key,
    required this.roomId,
    required this.isHost,
    required this.user,
    required this.myGrid,
    required this.onStartGame,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final SocketService socketService = SocketService();

  Map<String, dynamic>? player1;
  Map<String, dynamic>? player2;

  @override
  @override
  void initState() {
    super.initState();

    socketService.connect();

    // Wait until socket is actually connected
    socketService.socket.onConnect((_) {
      print("✅ Connected inside LobbyScreen");

      // Emit join-room
      socketService.socket.emit("join-room", {
        "roomId": widget.roomId,
        "user": {
          "id": widget.user["_id"],
          "name": widget.user["name"],
          "grid": widget.myGrid
              .map((row) => row.map((cell) => cell.toJson()).toList())
              .toList(),
          "role": widget.isHost ? "Host" : "Player",
        },
      });
    });

    // Room updates
    socketService.socket.on("room-joined", (players) {
      if (!mounted) return;
      print("🔹 room-joined event: $players");

      final list = List<Map<String, dynamic>>.from(players);

      setState(() {
        player1 = list.isNotEmpty ? list[0] : null;
        player2 = list.length > 1 ? list[1] : null;
      });
    });

    // Game start
    socketService.socket.on("game-start", (data) {
      if (!mounted) return;
      widget.onStartGame?.call(data["turnUserId"]);
    });
  }

  @override
  void dispose() {
    socketService.socket.emit("leave-room", {"roomId": widget.roomId});

    socketService.socket.off("room-joined");
    socketService.socket.off("game-start");

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Lobby")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Room ID: ${widget.roomId}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// 👥 PLAYERS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Players",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "✅ ${player1?["name"] ?? "Waiting..."} (${player1?["role"] ?? ""})",
            ),
            Text(
              player2 != null
                  ? "✅ ${player2!["name"]} (${player2!["role"]})"
                  : "⏳ Waiting for Player 2...",
            ),

            const SizedBox(height: 20),

            /// 🔢 GRID PREVIEW
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Grids Preview",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: GridPreview(title: "Player 1", grid: player1?["grid"]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GridPreview(title: "Player 2", grid: player2?["grid"]),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// ▶ START GAME
            if (widget.isHost && player2 != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    socketService.socket.emit("start-game", {
                      "roomId": widget.roomId,
                    });
                  },
                  child: const Text("Let's Play"),
                ),
              ),

            if (widget.isHost && player2 == null)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text("Waiting for another player..."),
              ),
          ],
        ),
      ),
    );
  }
}

/// ================= GRID PREVIEW =================

class GridPreview extends StatelessWidget {
  final String title;
  final List<dynamic>? grid;

  const GridPreview({super.key, required this.title, this.grid});

  @override
  Widget build(BuildContext context) {
    if (grid == null) {
      return Text("$title: Not Ready");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 25,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final r = index ~/ 5;
            final c = index % 5;
            final cell = grid![r][c];
            final value = cell["value"];

            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: Text(
                value?.toString() ?? "",
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        ),
      ],
    );
  }
}

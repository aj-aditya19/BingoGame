import 'package:flutter/material.dart';
import '../models/cell_model.dart';
import '../services/socket_service.dart';

class LobbyScreen extends StatefulWidget {
  final String roomId;
  final bool isHost;
  final Map<String, dynamic> user;
  final List<List<CellModel>> myGrid;
  final VoidCallback onStartGame;

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
  void initState() {
    super.initState();

    if (widget.isHost) {
      player1 = {
        "_id": widget.user["_id"],
        "name": widget.user["name"],
        "role": "Host",
      };
    }
    print("Player1 in Lobby = $player1\n");
    print("RoomId in LObby: ${widget.roomId},\nisHost: ${widget.isHost}\n");
    print("User info in LObby: ${widget.user}\n");
    print("Grid length in LObby: ${widget.myGrid.length}\n");
    socketService.socket.on("room-joined", (players) {
      if (!mounted) return;

      final list = (players as List)
          .map((p) => Map<String, dynamic>.from(p))
          .toList();

      for (var player in list) {
        if (player["grid"] != null) {
          final gridJson = (player["grid"] as List)
              .map(
                (row) => (row as List)
                    .map((cell) => Map<String, dynamic>.from(cell))
                    .toList(),
              )
              .toList();
          player["grid"] = gridJson;
        }
      }

      setState(() {
        player1 = list.isNotEmpty ? list[0] : null;
        player2 = list.length > 1 ? list[1] : null;
      });
    });

    // socketService.socket.on("game-start", (_) {
    //   if (!mounted) return;
    //   widget.onStartGame();
    // });
  }

  @override
  void dispose() {
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

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Players",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "✅ ${player1?["name"] ?? "Player 1"} (${player1?["role"] ?? "Player"})",
            ),
            Text(
              player2 != null
                  ? "✅ ${player2!["name"]} (${player2!["role"] ?? "Player"})"
                  : "⏳ Waiting for Player 2...",
            ),
            const SizedBox(height: 20),

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
                  child: GridPreview(title: "Player 1", grid: widget.myGrid),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GridPreview(title: "Player 2", grid: player2?["grid"]),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Rules", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text("• Players take turns"),
                Text("• Strike numbers one by one"),
                Text("• Complete BINGO to win"),
              ],
            ),

            const SizedBox(height: 20),

            Visibility(
              visible: widget.isHost && player2 != null,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    SocketService().socket.emit("start-game", {
                      "roomId": widget.roomId,
                    });
                  },
                  child: const Text("Let's Play"),
                ),
              ),
            ),
            Visibility(
              visible: widget.isHost && player2 == null,
              child: const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text("Waiting for another player..."),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPreview extends StatelessWidget {
  final String title;
  final List<dynamic>? grid;

  const GridPreview({super.key, required this.title, this.grid});

  @override
  Widget build(BuildContext context) {
    if (grid == null) return Text("$title: Not Ready");

    late final List<List<CellModel>> typedGrid;

    // 🔥 FIX HERE
    if (grid!.isNotEmpty && grid![0][0] is CellModel) {
      // Player 1 (local grid)
      typedGrid = grid!.cast<List<CellModel>>();
    } else {
      // Player 2 (socket JSON grid)
      typedGrid = grid!
          .map<List<CellModel>>(
            (row) => (row as List)
                .map<CellModel>(
                  (cell) => CellModel.fromJson(Map<String, dynamic>.from(cell)),
                )
                .toList(),
          )
          .toList();
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
            final cell = typedGrid[r][c];

            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: cell.marked ? Colors.greenAccent : Colors.white,
              ),
              child: Text(
                cell.value.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        ),
      ],
    );
  }
}

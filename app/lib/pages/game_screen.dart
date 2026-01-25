import 'package:flutter/material.dart';
import '../models/cell_model.dart';
import '../services/socket_service.dart';

class GameScreen extends StatefulWidget {
  final String roomId;
  final List<List<CellModel>> initialGrid;
  final String myUserId;
  final String initialTurnUserId;
  final Function(Map) onGameEnd;

  const GameScreen({
    super.key,
    required this.roomId,
    required this.initialGrid,
    required this.myUserId,
    required this.initialTurnUserId,
    required this.onGameEnd,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<CellModel>> grid;
  String? currentTurn;
  String? winner;

  final socket = SocketService().socket;

  @override
  void initState() {
    super.initState();

    // Initialize grid and reset chosen
    grid = widget.initialGrid
        .map(
          (row) => row
              .map((cell) => CellModel(value: cell.value, marked: false))
              .toList(),
        )
        .toList();

    currentTurn = widget.initialTurnUserId;

    // Socket listeners
    socket.on("game:turn", (data) {
      setState(() => currentTurn = data["userId"]);
    });

    socket.on("game:update", (data) {
      final number = data["number"];
      final playedBy = data["userId"];
      setState(() {
        for (var row in grid) {
          for (var cell in row) {
            if (cell.value == number) cell.marked = true;
          }
        }
      });

      // Only current player can emit win
      if (playedBy == widget.myUserId && checkWin()) {
        socket.emit("game:win", {
          "roomId": widget.roomId,
          "userId": widget.myUserId,
        });
      }
    });

    socket.on("game:win", (data) {
      setState(() => winner = data["userId"]);
      widget.onGameEnd({
        "winnerName": data["userId"] == widget.myUserId ? "You" : "Opponent",
        "draw": false,
      });
    });
  }

  @override
  void dispose() {
    socket.off("game:turn");
    socket.off("game:update");
    socket.off("game:win");
    super.dispose();
  }

  bool get isLocked => currentTurn != widget.myUserId || winner != null;

  void selectNumber(CellModel cell) {
    if (isLocked || cell.marked) return;

    socket.emit("game:select-number", {
      "roomId": widget.roomId,
      "number": cell.value,
      "userId": widget.myUserId,
    });
  }

  bool checkWin() {
    int count = 0;

    // Rows & Columns
    for (int i = 0; i < 5; i++) {
      if (grid[i].every((c) => c.marked)) count++;
      if (grid.every((r) => r[i].marked)) count++;
    }

    // Diagonals
    if (List.generate(5, (i) => grid[i][i]).every((c) => c.marked)) count++;
    if (List.generate(5, (i) => grid[i][4 - i]).every((c) => c.marked)) count++;

    return count >= 5;
  }

  @override
  Widget build(BuildContext context) {
    String titleText;
    if (winner != null) {
      titleText = winner == widget.myUserId ? "🎉 You Win!" : "😢 You Lost";
    } else {
      titleText = currentTurn == widget.myUserId
          ? "Your Turn"
          : "Opponent Turn";
    }

    return Scaffold(
      appBar: AppBar(title: Text(titleText)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 25,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        itemBuilder: (context, index) {
          final r = index ~/ 5;
          final c = index % 5;
          final cell = grid[r][c];

          final bool marked = cell.marked; // 🔹 mark if chosen

          return GestureDetector(
            onTap: () => selectNumber(cell),
            child: Container(
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: marked ? Colors.greenAccent : Colors.white, // 🔹 updated
              ),
              child: Text(
                cell.value.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

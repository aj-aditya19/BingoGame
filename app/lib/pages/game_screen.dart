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
    grid = widget.initialGrid
        .map(
          (row) => row
              .map(
                (cell) => CellModel(
                  value: cell.value,
                  chosen: false, // RESET
                ),
              )
              .toList(),
        )
        .toList();

    currentTurn = widget.initialTurnUserId;

    socket.on("game:turn", (data) {
      setState(() => currentTurn = data["userId"]);
    });

    socket.on("game:update", (data) {
      final number = data["number"];
      setState(() {
        for (var row in grid) {
          for (var cell in row) {
            if (cell.value == number) {
              cell.chosen = true;
            }
          }
        }
      });

      if (currentTurn == widget.myUserId && checkWin()) {
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

    socket.emit("leave-room", {"roomId": widget.roomId});

    super.dispose();
  }

  bool get isLocked => currentTurn != widget.myUserId || winner != null;

  void selectNumber(CellModel cell) {
    if (isLocked || cell.chosen) return;

    socket.emit("game:select-number", {
      "roomId": widget.roomId,
      "number": cell.value,
      "userId": widget.myUserId,
    });
  }

  bool checkWin() {
    int count = 0;

    for (int i = 0; i < 5; i++) {
      if (grid[i].every((c) => c.chosen)) count++;
      if (grid.every((r) => r[i].chosen)) count++;
    }

    if (List.generate(5, (i) => grid[i][i]).every((c) => c.chosen)) count++;
    if (List.generate(5, (i) => grid[i][4 - i]).every((c) => c.chosen)) count++;

    return count >= 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          winner != null
              ? winner == widget.myUserId
                    ? "🎉 You Win!"
                    : "😢 You Lost"
              : currentTurn == widget.myUserId
              ? "Your Turn"
              : "Opponent Turn",
        ),
      ),
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

          return GestureDetector(
            onTap: () => selectNumber(cell),
            child: Container(
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cell.chosen ? Colors.grey : Colors.white,
                border: Border.all(),
              ),
              child: Text(cell.value.toString()),
            ),
          );
        },
      ),
    );
  }
}

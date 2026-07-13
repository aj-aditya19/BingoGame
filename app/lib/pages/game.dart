import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class GameScreen extends StatefulWidget {
  final String roomId;
  final List<List<Map<String, dynamic>>> initialGrid;
  final String myUserId;
  final String initialTurnUserId;
  final Function(Map<String, dynamic>) onGameEnd;
  final VoidCallback? onCancel;
  final VoidCallback? onLogout;
  final bool isBotGame;

  const GameScreen({
    super.key,
    required this.roomId,
    required this.initialGrid,
    required this.myUserId,
    required this.initialTurnUserId,
    required this.onGameEnd,
    this.onCancel,
    this.onLogout,
    this.isBotGame = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<Map<String, dynamic>>> grid;

  String? currentTurn;
  String? winner;

  @override
  void initState() {
    super.initState();

    grid = widget.initialGrid;

    currentTurn = widget.initialTurnUserId;

    _registerSocketEvents();
  }

  @override
  void dispose() {
    SocketService.socket.off("game-start");
    SocketService.socket.off("game:turn");
    SocketService.socket.off("game:update");
    SocketService.socket.off("game:win");

    super.dispose();
  }

  void _registerSocketEvents() {
    SocketService.socket.on("game-start", (data) {
      setState(() {
        currentTurn = data["turnUserId"];
      });
    });

    SocketService.socket.on("game:turn", (data) {
      setState(() {
        currentTurn = data["userId"];
      });
    });

    SocketService.socket.on("game:update", (data) {
      final int number = data["number"];

      final updatedGrid = grid
          .map(
            (row) => row
                .map(
                  (cell) => {
                    ...cell,
                    if (cell["value"] == number) "chosen": true,
                  },
                )
                .toList(),
          )
          .toList();

      final result = checkWin(updatedGrid);

      if (winner == null &&
          currentTurn == widget.myUserId &&
          result["win"] == true) {
        SocketService.socket.emit("game:win", {
          "roomId": widget.roomId,
          "userId": widget.myUserId,
        });
      }

      setState(() {
        grid = result["newGrid"] as List<List<Map<String, dynamic>>>;
      });
    });

    SocketService.socket.on("game:win", (data) {
      final userId = data["userId"];

      setState(() {
        winner = userId;
      });

      widget.onGameEnd({
        "winnerName": userId == widget.myUserId ? "You" : "Opponent",
        "draw": false,
      });
    });
  }

  bool get isLocked => currentTurn != widget.myUserId || winner != null;

  void selectNumber(Map<String, dynamic> cell) {
    if (isLocked) return;

    if (cell["chosen"] == true) return;

    SocketService.socket.emit("game:select-number", {
      "roomId": widget.roomId,
      "number": cell["value"],
      "userId": widget.myUserId,
    });
  }

  Map<String, dynamic> checkWin(List<List<Map<String, dynamic>>> board) {
    int lines = 0;

    final updated = board
        .map((row) => row.map((cell) => {...cell, "completed": false}).toList())
        .toList();

    // Rows
    for (int r = 0; r < 5; r++) {
      if (updated[r].every((c) => c["chosen"] == true)) {
        lines++;

        for (var cell in updated[r]) {
          cell["completed"] = true;
        }
      }
    }

    // Columns
    for (int c = 0; c < 5; c++) {
      bool full = true;

      for (int r = 0; r < 5; r++) {
        if (updated[r][c]["chosen"] != true) {
          full = false;
        }
      }

      if (full) {
        lines++;

        for (int r = 0; r < 5; r++) {
          updated[r][c]["completed"] = true;
        }
      }
    }

    // Diagonal 1
    bool diag1 = true;

    for (int i = 0; i < 5; i++) {
      if (updated[i][i]["chosen"] != true) {
        diag1 = false;
      }
    }

    if (diag1) {
      lines++;

      for (int i = 0; i < 5; i++) {
        updated[i][i]["completed"] = true;
      }
    }

    // Diagonal 2
    bool diag2 = true;

    for (int i = 0; i < 5; i++) {
      if (updated[i][4 - i]["chosen"] != true) {
        diag2 = false;
      }
    }

    if (diag2) {
      lines++;

      for (int i = 0; i < 5; i++) {
        updated[i][4 - i]["completed"] = true;
      }
    }

    return {"newGrid": updated, "win": lines >= 5};
  }

  String get titleText {
    if (winner != null) {
      return winner == widget.myUserId ? "🎉 You Win" : "😢 You Lost";
    }

    return currentTurn == widget.myUserId ? "Your Turn" : "Opponent Turn";
  }

  @override
  Widget build(BuildContext context) {
    final cells = grid.expand((row) => row).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bingo Game"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              titleText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                itemCount: cells.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final cell = cells[index];

                  final chosen = cell["chosen"] == true;

                  final completed = cell["completed"] == true;

                  return ElevatedButton(
                    onPressed: chosen || isLocked
                        ? null
                        : () => selectNumber(cell),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: completed
                          ? Colors.green
                          : chosen
                          ? Colors.grey
                          : null,
                    ),
                    child: Text(
                      cell["value"].toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            if (widget.isBotGame)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Cancel Game"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

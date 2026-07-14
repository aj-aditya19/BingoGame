import 'package:flutter/material.dart';
import '../services/socket_service.dart';
import '../utils/bingo_game.dart';
import '../widgets/chat_box.dart';
import '../theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  final String roomId;
  final List<List<Map<String, dynamic>>> initialGrid;
  final String myUserId;
  final String myName;
  final String initialTurnUserId;
  final Function(Map<String, dynamic>) onGameEnd;
  final VoidCallback? onCancel;
  final VoidCallback? onLogout;
  final bool isBotGame;

  final String? botPlayerId;
  final String? botPlayerName;
  final List<List<Map<String, dynamic>>>? botInitialGrid;

  const GameScreen({
    super.key,
    required this.roomId,
    required this.initialGrid,
    required this.myUserId,
    this.myName = "You",
    required this.initialTurnUserId,
    required this.onGameEnd,
    this.onCancel,
    this.onLogout,
    this.isBotGame = false,
    this.botPlayerId,
    this.botPlayerName,
    this.botInitialGrid,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<Map<String, dynamic>>> grid;

  List<List<Map<String, dynamic>>>? botGrid;

  String? currentTurn;
  String? winner;

  @override
  void initState() {
    super.initState();

    grid = widget.initialGrid;

    if (widget.isBotGame) {
      botGrid = widget.botInitialGrid;
      currentTurn = widget.myUserId;
    } else {
      currentTurn = widget.initialTurnUserId;
      _registerSocketEvents();
    }
  }

  @override
  void dispose() {
    if (!widget.isBotGame) {
      SocketService.socket.off("game-start");
      SocketService.socket.off("game:turn");
      SocketService.socket.off("game:update");
      SocketService.socket.off("game:win");
    }

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

    if (widget.isBotGame) {
      _applyOfflineMove(cell["value"]);
      return;
    }

    SocketService.socket.emit("game:select-number", {
      "roomId": widget.roomId,
      "number": cell["value"],
      "userId": widget.myUserId,
    });
  }

  void _applyOfflineMove(int number) {
    final humanNewGrid = BingoGameUtils.markNumber(grid, number)['newGrid'];
    final updated = grid
        .map((row) => row.map((cell) => {...cell, "completed": false}).toList())
        .toList();
    final humanEval = BingoGameUtils.evaluateGrid(humanNewGrid);

    Map<String, dynamic>? botEval;
    if (botGrid != null) {
      final botNewGrid = BingoGameUtils.markNumber(botGrid!, number)['newGrid'];
      botEval = BingoGameUtils.evaluateGrid(botNewGrid);
    }

    setState(() {
      grid = humanEval['newGrid'];
      if (botEval != null) botGrid = botEval['newGrid'];
    });

    final humanWon = humanEval['win'] == true;
    final botWon = botEval != null && botEval['win'] == true;

    if (humanWon && botWon) {
      _finishOfflineGame(null, isDraw: true);
      return;
    }

    if (humanWon) {
      _finishOfflineGame(widget.myUserId, isDraw: false);
      return;
    }

    if (botWon) {
      _finishOfflineGame(widget.botPlayerId, isDraw: false);
      return;
    }

    final nextTurn = currentTurn == widget.myUserId
        ? widget.botPlayerId
        : widget.myUserId;

    setState(() {
      currentTurn = nextTurn;
    });

    if (nextTurn == widget.botPlayerId) {
      _scheduleBotMove();
    }
  }

  void _scheduleBotMove() {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (winner != null) return;
      if (botGrid == null) return;

      final move = BingoGameUtils.pickBotMove(botGrid!, grid);

      if (move == null) {
        _finishOfflineGame(null, isDraw: true);
        return;
      }

      _applyOfflineMove(move);
    });
  }

  void _finishOfflineGame(String? winnerId, {required bool isDraw}) {
    setState(() {
      winner = isDraw ? "draw" : winnerId;
    });

    widget.onGameEnd({
      "winnerName": isDraw
          ? "Draw"
          : (winnerId == widget.myUserId
                ? "You"
                : (widget.botPlayerName ?? "Bot")),
      "draw": isDraw,
    });
  }

  /* ================= WIN CHECKING (multiplayer) ================= */

  Map<String, dynamic> checkWin(List<List<Map<String, dynamic>>> board) {
    int lines = 0;

    final updated = board
        .map((row) => row.map((cell) => {...cell, "completed": false}).toList())
        .toList();

    for (int r = 0; r < 5; r++) {
      if (updated[r].every((c) => c["chosen"] == true)) {
        lines++;

        for (var cell in updated[r]) {
          cell["completed"] = true;
        }
      }
    }

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
      if (winner == "draw") return "🤝 It's a Draw";
      return winner == widget.myUserId ? "🎉 You Win" : "😢 You Lost";
    }

    if (currentTurn == widget.myUserId) return "Your Turn";

    return widget.isBotGame
        ? "${widget.botPlayerName ?? 'Bot'}'s Turn"
        : "Opponent Turn";
  }

  Color get titleColor {
    if (winner != null) {
      if (winner == "draw") return const Color(0xFFB45309);
      return winner == widget.myUserId ? AppColors.success : AppColors.danger;
    }

    if (currentTurn == widget.myUserId) return AppColors.accent2;

    return AppColors.text;
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
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Text(
                    titleText,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GridView.builder(
                        itemCount: cells.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemBuilder: (context, index) {
                          final cell = cells[index];

                          final chosen = cell["chosen"] == true;
                          final completed = cell["completed"] == true;

                          Color bg = AppColors.bgSoft;
                          Color fg = AppColors.text;
                          Color border = AppColors.line;

                          if (completed) {
                            bg = AppColors.completedCellBg;
                            fg = AppColors.completedCellText;
                            border = AppColors.completedCellBorder;
                          } else if (chosen) {
                            bg = AppColors.chosenCellBg;
                            fg = AppColors.chosenCellText;
                          }

                          return ElevatedButton(
                            onPressed: chosen || isLocked
                                ? null
                                : () => selectNumber(cell),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bg,
                              foregroundColor: fg,
                              disabledBackgroundColor: bg,
                              disabledForegroundColor: fg,
                              side: BorderSide(color: border),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              cell["value"].toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (!widget.isBotGame)
                    ChatBox(
                      roomId: widget.roomId,
                      myUserId: widget.myUserId,
                      myName: widget.myName,
                    ),

                  const SizedBox(height: 12),

                  if (widget.isBotGame)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          backgroundColor: const Color(0xFFFFF1F2),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                        ),
                        child: const Text("Cancel Game"),
                      ),
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

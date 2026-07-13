import 'package:flutter/material.dart';

import 'pages/landing.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/game_home.dart';
import 'pages/grid.dart';
import 'pages/create_room.dart';
import 'pages/join_room.dart';
import 'pages/lobby.dart';
import 'pages/game.dart';
import 'pages/result.dart';
import 'pages/create_bot.dart';

import 'services/socket_service.dart';

class BingoApp extends StatelessWidget {
  const BingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppController(),
    );
  }
}

class AppController extends StatefulWidget {
  const AppController({super.key});

  @override
  State<AppController> createState() => _AppControllerState();
}

class _AppControllerState extends State<AppController> {
  String page = "landing";

  String? mode;
  String? playMode;
  String? roomId;

  dynamic gameGrid;
  dynamic botPlayer;
  dynamic botGrid;
  List players = [];

  String? winner;
  bool isDraw = false;

  String? initialTurnUserId;

  dynamic user;

  @override
  void initState() {
    super.initState();

    SocketService.connect();
    loadUser();
    _setupSocket();
  }

  void _setupSocket() {
    SocketService.socket.on("room-joined", (updatedPlayers) {
      setState(() {
        players = updatedPlayers;
      });
    });

    SocketService.socket.on("game-start", (data) {
      setState(() {
        initialTurnUserId = data["turnUserId"];
        page = "game";
      });
    });
  }

  Future<void> loadUser() async {
    // SharedPreferences later
  }

  void resetGame() {
    setState(() {
      winner = null;
      isDraw = false;
      gameGrid = null;
      botPlayer = null;
      botGrid = null;
      roomId = null;
      mode = null;
      playMode = null;
      players = [];
      page = "home";
    });
  }

  void handleLogout() {
    resetGame();
    setState(() {
      user = null;
      page = "landing";
    });
  }

  void handleCancelGame() {
    resetGame();
  }

  void handlePlayWithBot() {
    // Set guest user if not logged in
    if (user == null) {
      setState(() {
        user = {
          "_id": "guest-${DateTime.now().millisecondsSinceEpoch}",
          "name": "Guest Player",
          "role": "Guest",
        };
        playMode = "bot";
        page = "grid";
      });
    } else {
      setState(() {
        playMode = "bot";
        page = "grid";
      });
    }
  }

  void handlePlayWithFriends() {
    setState(() {
      page = "login";
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case "landing":
        return LandingScreen(
          onPlayWithBot: handlePlayWithBot,
          onPlayWithFriends: handlePlayWithFriends,
        );

      case "login":
        return LoginScreen(
          onLogin: (userData) {
            setState(() {
              user = userData;
              page = "home";
            });
          },
          onRegister: () => setState(() => page = "register"),
        );

      case "register":
        return RegisterScreen(
          onRegister: (userData) {
            setState(() {
              user = userData;
              page = "home";
            });
          },
        );

      case "home":
        return GameHomeScreen(
          onCreateRoom: () {
            setState(() {
              mode = "create";
              playMode = "multiplayer";
              page = "grid";
            });
          },
          onJoinRoom: () {
            setState(() {
              mode = "join";
              playMode = "multiplayer";
              page = "grid";
            });
          },
          onPlayBot: handlePlayWithBot,
          onLogout: handleLogout,
        );

      case "grid":
        return GridScreen(
          onDone: (grid) {
            setState(() {
              gameGrid = grid;
              if (playMode == "bot") {
                page = "bot-setup";
              } else {
                page = mode == "create" ? "create-room" : "join-room";
              }
            });
          },
        );

      case "bot-setup":
        return CreateBotScreen(
          onBotReady: (bot, grid) {
            setState(() {
              botPlayer = bot;
              botGrid = grid;
              page = "game";
            });
          },
        );

      case "create-room":
        return CreateRoomScreen(
          grid: gameGrid,
          user: user,
          onCreated: (id) {
            setState(() {
              roomId = id;
              page = "lobby";
            });
          },
        );

      case "join-room":
        return JoinRoomScreen(
          grid: gameGrid,
          user: user,
          onJoined: (id) {
            setState(() {
              roomId = id;
              page = "lobby";
            });
          },
        );

      case "lobby":
        return LobbyScreen(
          roomId: roomId ?? "",
          isHost: mode == "create",
          player1: players.isNotEmpty ? players[0] : null,
          player2: players.length > 1 ? players[1] : null,
          onStartGame: () {
            SocketService.socket.emit("start-game", {"roomId": roomId});
          },
        );

      case "game":
        return GameScreen(
          roomId: roomId ?? "",
          initialGrid: (gameGrid as List<List<Map<String, dynamic>>>),
          myUserId: user["_id"],
          initialTurnUserId: initialTurnUserId ?? "",
          onGameEnd: (result) {
            setState(() {
              winner = result["winnerName"];
              isDraw = result["draw"] ?? false;
              page = "result";
            });
          },
          onCancel: handleCancelGame,
          onLogout: handleLogout,
          isBotGame: playMode == "bot",
        );

      case "result":
        return ResultScreen(
          winner: winner,
          isDraw: isDraw,
          onPlayAgain: resetGame,
        );

      default:
        return const Scaffold(body: Center(child: Text("Unknown Page")));
    }
  }
}

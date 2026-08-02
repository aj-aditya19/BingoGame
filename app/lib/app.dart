import 'package:flutter/material.dart';
import 'dart:convert';
import 'theme/app_theme.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class BingoApp extends StatelessWidget {
  const BingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppController(),
    );
  }
}

class AppController extends StatefulWidget {
  const AppController({super.key});

  @override
  State<AppController> createState() => _AppControllerState();
}

class _AppControllerState extends State<AppController> {
  String page = "Landing";
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

  //Socket use for avoiding login again and again
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
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString("user");
    if (userString != null) {
      setState(() {
        user = jsonDecode(userString);
        // page = "home";
      });
    }
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user", jsonEncode(userData));
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
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

  Future<void> handleLogout() async {
    await logoutUser();
    resetGame();
    setState(() {
      user = null;
      page = "Landing";
    });
  }

  void handleCancelGame() {
    resetGame();
  }

  void handlePlayWithBot() {
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
      if (user != null) {
        page = "home";
      } else {
        page = "login";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case "Landing":
        return Scaffold(
          body: LandingScreen(
            onPlayWithBot: handlePlayWithBot,
            onPlayWithFriends: handlePlayWithFriends,
          ),
        );

      case "login":
        return Scaffold(
          appBar: MyAppBar(
            onBack: () {
              setState(() {
                page = "Landing";
              });
            },
          ),
          body: LoginScreen(
            onLogin: (userData) async {
              await saveUser(userData);
              setState(() {
                user = userData;
                page = "home";
              });
            },
            onRegister: () => setState(() => page = "register"),
          ),
        );

      case "register":
        return Scaffold(
          appBar: MyAppBar(
            onBack: () {
              setState(() {
                page = "Landing";
              });
            },
          ),
          body: RegisterScreen(
            onRegister: (userData) async {
              await saveUser(userData);
              setState(() {
                user = userData;
                page = "home";
              });
            },
          ),
        );

      case "home":
        return Scaffold(
          appBar: MyAppBar(
            onBack: () {
              setState(() {
                page = "Landing";
              });
            },
            onLogout: handleLogout,
          ),
          body: GameHomeScreen(
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
          ),
        );

      case "grid":
        return Scaffold(
          appBar: MyAppBar(
            onBack: () {
              setState(() {
                page = "home";
              });
            },
          ),
          body: GridScreen(
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
          ),
        );

      case "bot-setup":
        return Scaffold(
          appBar: MyAppBar(
            onBack: () {
              setState(() {
                page = "home";
              });
            },
          ),
          body: CreateBotScreen(
            onBotReady: (bot, grid) {
              setState(() {
                botPlayer = bot;
                botGrid = grid;
                page = "game";
              });
            },
          ),
        );

      case "create-room":
        return Scaffold(
          appBar: MyAppBar(
            onBack: () {
              setState(() {
                page = "home";
              });
            },
          ),
          body: CreateRoomScreen(
            grid: gameGrid,
            user: user,
            onCreated: (id) {
              setState(() {
                roomId = id;
                page = "lobby";
              });
            },
          ),
        );

      case "join-room":
        return Scaffold(
          appBar: MyAppBar(
            onBack: () {
              setState(() {
                page = "home";
              });
            },
          ),
          body: JoinRoomScreen(
            grid: gameGrid,
            user: user,
            onJoined: (id) {
              setState(() {
                roomId = id;
                page = "lobby";
              });
            },
          ),
        );

      case "lobby":
        return Scaffold(
          appBar: MyAppBar(
            onBack: () {
              setState(() {
                page = "home";
              });
            },
          ),
          body: LobbyScreen(
            roomId: roomId ?? "",
            isHost: mode == "create",
            player1: players.isNotEmpty ? players[0] : null,
            player2: players.length > 1 ? players[1] : null,
            onStartGame: () {
              SocketService.socket.emit("start-game", {"roomId": roomId});
            },
          ),
        );

      case "game":
        return Scaffold(
          appBar: MyAppBar(
            onBack: () {
              setState(() {
                page = "lobby";
              });
            },
          ),
          body: GameScreen(
            roomId: roomId ?? "",
            initialGrid: (gameGrid as List<List<Map<String, dynamic>>>),
            myUserId: user["_id"],
            myName: user["name"] ?? "You",
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
            botPlayerId: botPlayer != null ? botPlayer["_id"] : null,
            botPlayerName: botPlayer != null ? botPlayer["name"] : null,
            botInitialGrid: botGrid != null
                ? (botGrid as List<List<Map<String, dynamic>>>)
                : null,
          ),
        );

      case "result":
        return Scaffold(
          appBar: MyAppBar(
            onBack: () {
              setState(() {
                page = "home";
              });
            },
          ),
          body: ResultScreen(
            winner: winner,
            isDraw: isDraw,
            onPlayAgain: resetGame,
          ),
        );

      default:
        return Scaffold(body: Center(child: Text("Unknown Page")));
    }
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final VoidCallback? onLogout;

  const MyAppBar({super.key, this.onBack, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: onBack != null
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)
          : null,
      actions: onLogout != null
          ? [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: onLogout,
                tooltip: "Logout",
              ),
            ]
          : null,
      title: const Text("Bingo Game"),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_service.dart';
import 'pages/firebase_options.dart';

import 'models/cell_model.dart';
import 'pages/login_screen.dart';
import 'pages/register_screen.dart';
import 'pages/grid_screen.dart';
import 'pages/game_home_screen.dart';
import 'pages/create_room_screen.dart';
import 'pages/join_room_screen.dart';
import 'pages/lobby_screen.dart';
import 'pages/game_screen.dart';
import 'services/socket_service.dart';
import 'pages/result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SocketService().connect();
  runApp(const BingoApp());
}

// ✅ Enum for screens
enum AppScreen {
  login,
  register,
  grid,
  home,
  createRoom,
  joinRoom,
  lobby,
  game,
  result,
}

class BingoApp extends StatefulWidget {
  const BingoApp({super.key});

  @override
  State<BingoApp> createState() => _BingoAppState();
}

class _BingoAppState extends State<BingoApp> {
  AppScreen currentScreen = AppScreen.login;

  Map<String, dynamic>? user;

  String? roomId;
  List<List<CellModel>>? myGrid;
  String? myUserId;

  Map<String, dynamic>? gameResult;
  String? initialTurnUserId;

  void go(AppScreen screen) {
    setState(() => currentScreen = screen);
  }

  @override
  Widget build(BuildContext context) {
    Widget screen;

    switch (currentScreen) {
      case AppScreen.login:
        screen = LoginScreen(
          onLogin: (u) {
            user = u;
            myUserId = u["_id"];
            go(AppScreen.grid);
          },
          onRegister: () => go(AppScreen.register),
        );
        break;

      case AppScreen.register:
        void handleRegister([String? step]) {
          go(AppScreen.login);
        }
        screen = RegisterScreen(onRegister: handleRegister);

        break;

      case AppScreen.grid:
        screen = GridScreen(
          onDone: (grid) {
            myGrid = grid;
            go(AppScreen.home);
          },
        );
        break;

      case AppScreen.home:
        screen = GameHomeScreen(
          onCreateRoom: () => go(AppScreen.createRoom),
          onJoinRoom: () => go(AppScreen.joinRoom),
        );
        break;

      case AppScreen.createRoom:
        if (myGrid == null || user == null) {
          screen = const Center(child: CircularProgressIndicator());
          break;
        }
        screen = CreateRoomScreen(
          grid: myGrid!,
          user: user!,
          onCreated: (id) {
            roomId = id;
            go(AppScreen.lobby);
          },
        );
        break;

      case AppScreen.joinRoom:
        if (myGrid == null || user == null) {
          screen = const Center(child: CircularProgressIndicator());
          break;
        }
        screen = JoinRoomScreen(
          grid: myGrid!,
          user: user!,
          onJoined: (id) {
            roomId = id;
            go(AppScreen.lobby);
          },
        );
        break;

      case AppScreen.lobby:
        if (roomId == null) {
          screen = const Center(child: CircularProgressIndicator());
          break;
        }

        screen = screen = LobbyScreen(
          roomId: roomId!,
          isHost: currentScreen == AppScreen.createRoom,
          user: user!,
          myGrid: myGrid!,
          onStartGame: (String turnUserId) {
            initialTurnUserId = turnUserId;
            go(AppScreen.game);
          },
        );

        break;

      case AppScreen.game:
        if (roomId == null || myGrid == null || myUserId == null) {
          screen = const Center(child: CircularProgressIndicator());
          break;
        }
        screen = GameScreen(
          roomId: roomId!,
          initialGrid: myGrid!,
          myUserId: myUserId!,
          initialTurnUserId: initialTurnUserId!,
          onGameEnd: (result) {
            gameResult = Map<String, dynamic>.from(result);
            go(AppScreen.result);
          },
        );
        break;

      case AppScreen.result:
        if (gameResult == null) {
          screen = const Center(child: CircularProgressIndicator());
          break;
        }
        screen = ResultScreen(
          winner: gameResult!["winnerName"],
          isDraw: gameResult!["draw"],
          onPlayAgain: () {
            roomId = null;
            gameResult = null;
            go(AppScreen.home);
          },
        );
        break;

      default:
        screen = const SizedBox();
    }

    return MaterialApp(debugShowCheckedModeBanner: false, home: screen);
  }
}

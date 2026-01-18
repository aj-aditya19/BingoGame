import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/set_password_page.dart';
import 'pages/grid_page.dart';
import 'pages/game_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This is like React's `useState("login")`
  String currentPage = "login";
  dynamic gameGrid; // to pass grid to game page

  void setPage(String page, {dynamic data}) {
    setState(() {
      currentPage = page;
      if (page == "game") {
        gameGrid = data; // store grid for GamePage
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget pageWidget;

    switch (currentPage) {
      case "login":
        pageWidget = LoginPage(
          onLogin: () => setPage("grid"),
          onRegister: () => setPage("register"),
        );
        break;

      case "register":
        pageWidget = RegisterPage(onRegister: () => setPage("login"));
        break;

      case "set-password":
        pageWidget = SetPasswordPage(onDone: () => setPage("grid"));
        break;

      case "grid":
        pageWidget = GridPage(
          onStartGame: (grid) => setPage("game", data: grid),
        );
        break;

      case "game":
        pageWidget = GamePage(grid: gameGrid);
        break;

      default:
        pageWidget = LoginPage(
          onLogin: () => setPage("grid"),
          onRegister: () => setPage("register"),
        );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bingo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(body: pageWidget),
    );
  }
}

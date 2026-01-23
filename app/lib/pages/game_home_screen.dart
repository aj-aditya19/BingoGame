import 'package:flutter/material.dart';

class GameHomeScreen extends StatelessWidget {
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;

  const GameHomeScreen({
    super.key,
    required this.onCreateRoom,
    required this.onJoinRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Bingo Game", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onCreateRoom,
              child: const Text("Create Room"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onJoinRoom,
              child: const Text("Join Room"),
            ),
          ],
        ),
      ),
    );
  }
}

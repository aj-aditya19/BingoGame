import 'package:flutter/material.dart';

class GameHomeScreen extends StatelessWidget {
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;
  final VoidCallback onPlayBot;
  final VoidCallback onLogout;

  const GameHomeScreen({
    super.key,
    required this.onCreateRoom,
    required this.onJoinRoom,
    required this.onPlayBot,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "🎯 Bingo Game",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Choose your game mode",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),

                          const SizedBox(height: 40),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onCreateRoom,
                              icon: const Icon(Icons.home),
                              label: const Text("Create Room"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: const Color(0xFF2563EB),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: onJoinRoom,
                              icon: const Icon(Icons.door_front_door),
                              label: const Text("Join Room"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onPlayBot,
                              icon: const Icon(Icons.smart_toy),
                              label: const Text("Play with Bot"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: const Color(0xFF9333EA),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: onLogout,
                  tooltip: "Logout",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

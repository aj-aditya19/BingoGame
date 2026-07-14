import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    return AppBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "🎯 Bingo Game",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Choose your game mode",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.muted,
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 90,
                                  child: ElevatedButton(
                                    onPressed: onCreateRoom,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_home,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 6),
                                        Text("Create Room"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 90,
                                  child: ElevatedButton(
                                    onPressed: onJoinRoom,
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.meeting_room,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 6),
                                        Text("Join Room"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: onPlayBot,
                              icon: const Icon(Icons.smart_toy),
                              label: const Text("Play with Bot"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.logout, color: AppColors.muted),
                onPressed: onLogout,
                tooltip: "Logout",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  final VoidCallback onPlayWithBot;
  final VoidCallback onPlayWithFriends;

  const LandingScreen({
    super.key,
    required this.onPlayWithBot,
    required this.onPlayWithFriends,
  });

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              const AppBadge(text: "Live multiplayer bingo"),

              const SizedBox(height: 20),

              Text(
                "Play bingo with friends in a bright, animated game room.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Create a room, join a match, and track every move in real "
                "time with smooth visuals and fast interactions.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPlayWithFriends,
                  icon: const Icon(Icons.people),
                  label: const Text("Play with Friends"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onPlayWithBot,
                  icon: const Icon(Icons.smart_toy),
                  label: const Text("Play Offline with Bot"),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(child: _statCard("2", "ways to start")),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard("24/7", "app access")),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard("Live", "room updates")),
                ],
              ),

              const SizedBox(height: 24),

              _featureCard(
                icon: "①",
                title: "Fast rooms",
                subtitle: "Create or join a match in seconds with a room code.",
              ),
              const SizedBox(height: 10),
              _featureCard(
                icon: "②",
                title: "Real-time play",
                subtitle:
                    "Every number call and turn syncs instantly for both players.",
              ),
              const SizedBox(height: 10),
              _featureCard(
                icon: "③",
                title: "Practice vs Bot",
                subtitle:
                    "No friends online? Play an offline match against the bot.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFB45309),
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatefulWidget {
  final String? winner;
  final bool isDraw;
  final VoidCallback onPlayAgain;

  const ResultScreen({
    super.key,
    required this.winner,
    required this.isDraw,
    required this.onPlayAgain,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int countdown = 7;

  String copyStatus = "";

  Timer? countdownTimer;
  Timer? restartTimer;

  final String websiteUrl = "https://bingogame-web-t73z.vercel.app/";

  @override
  void initState() {
    super.initState();

    restartTimer = Timer(const Duration(seconds: 7), () {
      widget.onPlayAgain();
    });

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    restartTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> copyWebsiteLink() async {
    try {
      await Clipboard.setData(ClipboardData(text: websiteUrl));

      setState(() {
        copyStatus = "Link copied";
      });
    } catch (_) {
      setState(() {
        copyStatus = "Copy failed";
      });
    }

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      setState(() {
        copyStatus = "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWin = widget.winner == "You";

    return CenteredCardPage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Game Result",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),

          const SizedBox(height: 18),

          if (!widget.isDraw) ...[
            Text(
              isWin ? "🏆 You Win" : "😞 You Lose",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isWin ? AppColors.success : AppColors.danger,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.winner ?? "",
              style: const TextStyle(fontSize: 18, color: AppColors.text),
            ),

            const SizedBox(height: 6),

            const Text(
              "BINGO completed 🎉",
              style: TextStyle(color: AppColors.muted),
            ),
          ] else ...[
            const Text(
              "🤝 Draw",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB45309),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Both players completed BINGO",
              style: TextStyle(color: AppColors.muted),
            ),
          ],

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onPlayAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text("Play Again"),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSoft,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  "Share this website with more friends",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${websiteUrl}",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: copyWebsiteLink,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.softBlueBg,
                          border: Border.all(color: AppColors.softBlueBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.copy,
                          size: 18,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ),
                  ],
                ),

                if (copyStatus.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      copyStatus,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "Auto restarting in ${countdown}s...",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

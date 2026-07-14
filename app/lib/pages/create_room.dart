import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../theme/app_theme.dart';

class CreateRoomScreen extends StatefulWidget {
  final dynamic grid;
  final dynamic user;
  final Function(String roomId) onCreated;

  const CreateRoomScreen({
    super.key,
    required this.grid,
    required this.user,
    required this.onCreated,
  });

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  String? roomId;
  String copyStatus = "";

  @override
  void initState() {
    super.initState();
    _createRoom();
  }

  Future<void> _createRoom() async {
    try {
      final res = await ApiService.createRoom();

      if (res["success"] != true) {
        return;
      }

      final createdRoomId = res["roomId"];

      setState(() {
        roomId = createdRoomId;
      });

      SocketService.socket.emit("join-room", {
        "roomId": createdRoomId,
        "user": {
          "_id": widget.user["_id"],
          "name": widget.user["name"],
          "grid": widget.grid,
          "role": "Host",
        },
      });
    } catch (e) {
      debugPrint("Create Room Error: $e");
    }
  }

  Future<void> _copyRoomId() async {
    if (roomId == null) return;

    try {
      await Clipboard.setData(ClipboardData(text: roomId!));

      setState(() {
        copyStatus = "Copied";
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
    if (roomId == null) {
      return AppBackground(
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.accent2),
              SizedBox(height: 16),
              Text(
                "Creating room...",
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      );
    }

    return CenteredCardPage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Room Created",
            style: TextStyle(fontSize: 15, color: AppColors.muted),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                roomId!,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: AppColors.accentDark,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: _copyRoomId,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
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

          const SizedBox(height: 8),

          SizedBox(
            height: 20,
            child: Text(
              copyStatus,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onCreated(roomId!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text("Go To Lobby"),
            ),
          ),
        ],
      ),
    );
  }
}

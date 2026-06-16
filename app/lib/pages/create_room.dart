import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/socket_service.dart';

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Create Room")),
      body: Center(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Room Created",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      roomId!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      onPressed: _copyRoomId,
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),

                if (copyStatus.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      copyStatus,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onCreated(roomId!);
                    },
                    child: const Text("Go To Lobby"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

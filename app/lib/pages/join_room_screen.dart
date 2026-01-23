import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../models/cell_model.dart';

class JoinRoomScreen extends StatefulWidget {
  final List<List<CellModel>> grid;
  final Map<String, dynamic> user;
  final Function(String roomId) onJoined;

  const JoinRoomScreen({
    super.key,
    required this.grid,
    required this.user,
    required this.onJoined,
  });

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  String roomId = "";
  final socket = SocketService().socket;

  Future<void> _joinRoom() async {
    if (roomId.trim().isEmpty) return;

    final res = await GameApi.joinRoom(roomId);

    if (res["success"] != true) {
      _showAlert(res["message"] ?? "Failed to join room");
      return;
    }

    // 🔌 JOIN ROOM AS INVITED
    socket.emit("join-room", {
      "roomId": roomId,
      "user": {
        "id": widget.user["_id"],
        "name": widget.user["name"],
        "grid": widget.grid
            .map(
              (row) => row
                  .map((cell) => {"value": cell.value, "chosen": cell.chosen})
                  .toList(),
            )
            .toList(),
        "role": "Invited",
      },
    });

    widget.onJoined(roomId);
  }

  void _showAlert(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Room")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Join Room", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),

            TextField(
              decoration: const InputDecoration(
                hintText: "Enter Room ID",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => roomId = v),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _joinRoom,
                child: const Text("Join Game"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

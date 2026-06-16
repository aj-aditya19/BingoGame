import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/socket_service.dart';

class JoinRoomScreen extends StatefulWidget {
  final dynamic grid;
  final dynamic user;
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
  final TextEditingController roomController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  Future<void> joinRoom() async {
    final roomId = roomController.text.trim();

    if (roomId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter Room ID")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final res = await ApiService.joinRoom(roomId);

      if (res["success"] != true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Unable to join room")),
        );

        setState(() {
          isLoading = false;
        });

        return;
      }

      SocketService.socket.emit("join-room", {
        "roomId": roomId,
        "user": {
          "_id": widget.user["_id"],
          "name": widget.user["name"],
          "grid": widget.grid,
          "role": "Invited",
        },
      });

      widget.onJoined(roomId);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Room")),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Join Room",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: roomController,
                    decoration: const InputDecoration(
                      labelText: "Room ID",
                      hintText: "Enter Room ID",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : joinRoom,
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Join Game"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../models/cell_model.dart';

class CreateRoomScreen extends StatefulWidget {
  final List<List<CellModel>> grid;
  final Map<String, dynamic> user;
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
  final socket = SocketService().socket;

  @override
  void initState() {
    super.initState();
    _createRoom();
  }

  // 🔥 CREATE ROOM ON SERVER (same as React useEffect)
  Future<void> _createRoom() async {
    final res = await GameApi.createRoom();

    if (res["success"] != true) return;

    setState(() {
      roomId = res["roomId"];
    });

    // 🔌 JOIN ROOM AS HOST
    socket.emit("join-room", {
      "roomId": res["roomId"],
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
        "role": "Host",
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Room")),
      body: Center(
        child: roomId == null
            ? const Text("Creating room...", style: TextStyle(fontSize: 18))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Room Created", style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Text(
                    roomId!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => widget.onCreated(roomId!),
                    child: const Text("Go To Lobby"),
                  ),
                ],
              ),
      ),
    );
  }
}

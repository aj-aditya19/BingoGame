import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;

  factory SocketService() => _instance;

  SocketService._internal() {
    String url;

    if (kIsWeb) {
      // Running on web
      url = 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      // Android emulator
      url = 'http://10.0.2.2:5000';
    } else if (Platform.isIOS) {
      // iOS simulator
      url = 'http://127.0.0.1:5000';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop
      url = 'http://127.0.0.1:5000';
    } else {
      url = 'http://127.0.0.1:5000'; // fallback
    }

    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    // Debug logs
    socket.onConnect((_) => print("✅ Socket connected: ${socket.id}"));
    socket.onConnectError((data) => print("❌ Connect error: $data"));
    socket.onDisconnect((_) => print("❌ Socket disconnected"));
    socket.onReconnect((_) => print("🔄 Reconnected"));
    socket.onReconnectAttempt((_) => print("🔄 Reconnect attempt"));
  }

  void connect() {
    if (!socket.connected) {
      socket.connect();
    }
  }
}

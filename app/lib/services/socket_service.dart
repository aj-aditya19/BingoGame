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
      url = 'wss://bingogame-6eoj.onrender.com';
    } else if (Platform.isAndroid) {
      // Android emulator
      url = 'wss://bingogame-6eoj.onrender.com';
    } else if (Platform.isIOS) {
      // iOS simulator
      url = 'wss://bingogame-6eoj.onrender.com';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop
      url = 'wss://bingogame-6eoj.onrender.com';
    } else {
      url = 'wss://bingogame-6eoj.onrender.com'; // fallback
    }

    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          // .enableForceNew()
          .build(),
    );

    // Debug logs
    socket.onConnect(
      (_) => print("✅ Socket connected in flutter: ${socket.id}"),
    );
    socket.onConnectError((data) => print("❌ Connect error in flutter: $data"));
    socket.onDisconnect((_) => print("❌ Socket disconnected in flutter"));
    socket.onReconnect((_) => print("🔄 Reconnected in flutter"));
    socket.onReconnectAttempt((_) => print("🔄 Reconnect attempt in flutter"));
  }

  void connect() {
    if (!socket.connected) {
      socket.connect();
    }
  }
}

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://bingogame-6eoj.onrender.com',
  );

  static late IO.Socket socket;
  static bool _isConnected = false;
  static int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const int _reconnectDelayMs = 1000;

  /// Initialize socket connection with proper error handling
  static void init({String? customUrl}) {
    final url = customUrl ?? socketUrl;

    print('🔌 Initializing Socket.io connection to: $url');

    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling']) // support both transports
          .enableReconnection()
          .setReconnectionAttempts(_maxReconnectAttempts)
          .setReconnectionDelay(_reconnectDelayMs)
          .setReconnectionDelayMax(5000)
          .enableForceNew()
          .enableAutoConnect()
          .build(),
    );

    _setupEventListeners();
    socket.connect();
  }

  /// Setup all socket event listeners
  static void _setupEventListeners() {
    socket.onConnect((_) {
      _isConnected = true;
      _reconnectAttempts = 0;
      print('✅ Socket connected: ${socket.id}');
    });

    socket.onDisconnect((_) {
      _isConnected = false;
      print('❌ Socket disconnected');
    });

    socket.onConnectError((err) {
      _isConnected = false;
      _reconnectAttempts++;
      print(
        '⚠️ Connect error (attempt $_reconnectAttempts/$_maxReconnectAttempts): $err',
      );
    });

    socket.onError((err) {
      print('⚠️ Socket error: $err');
    });

    socket.on('exception', (data) {
      print('⚠️ Server exception: $data');
    });

    socket.on('connect_error', (data) {
      print('⚠️ Connection error: $data');
    });
  }

  /// Check if socket is connected
  static bool get isConnected {
    try {
      return _isConnected && socket.connected;
    } catch (e) {
      return false;
    }
  }

  /// Emit event
  static void emit(String event, [dynamic data]) {
    try {
      if (!isConnected) {
        print('⚠️ Socket not connected, queuing event: $event');
        // Queue event for later or handle offline
        return;
      }

      if (data != null) {
        socket.emit(event, data);
      } else {
        socket.emit(event);
      }
    } catch (e) {
      print('❌ Error emitting event $event: $e');
    }
  }

  /// Listen to event with callback
  static void on(String event, Function(dynamic)? callback) {
    try {
      if (callback != null) {
        socket.on(event, callback);
      }
    } catch (e) {
      print('❌ Error listening to event $event: $e');
    }
  }

  /// Listen to event once only
  static void once(String event, Function(dynamic)? callback) {
    try {
      if (callback != null) {
        socket.once(event, callback);
      }
    } catch (e) {
      print('❌ Error setting up once listener for $event: $e');
    }
  }

  /// Remove listener
  static void off(String event) {
    try {
      socket.off(event);
    } catch (e) {
      print('❌ Error removing listener for $event: $e');
    }
  }

  /// Reconnect to socket
  static void reconnect() {
    try {
      print('🔄 Attempting manual reconnect...');
      socket.disconnect();
      socket.connect();
    } catch (e) {
      print('❌ Error during reconnect: $e');
    }
  }

  /// Gracefully dispose socket connection
  static void dispose() {
    try {
      print('🛑 Disposing socket connection...');
      socket.disconnect();
      socket.dispose();
      _isConnected = false;
      print('✓ Socket disposed');
    } catch (e) {
      print('❌ Error during dispose: $e');
    }
  }

  /// Get socket instance directly (for advanced usage)
  static IO.Socket getInstance() => socket;
}

import 'package:socket_io_client/socket_io_client.dart' as IO;
import "../config/app_config.dart";

class SocketService {
  static late IO.Socket socket;

  static void connect() {
    socket = IO.io(
      AppConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .build(),
    );

    socket.connect();
  }
}

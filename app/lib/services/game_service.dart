import 'dart:convert';
import 'package:http/http.dart' as http;

class GameService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bingogame-6eoj.onrender.com/api',
  );

  /// Create a new game room
  /// Returns {success, roomId, message}
  static Future<Map<String, dynamic>> createRoom() async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/game/room/create'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Error creating room: $e'};
    }
  }

  /// Join an existing game room
  /// Returns {success, message}
  static Future<Map<String, dynamic>> joinRoom(String roomId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/game/room/join'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'roomId': roomId.trim()}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Error joining room: $e'};
    }
  }

  /// Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response res) {
    try {
      final body = jsonDecode(res.body);

      if (res.statusCode != 200) {
        return {
          'success': false,
          'message': body['message'] ?? 'Server error: ${res.statusCode}',
        };
      }

      if (body is Map<String, dynamic>) {
        return body;
      }

      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to parse response: $e'};
    }
  }
}

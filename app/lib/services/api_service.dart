import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiUrl;

  static Future<dynamic> login(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  static Future<dynamic> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  static Future<dynamic> createRoom() async {
    final response = await http.post(
      Uri.parse("$baseUrl/game/room/create"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<dynamic> joinRoom(String roomId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/game/room/join"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"roomId": roomId}),
    );

    return jsonDecode(response.body);
  }
}

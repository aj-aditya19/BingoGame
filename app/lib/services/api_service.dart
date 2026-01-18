import 'dart:convert';
import 'package:http/http.dart' as http;

const String BASE_URL = "http://localhost:5000/api";

class ApiService {
  static Future<Map<String, dynamic>> login(Map<String, String> data) async {
    final res = await http.post(
      Uri.parse("$BASE_URL/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register(Map<String, String> data) async {
    final res = await http.post(
      Uri.parse("$BASE_URL/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> googleAuth(String token) async {
    final res = await http.post(
      Uri.parse("$BASE_URL/google"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"token": token}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> setPassword(String password) async {
    final res = await http.post(
      Uri.parse("$BASE_URL/set-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"password": password}),
    );
    return jsonDecode(res.body);
  }
}

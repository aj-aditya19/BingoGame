import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bingogame-6eoj.onrender.com/api',
  );

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final uri = Uri.parse('$baseUrl/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final body = jsonDecode(res.body);
    if (body is Map<String, dynamic>) return body;
    return {'success': false, 'message': 'Invalid response'};
  }
}

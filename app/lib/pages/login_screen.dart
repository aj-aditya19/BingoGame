import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLogin;
  final VoidCallback onRegister;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _handleLogin() async {
    setState(() => _loading = true);

    final form = {
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    final res = await Api.login(form);

    setState(() => _loading = false);

    if (res["success"] == true) {
      widget.onLogin(res["user"]);
      print("Login successful");
    } else {
      _showAlert(res["message"] ?? "Login failed");
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      final UserCredential result = await _auth.signInWithPopup(googleProvider);
      final token = await result.user?.getIdToken();

      if (token == null) return;

      final res = await Api.googleAuth(token);

      if (res["success"] == true) {
        widget.onLogin(res["user"]);
      } else {
        _showAlert("Google login failed");
      }
    } catch (e) {
      _showAlert(e.toString());
    }
  }

  void _showAlert(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleLogin,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleGoogleLogin,
                child: const Text("Login with Google"),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: widget.onRegister,
              child: const Text(
                "New user? Register",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

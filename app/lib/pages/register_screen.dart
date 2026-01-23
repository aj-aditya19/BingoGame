import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  final Function([String? type]) onRegister;

  const RegisterScreen({super.key, required this.onRegister});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _handleRegister() async {
    if (_passwordController.text.isEmpty) {
      _showAlert("Password is required");
      return;
    }

    setState(() => _loading = true);

    final form = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    final res = await Api.register(form);

    setState(() => _loading = false);

    if (res["success"] == true) {
      widget.onRegister();
    } else {
      _showAlert(res["message"] ?? "Registration failed");
    }
  }

  Future<void> _handleGoogleRegister() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      final UserCredential result = await _auth.signInWithPopup(googleProvider);
      final token = await result.user?.getIdToken();

      if (token == null) return;

      final res = await Api.googleAuth(token);

      if (res["success"] == true) {
        if (res["needPassword"] == true) {
          widget.onRegister("set-password");
        } else {
          widget.onRegister("input");
        }
      } else {
        _showAlert("Google registration failed");
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
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),
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
                onPressed: _loading ? null : _handleRegister,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Register"),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleGoogleRegister,
                child: const Text("Register with Google"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

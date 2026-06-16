import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(dynamic user) onLogin;
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
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> login() async {
    setState(() {
      loading = true;
    });

    try {
      final res = await ApiService.login({
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      });

      if (res["success"] == true) {
        widget.onLogin(res["user"]);
      } else {
        showMessage(res["message"] ?? "Login Failed");
      }
    } catch (e) {
      showMessage(e.toString());
    }

    setState(() {
      loading = false;
    });
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : login,
              child: const Text("Login"),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: widget.onRegister,
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}

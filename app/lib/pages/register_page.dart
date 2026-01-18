import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import 'grid_page.dart';
import 'set_password_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io'; // for kisWeb
import 'package:flutter/foundation.dart'; // for platform

class RegisterPage extends StatefulWidget {
  final VoidCallback? onRegister;
  RegisterPage({this.onRegister});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  /// Email registration
  void handleRegister() async {
    if (passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Password is required");
      return;
    }

    setState(() => loading = true);
    final res = await ApiService.register({
      "name": nameController.text,
      "email": emailController.text,
      "password": passwordController.text,
    });
    setState(() => loading = false);

    if (res['success']) {
      Fluttertoast.showToast(msg: "Registered successfully");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GridPage()),
      );
    } else {
      Fluttertoast.showToast(msg: res['message'] ?? "Registration failed");
    }
  }

  /// Google registration
  void handleGoogleRegister() async {
    if (!kIsWeb && Platform.isWindows) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Register not supported on Windows")),
      );
      return;
    }
    setState(() => loading = true);

    final userCred = await FirebaseService.signInWithGoogle();
    if (userCred == null) {
      setState(() => loading = false);
      Fluttertoast.showToast(msg: "Google registration cancelled");
      return;
    }

    final token = await FirebaseService.getFirebaseToken(userCred.user!);
    final res = await ApiService.googleAuth(token!);

    setState(() => loading = false);

    if (res['success']) {
      if (res['needPassword'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SetPasswordPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GridPage()),
        );
      }
    } else {
      Fluttertoast.showToast(msg: "Google registration failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : handleRegister,
              child: Text(loading ? "Registering..." : "Register"),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : handleGoogleRegister,
              child: Text("Register with Google"),
            ),
          ],
        ),
      ),
    );
  }
}

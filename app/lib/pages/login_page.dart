import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import 'register_page.dart';
import 'grid_page.dart';
import 'set_password_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io'; // for kisWeb
import 'package:flutter/foundation.dart'; // for platform

class LoginPage extends StatefulWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;

  LoginPage({this.onLogin, this.onRegister});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool loading = false;

  void handleLogin() async {
    setState(() => loading = true);

    final res = await ApiService.login({
      "email": emailController.text,
      "password": passwordController.text,
    });

    setState(() => loading = false);

    if (res['success']) {
      Fluttertoast.showToast(msg: "Login successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GridPage()),
      );
    } else {
      Fluttertoast.showToast(msg: res['message'] ?? "Login failed");
    }
  }

  void handleGoogleLogin() async {
    if (!kIsWeb && Platform.isWindows) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Login not supported on Windows")),
      );
      return;
    }
    setState(() => loading = true);

    final userCred = await FirebaseService.signInWithGoogle();
    if (userCred == null) {
      setState(() => loading = false);
      Fluttertoast.showToast(msg: "Google login cancelled");
      return;
    }

    // Get Firebase ID token safely
    String? token;
    try {
      token = await userCred.user?.getIdToken();
      if (token == null) {
        Fluttertoast.showToast(msg: "Failed to get token");
        setState(() => loading = false);
        return;
      }
    } catch (e) {
      print("Token error: $e");
      Fluttertoast.showToast(msg: "Error getting token");
      setState(() => loading = false);
      return;
    }

    // Send token to backend
    final res = await ApiService.googleAuth(token);

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
      Fluttertoast.showToast(msg: "Google login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              onPressed: loading ? null : handleLogin,
              child: Text(loading ? "Logging in..." : "Login"),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : handleGoogleLogin,
              child: Text("Login with Google"),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: Text("New user? Register here"),
            ),
          ],
        ),
      ),
    );
  }
}

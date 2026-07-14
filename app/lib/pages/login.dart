import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

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
    return CenteredCardPage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Welcome Back",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password"),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Login"),
            ),
          ),

          const SizedBox(height: 16),

          const Divider(),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: AppColors.muted),
              ),
              GestureDetector(
                onTap: widget.onRegister,
                child: const Text(
                  "Create one",
                  style: TextStyle(
                    color: AppColors.accentDark,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

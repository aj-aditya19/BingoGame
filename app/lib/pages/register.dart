import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  final Function(dynamic user) onRegister;

  const RegisterScreen({super.key, required this.onRegister});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> register() async {
    if (passwordController.text.trim().isEmpty) {
      showMessage("Password required");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final res = await ApiService.register({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      });

      if (res["success"] == true) {
        widget.onRegister(res["user"]);
      } else {
        showMessage(res["message"] ?? "Registration failed");
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
      maxWidth: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Create Account",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),

          const SizedBox(height: 12),

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
              onPressed: loading ? null : register,
              child: loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Register"),
            ),
          ),
        ],
      ),
    );
  }
}

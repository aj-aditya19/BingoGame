import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SetPasswordScreen extends StatefulWidget {
  final VoidCallback onDone;

  const SetPasswordScreen({super.key, required this.onDone});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _savePassword() async {
    if (_passwordController.text.isEmpty) {
      _showAlert("Password required");
      return;
    }

    setState(() => _loading = true);

    final res = await Api.setPassword(_passwordController.text.trim());

    setState(() => _loading = false);

    if (res["success"] == true) {
      widget.onDone();
    } else {
      _showAlert(res["message"] ?? "Failed to set password");
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
      appBar: AppBar(title: const Text("Set Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Use this password for future email logins"),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _savePassword,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_name.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() => _loading = true);

    final res = await AuthService.register(
      _name.text,
      _email.text,
      _password.text,
    );

    setState(() => _loading = false);

    if ((res['success'] ?? false) == true) {
      if (!mounted) return;

      // After register → go to login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final msg = res['message'] ?? 'Registration failed';

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07111F), Color(0xFF0B1220)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        hintText: 'Name',
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        filled: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('Register'),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text("Already have an account? Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

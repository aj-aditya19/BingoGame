import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'grid_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SetPasswordPage extends StatefulWidget {
  final VoidCallback? onDone;
  SetPasswordPage({this.onDone});
  @override
  _SetPasswordPageState createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  TextEditingController passwordController = TextEditingController();
  bool loading = false;

  void savePassword() async {
    if (passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Password required");
      return;
    }

    setState(() => loading = true);
    final res = await ApiService.setPassword(passwordController.text);
    setState(() => loading = false);

    if (res['success']) {
      Fluttertoast.showToast(msg: "Password saved");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GridPage()),
      );
    } else {
      Fluttertoast.showToast(msg: res['message'] ?? "Failed to save password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Password")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Use this password for future logins",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "New Password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : savePassword,
              child: Text(loading ? "Saving..." : "Save"),
            ),
          ],
        ),
      ),
    );
  }
}

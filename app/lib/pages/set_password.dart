// import 'package:flutter/material.dart';
// import '../services/api_service.dart';

// class SetPasswordScreen extends StatefulWidget {
//   final VoidCallback onDone;

//   const SetPasswordScreen({super.key, required this.onDone});

//   @override
//   State<SetPasswordScreen> createState() => _SetPasswordScreenState();
// }

// class _SetPasswordScreenState extends State<SetPasswordScreen> {
//   final passwordController = TextEditingController();

//   bool loading = false;

//   Future<void> savePassword() async {
//     final password = passwordController.text.trim();

//     if (password.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Password required")));
//       return;
//     }

//     setState(() {
//       loading = true;
//     });

//     try {
//       final res = await ApiService.setPassword(password);

//       if (res["success"] == true) {
//         widget.onDone();
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(res["message"] ?? "Failed")));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(e.toString())));
//     }

//     setState(() {
//       loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Set Password")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Text("Use this password for future email logins"),

//             const SizedBox(height: 20),

//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: "New Password"),
//             ),

//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: loading ? null : savePassword,
//               child: const Text("Save Password"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

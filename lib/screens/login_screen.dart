import 'package:flutter/material.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  final Function(Role) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String email = emailController.text.trim();
                Role role;

                if (email.contains("admin")) {
                  role = Role.admin;
                } else if (email.contains("committee")) {
                  role = Role.committee;
                } else {
                  role = Role.member;
                }

                // এই জায়গাটাই মূল — এখন Login এ ক্লিক করলে অন্য স্ক্রিনে যাবে
                widget.onLogin(role);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

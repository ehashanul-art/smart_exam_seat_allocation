import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/auth_service.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  void _login() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      await auth.signIn(email: email.text.trim(), password: password.text.trim());
      Fluttertoast.showToast(msg: 'Logged in');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } catch (e) {
      Fluttertoast.showToast(msg: 'Login failed: ${e.toString()}');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Smart Exam Seat System', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                CustomTextField(controller: email, label: 'Email'),
                const SizedBox(height: 12),
                CustomTextField(controller: password, label: 'Password', obscure: true),
                const SizedBox(height: 16),
                CustomButton(text: 'Login', loading: loading, onPressed: _login),
                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Create account'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'dashboard_screen.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  bool loading = false;
  void _register() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      await auth.signUp(email: email.text.trim(), password: password.text.trim(), name: name.text.trim(), role: 'admin');
      Fluttertoast.showToast(msg: 'Account created');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } catch (e) {
      Fluttertoast.showToast(msg: 'Register failed: ${e.toString()}');
    } finally {
      setState(() => loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              const Text('Create Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              CustomTextField(controller: name, label: 'Name'),
              const SizedBox(height: 12),
              CustomTextField(controller: email, label: 'Email'),
              const SizedBox(height: 12),
              CustomTextField(controller: password, label: 'Password', obscure: true),
              const SizedBox(height: 16),
              CustomButton(text: 'Sign Up', loading: loading, onPressed: _register),
            ]),
          ),
        ),
      ),
    );
  }
}

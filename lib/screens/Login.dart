import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_admin_dashboard.dart';
import 'teacher_dashboard.dart';
import '../theme.dart';
import 'main_admin_signIn.dart';
import 'student_dashboard.dart';
class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
enum LoginRole { Student, Teacher, MainAdmin }
class _LoginScreenState extends State<LoginScreen> {
  LoginRole _role = LoginRole.Student;
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = false;
  Future<void> _login() async {
    final userInput = _userController.text.trim();
    final password = _passController.text.trim();
    if (userInput.isEmpty || password.isEmpty) {
      _showError('Please enter all fields.');
      return;
    }
    setState(() => _loading = true);
    try {
      if (_role == LoginRole.MainAdmin) {
        final userCred = await _auth.signInWithEmailAndPassword(
          email: userInput,
          password: password,
        );
        final query = await _firestore
            .collection('users')
            .where('email', isEqualTo: userInput)
            .limit(1)
            .get();
        if (query.docs.isEmpty) {
          _showError('Access denied. Not an admin.');
          await _auth.signOut();
          return;
        }
        final userData = query.docs.first.data();
        final role = userData['role'] ?? '';
        if (role == 'main_admin' || role == 'admin') {
          Navigator.pushReplacementNamed(context, MainAdminDashboard.routeName);
        } else {
          _showError('Access denied. Not an admin.');
          await _auth.signOut();
        }
      } else if (_role == LoginRole.Teacher) {
        final query = await _firestore
            .collection('teachers')
            .where('gmail', isEqualTo: userInput)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          Navigator.pushReplacementNamed(context, TeacherDashboard.routeName);
        } else {
          _showError('Invalid teacher email or password.');
        }
      } else {
        final query = await _firestore
            .collection('students')
            .where('roll', isEqualTo: userInput)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          final studentRollId = userInput;
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StudentDashboard(studentRollId: studentRollId),
            ),
          );
        } else {
          _showError('Invalid student ID or password.');
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication failed.');
    } catch (e) {
      _showError('An error occurred. Please try again.');
    } finally {
      setState(() => _loading = false);
    }
  }
  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
  @override
  Widget build(BuildContext context) {
    final headerStyle =
    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              child: ListView(
                children: [
                  Row(children: [
                    Icon(Icons.menu, color: AppTheme.primary),
                    const SizedBox(width: 12),
                    const Text('Welcome',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 18),
                    child: Column(
                      children: const [
                        Icon(Icons.school, size: 48, color: Colors.white),
                        SizedBox(height: 12),
                        Text('Smart Exam\nSeat Allocation\nSystem',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ChoiceChip(
                        label: const Text('Student'),
                        selected: _role == LoginRole.Student,
                        onSelected: (_) =>
                            setState(() => _role = LoginRole.Student),
                        selectedColor: AppTheme.primary,
                      ),
                      ChoiceChip(
                        label: const Text('Teacher'),
                        selected: _role == LoginRole.Teacher,
                        onSelected: (_) =>
                            setState(() => _role = LoginRole.Teacher),
                        selectedColor: AppTheme.primary,
                      ),
                      ChoiceChip(
                        label: const Text('Main Admin'),
                        selected: _role == LoginRole.MainAdmin,
                        onSelected: (_) =>
                            setState(() => _role = LoginRole.MainAdmin),
                        selectedColor: AppTheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  _role == LoginRole.Student
                                      ? 'Student'
                                      : (_role == LoginRole.Teacher
                                      ? 'Teacher'
                                      : 'Admin'),
                                  style: headerStyle)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _userController,
                            decoration: InputDecoration(
                                hintText: _role == LoginRole.Student
                                    ? 'Roll ID'
                                    : 'Email'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passController,
                            obscureText: true,
                            decoration:
                            const InputDecoration(hintText: 'Password'),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: _loading ? null : _login,
                            child: const Center(
                                child: Text('Log In',
                                    style: TextStyle(fontSize: 16))),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                              onPressed: _loading ? null : () {},
                              child: const Text('Forgot password?')),
                          const SizedBox(height: 12),
                          Divider(thickness: 1),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, MainAdminSignUp.routeName);
                            },
                            icon: const Icon(
                                Icons.admin_panel_settings_outlined),
                            label: const Text(
                              'Login as Main Admin',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
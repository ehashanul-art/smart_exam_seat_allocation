import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
class AddTeacherScreen extends StatefulWidget {
  static const String routeName = '/add-teacher';
  @override
  _AddTeacherScreenState createState() => _AddTeacherScreenState();
}
class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name, _email, _designation;
  bool _loading = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Future<void> _createTeacher() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      const defaultPassword = 'teacher123';
      final String finalEmail = _email!.trim();
      final cred = await _auth.createUserWithEmailAndPassword(
        email: finalEmail,
        password: defaultPassword,
      );
      final uid = cred.user!.uid;
      await _firestore.collection('teachers').doc(uid).set({
        'id': uid,
        'name': _name,
        'gmail': finalEmail,
        'designation': _designation,
        'is_admin': false,
        'role': 'teacher',
        'password': defaultPassword,
        'created_at': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Teacher added successfully!')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Teacher')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Name'),
                      onSaved: (v) => _name = v,
                      validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Email'),
                      onSaved: (v) => _email = v,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Designation'),
                      onSaved: (v) => _designation = v,
                      validator: (v) =>
                      v!.isEmpty ? 'Enter designation' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _createTeacher,
                      child: const Text('Create Teacher'),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
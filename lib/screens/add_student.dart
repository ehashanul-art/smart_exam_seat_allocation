import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'dart:math';
class AddStudentScreen extends StatefulWidget {
  static const String routeName = '/add-student';
  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}
class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name, roll, batch, levelTeam;
  bool autoGen = true;
  bool loading = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => loading = true);
    try {
      final email = autoGen
          ? '${roll ?? "student"}@student.com'
          : '${roll}@student.com';
      final password = autoGen ? _generatePassword() : '123456';
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      await _firestore.collection('students').doc(uid).set({
        'id': uid,
        'name': name,
        'roll': roll,
        'batch': batch,
        'level_team': levelTeam,
        'email': email,
        'password': password,
        'assigned_exam_id': null,
        'room_id': null,
        'seat_number': null,
        'created_at': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Student added successfully!')),
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
      setState(() => loading = false);
    }
  }
  String _generatePassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(8, (index) => chars[rand.nextInt(chars.length)]).join();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Full Name'),
                      onSaved: (v) => name = v,
                      validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Roll ID'),
                      onSaved: (v) => roll = v,
                      validator: (v) => v!.isEmpty ? 'Enter roll ID' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Batch'),
                      onSaved: (v) => batch = v,
                      validator: (v) => v!.isEmpty ? 'Enter batch' : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(hintText: 'Level-Team'),
                      items: ['1-I', '1-II', '2-I', '2-II', '3-I', '3-II', '4-I', '4-II']
                          .map((e) => DropdownMenuItem(child: Text(e), value: e))
                          .toList(),
                      onChanged: (v) => levelTeam = v,
                      validator: (v) => v == null ? 'Select level-team' : null,
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Checkbox(value: autoGen, onChanged: (v) => setState(() => autoGen = v!)),
                      const Text('Auto-generate ID and password')
                    ]),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: loading ? null : _addStudent,
                      child: const Text('Submit'),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          if (loading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
class AddCourseScreen extends StatefulWidget {
  static const String routeName = '/add-course';
  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}
class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  String? _levelTeam;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = false;
  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate() || _levelTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _firestore.collection('courses').add({
        'name': _nameCtrl.text.trim(),
        'code': _codeCtrl.text.trim(),
        'levelTeam': _levelTeam,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course added successfully')),
      );
      _formKey.currentState!.reset();
      setState(() => _levelTeam = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding course: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Course')),
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
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(hintText: 'Course Name'),
                        validator: (v) =>
                        (v ?? '').isEmpty ? 'Course name required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _codeCtrl,
                        decoration: const InputDecoration(hintText: 'Course Code'),
                        validator: (v) =>
                        (v ?? '').isEmpty ? 'Course code required' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(hintText: 'Level-Team'),
                        value: _levelTeam,
                        items: [
                          '1-I','1-II','2-I','2-II','3-I','3-II','4-I','4-II'
                        ]
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _levelTeam = v),
                        validator: (v) => v == null ? 'Select Level-Team' : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _addCourse,
                          child: const Text('Add Course'),
                        ),
                      ),
                    ],
                  ),
                ),
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
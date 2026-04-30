import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
class CreateExamScreen extends StatefulWidget {
  static const String routeName = '/create-exam';
  final DocumentSnapshot? exam;
  const CreateExamScreen({Key? key, this.exam}) : super(key: key);
  @override
  _CreateExamScreenState createState() => _CreateExamScreenState();
}
class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _courseController = TextEditingController();
  String? levelTeam, examType;
  DateTime? dateTime;
  bool _loading = false;
  bool _isEditing = false;
  List<Map<String, String>> _courseSuggestions = [];
  @override
  void initState() {
    super.initState();
    _isEditing = widget.exam != null;
    _fetchCourses();
    if (_isEditing) {
      _populateFields();
    }
  }
  void _populateFields() {
    final data = widget.exam!.data() as Map<String, dynamic>;
    _courseController.text = data['course_name'] ?? '';
    levelTeam = data['level_team'];
    examType = data['exam_type'];
    if (data['timestamp'] != null) {
      dateTime = (data['timestamp'] as Timestamp).toDate();
    }
    setState(() {});
  }
  Future<void> _fetchCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      final courses = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] as String? ?? '',
          'code': data['code'] as String? ?? '',
        };
      }).where((c) => c['name']!.isNotEmpty && c['code']!.isNotEmpty).toList();
      setState(() {
        _courseSuggestions = courses;
      });
    } catch (e) {
    }
  }
  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time')),
      );
      return;
    }
    final courseName = _courseController.text;
    final isValidCourse = _courseSuggestions.any((c) => c['name'] == courseName);
    if (!isValidCourse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid course from the suggestions')),
      );
      return;
    }
    setState(() => _loading = true);
    final examData = {
      'course_name': courseName,
      'level_team': levelTeam,
      'exam_type': examType,
      'timestamp': dateTime,
      'created_at': FieldValue.serverTimestamp(),
    };
    try {
      if (_isEditing) {
        await _firestore.collection('exams').doc(widget.exam!.id).update(examData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Exam updated successfully!')),
        );
      } else {
        await _firestore.collection('exams').add(examData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Exam created successfully!')),
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
    } finally {
      setState(() => _loading = false);
    }
  }
  Future<void> _deleteExam() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam?'),
        content: const Text('Are you sure you want to delete this exam? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    setState(() => _loading = true);
    try {
      await _firestore.collection('exams').doc(widget.exam!.id).delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam deleted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
    } finally {
      setState(() => _loading = false);
    }
  }
  @override
  void dispose() {
    _courseController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Exam' : 'Create Exam'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _loading ? null : _deleteExam,
            )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    Autocomplete<Map<String, String>>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        final text = textEditingValue.text.toLowerCase();
                        if (text == '') {
                          return const Iterable<Map<String, String>>.empty();
                        }
                        return _courseSuggestions.where((option) {
                          final name = option['name']!.toLowerCase();
                          final code = option['code']!.toLowerCase();
                          return name.contains(text) || code.contains(text);
                        });
                      },
                      displayStringForOption: (option) => option['name']!,
                      fieldViewBuilder: (context, fieldController, fieldFocusNode, onFieldSubmitted) {
                        if (fieldController.text != _courseController.text) {
                          fieldController.text = _courseController.text;
                        }
                        return TextFormField(
                          controller: fieldController,
                          focusNode: fieldFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Course (type to search...)',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a course';
                            }
                            return null;
                          },
                        );
                      },
                      onSelected: (selection) {
                        _courseController.text = selection['name']!;
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: levelTeam,
                      decoration: InputDecoration(hintText: 'Level-Team'),
                      items: [
                        '1-I', '1-II', '2-I', '2-II', '3-I', '3-II', '4-I', '4-II'
                      ]
                          .map((e) => DropdownMenuItem(child: Text(e), value: e))
                          .toList(),
                      onChanged: (v) => levelTeam = v,
                      validator: (v) =>
                      v == null ? 'Please select a level-team' : null,
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: examType,
                      decoration: InputDecoration(hintText: 'Exam-Type'),
                      items: ['Mid', 'Final']
                          .map((e) => DropdownMenuItem(child: Text(e), value: e))
                          .toList(),
                      onChanged: (v) => examType = v,
                      validator: (v) =>
                      v == null ? 'Please select an exam type' : null,
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text(dateTime == null
                          ? 'Select Date & Time'
                          : DateFormat('yyyy-MM-dd – hh:mm a').format(dateTime!)),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final d = await showDatePicker(
                            context: context,
                            initialDate: dateTime ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030));
                        if (d != null) {
                          final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(dateTime ?? DateTime.now()));
                          if (t != null) {
                            setState(() {
                              dateTime =
                                  DateTime(d.year, d.month, d.day, t.hour, t.minute);
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loading ? null : _saveExam,
                      child: Text(_isEditing ? 'Update Exam' : 'Create Exam'),
                    ),
                  ]),
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
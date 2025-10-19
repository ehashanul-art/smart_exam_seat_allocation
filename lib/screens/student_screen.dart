import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/student_model.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});
  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final FirestoreService _fs = FirestoreService();
  final name = TextEditingController();
  final dept = TextEditingController();
  final roll = TextEditingController();

  void _addStudent() {
    if (name.text.trim().isEmpty) return;
    final s = Student(id: '', name: name.text.trim(), department: dept.text.trim(), roll: roll.text.trim());
    _fs.addStudent(s);
    name.clear(); dept.clear(); roll.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: dept, decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: roll, decoration: const InputDecoration(labelText: 'Roll', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _addStudent, child: const Text('Add Student')),
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<Student>>(
            stream: _fs.studentsStream(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final students = snap.data!;
              if (students.isEmpty) return const Center(child: Text('No students yet'));
              return ListView.separated(
                itemCount: students.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, i) {
                  final s = students[i];
                  return ListTile(
                    title: Text(s.name),
                    subtitle: Text('${s.department} • ${s.roll}'),
                    trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _fs.deleteStudent(s.id)),
                  );
                },
              );
            },
          ),
        )
      ]),
    );
  }
}

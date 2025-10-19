import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/exam_model.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final FirestoreService _fs = FirestoreService();
  final course = TextEditingController();
  final dept = TextEditingController();
  DateTime? chosenDate;
  TimeOfDay? chosenTime;

  void _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (d != null) {
      setState(() {
        chosenDate = d;
        chosenTime = null; // reset time when new date chosen
      });
    }
  }

  void _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => chosenTime = t);
  }

  void _addExam() {
    if (course.text.trim().isEmpty || chosenDate == null || chosenTime == null) return;

    // Combine date + time into a single DateTime for Firestore
    final dateTime = DateTime(
      chosenDate!.year,
      chosenDate!.month,
      chosenDate!.day,
      chosenTime!.hour,
      chosenTime!.minute,
    );

    final e = Exam(
      id: '',
      courseName: course.text.trim(),
      date: dateTime,
      department: dept.text.trim(),
    );

    _fs.addExam(e);
    course.clear();
    dept.clear();
    setState(() {
      chosenDate = null;
      chosenTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: course,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dept,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),

                // DATE PICKER
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chosenDate == null
                            ? 'Pick exam date'
                            : chosenDate!.toLocal().toString().split(' ')[0],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickDate,
                      child: const Text('Choose Date'),
                    ),
                  ],
                ),

                // TIME PICKER (visible only after date chosen)
                if (chosenDate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chosenTime == null
                              ? 'Pick exam time'
                              : chosenTime!.format(context),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _pickTime,
                        child: const Text('Choose Time'),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addExam,
                  child: const Text('Add Exam'),
                ),
              ],
            ),
          ),

          // DISPLAY EXAMS
          Expanded(
            child: StreamBuilder<List<Exam>>(
              stream: _fs.examsStream(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final exams = snap.data!;
                if (exams.isEmpty) return const Center(child: Text('No exams'));

                return ListView.separated(
                  itemCount: exams.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final e = exams[i];
                    final dateStr = e.date.toLocal().toString().split(' ')[0];
                    final timeStr =
                    TimeOfDay.fromDateTime(e.date).format(context);
                    return ListTile(
                      title: Text(e.courseName),
                      subtitle: Text('${e.department} • $dateStr • $timeStr'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _fs.deleteExam(e.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

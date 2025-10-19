import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/seat_plan_model.dart';
import '../models/student_model.dart';
import '../models/room_model.dart';
import '../models/exam_model.dart';

class SeatPlanScreen extends StatefulWidget {
  const SeatPlanScreen({super.key});

  @override
  State<SeatPlanScreen> createState() => _SeatPlanScreenState();
}

class _SeatPlanScreenState extends State<SeatPlanScreen> {
  final FirestoreService _fs = FirestoreService();

  List<Student> _students = [];
  List<Room> _rooms = [];
  List<Exam> _exams = [];

  String? selectedExamId;
  bool generating = false;

  @override
  void initState() {
    super.initState();
    _fs.studentsStream().listen((s) => setState(() => _students = s));
    _fs.roomsStream().listen((r) => setState(() => _rooms = r));
    _fs.examsStream().listen((e) => setState(() => _exams = e));
  }

  Future<void> _generateSeatPlan() async {
    if (selectedExamId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select an exam first')));
      return;
    }

    if (_students.isEmpty || _rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add students and rooms first')));
      return;
    }

    setState(() => generating = true);

    try {
      await _fs.clearSeatPlanForExam(selectedExamId!);

      // 🔹 Load the selected exam
      final selectedExam =
      _exams.firstWhere((e) => e.id == selectedExamId!, orElse: () => Exam(id: '', courseName: '', date: DateTime.now(), department: ''));

      // 🔹 Separate students by course (same course = same branch)
      final sameCourseStudents = _students
          .where((s) => s.department.toLowerCase() ==
          selectedExam.department.toLowerCase())
          .toList();

      final otherCourseStudents = _students
          .where((s) => s.department.toLowerCase() !=
          selectedExam.department.toLowerCase())
          .toList();

      // 🔹 Shuffle to randomize a bit
      sameCourseStudents.shuffle();
      otherCourseStudents.shuffle();

      // 🔹 Assign seat numbers by "branch" (right/left)
      int seatCounter = 0;
      final rooms = List<Room>.from(_rooms);

      for (final room in rooms) {
        int cap = room.capacity;
        // Divide capacity into two halves
        int half = (cap / 2).floor();

        // 🔹 Fill left side = sameCourseStudents
        for (int i = 0; i < half && sameCourseStudents.isNotEmpty; i++) {
          final stu = sameCourseStudents.removeAt(0);
          seatCounter++;
          final item = SeatPlanItem(
            id: '',
            examId: selectedExamId!,
            studentId: stu.id,
            studentName: stu.name,
            roomNo: room.roomNo,
            seatNo: seatCounter,
          );
          await _fs.addSeatPlanItem(item);
        }

        // 🔹 Fill right side = otherCourseStudents
        for (int i = 0; i < half && otherCourseStudents.isNotEmpty; i++) {
          final stu = otherCourseStudents.removeAt(0);
          seatCounter++;
          final item = SeatPlanItem(
            id: '',
            examId: selectedExamId!,
            studentId: stu.id,
            studentName: stu.name,
            roomNo: room.roomNo,
            seatNo: seatCounter,
          );
          await _fs.addSeatPlanItem(item);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Smart seat plan generated')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seat Plan')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedExamId,
                hint: const Text('Select exam'),
                items: _exams
                    .map((e) =>
                    DropdownMenuItem(value: e.id, child: Text(e.courseName)))
                    .toList(),
                onChanged: (v) => setState(() => selectedExamId = v),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: generating ? null : _generateSeatPlan,
              child: generating
                  ? const CircularProgressIndicator()
                  : const Text('Generate'),
            ),
          ]),
          const SizedBox(height: 12),
          if (selectedExamId != null)
            Expanded(
              child: StreamBuilder<List<SeatPlanItem>>(
                stream: _fs.seatPlanStream(selectedExamId!),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final plan = snap.data!;
                  if (plan.isEmpty) {
                    return const Center(child: Text('No seat plan yet'));
                  }

                  // Group by room
                  final byRoom = <String, List<SeatPlanItem>>{};
                  for (final p in plan) {
                    byRoom.putIfAbsent(p.roomNo, () => []).add(p);
                  }

                  return ListView(
                    children: byRoom.entries.map((e) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ExpansionTile(
                          title: Text('Room ${e.key} (${e.value.length} seats)'),
                          children: e.value
                              .map((item) => ListTile(
                            title: Text(item.studentName),
                            subtitle: Text('Seat ${item.seatNo}'),
                          ))
                              .toList(),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ]),
      ),
    );
  }
}

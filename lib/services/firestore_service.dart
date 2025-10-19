import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/room_model.dart';
import '../models/exam_model.dart';
import '../models/seat_plan_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Students
  Stream<List<Student>> studentsStream() {
    return _db.collection('students').orderBy('name').snapshots().map(
          (snap) => snap.docs.map((d) => Student.fromMap(d.data(), d.id)).toList(),
    );
  }

  Future<void> addStudent(Student s) => _db.collection('students').add(s.toMap());
  Future<void> updateStudent(Student s) => _db.collection('students').doc(s.id).update(s.toMap());
  Future<void> deleteStudent(String id) => _db.collection('students').doc(id).delete();

  // Rooms
  Stream<List<Room>> roomsStream() {
    return _db.collection('rooms').orderBy('roomNo').snapshots().map(
          (snap) => snap.docs.map((d) => Room.fromMap(d.data(), d.id)).toList(),
    );
  }

  Future<void> addRoom(Room r) => _db.collection('rooms').add(r.toMap());
  Future<void> updateRoom(Room r) => _db.collection('rooms').doc(r.id).update(r.toMap());
  Future<void> deleteRoom(String id) => _db.collection('rooms').doc(id).delete();

  // Exams
  Stream<List<Exam>> examsStream() {
    return _db.collection('exams').orderBy('date', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => Exam.fromMap(d.data(), d.id)).toList(),
    );
  }

  Future<void> addExam(Exam e) => _db.collection('exams').add(e.toMap());
  Future<void> updateExam(Exam e) => _db.collection('exams').doc(e.id).update(e.toMap());
  Future<void> deleteExam(String id) => _db.collection('exams').doc(id).delete();

  // Seat plans
  Stream<List<SeatPlanItem>> seatPlanStream(String examId) {
    return _db
        .collection('seat_plans')
        .where('exam_id', isEqualTo: examId)
        .orderBy('room_no')
        .orderBy('seat_no')
        .snapshots()
        .map((snap) => snap.docs.map((d) => SeatPlanItem.fromMap(d.data(), d.id)).toList());
  }

  Future<void> clearSeatPlanForExam(String examId) async {
    final snap = await _db.collection('seat_plans').where('exam_id', isEqualTo: examId).get();
    final batch = _db.batch();
    for (final doc in snap.docs) batch.delete(doc.reference);
    await batch.commit();
  }

  Future<void> addSeatPlanItem(SeatPlanItem item) => _db.collection('seat_plans').add(item.toMap());
}

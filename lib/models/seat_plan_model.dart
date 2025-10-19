class SeatPlanItem {
  final String id;
  final String examId;
  final String studentId;
  final String studentName;
  final String roomNo;
  final int seatNo;

  SeatPlanItem({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.roomNo,
    required this.seatNo,
  });

  Map<String, dynamic> toMap() => {
    'exam_id': examId,
    'student_id': studentId,
    'student_name': studentName,
    'room_no': roomNo,
    'seat_no': seatNo,
  };

  factory SeatPlanItem.fromMap(Map<String, dynamic> data, String id) => SeatPlanItem(
    id: id,
    examId: data['exam_id'] ?? '',
    studentId: data['student_id'] ?? '',
    studentName: data['student_name'] ?? '',
    roomNo: data['room_no'] ?? '',
    seatNo: (data['seat_no'] ?? 0) is int ? data['seat_no'] : int.tryParse('${data['seat_no']}') ?? 0,
  );
}

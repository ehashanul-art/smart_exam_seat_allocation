class Exam {
  final String id;
  final String courseName;
  final DateTime date;
  final String department;
  Exam({required this.id, required this.courseName, required this.date, required this.department});
  Map<String, dynamic> toMap() => {
    'courseName': courseName,
    'date': date.toIso8601String(),
    'department': department,
  };
  factory Exam.fromMap(Map<String, dynamic> data, String id) => Exam(
    id: id,
    courseName: data['courseName'] ?? '',
    date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
    department: data['department'] ?? '',
  );
}

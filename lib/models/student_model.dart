class Student {
  final String id;
  final String name;
  final String department;
  final String roll;
  Student({required this.id, required this.name, required this.department, required this.roll});

  Map<String, dynamic> toMap() => {
    'name': name,
    'department': department,
    'roll': roll,
  };

  factory Student.fromMap(Map<String, dynamic> data, String id) => Student(
    id: id,
    name: data['name'] ?? '',
    department: data['department'] ?? '',
    roll: data['roll'] ?? '',
  );
}

class Room {
  final String id;
  final String roomNo;
  final int capacity;
  Room({required this.id, required this.roomNo, required this.capacity});
  Map<String, dynamic> toMap() => {
    'roomNo': roomNo,
    'capacity': capacity,
  };
  factory Room.fromMap(Map<String, dynamic> data, String id) => Room(
    id: id,
    roomNo: data['roomNo'] ?? '',
    capacity: (data['capacity'] ?? 0) is int ? data['capacity'] : int.tryParse('${data['capacity']}') ?? 0,
  );
}

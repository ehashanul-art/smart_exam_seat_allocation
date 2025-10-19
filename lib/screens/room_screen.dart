import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/room_model.dart';
class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}
class _RoomScreenState extends State<RoomScreen> {
  final FirestoreService _fs = FirestoreService();
  final roomNo = TextEditingController();
  final capacity = TextEditingController();
  void _addRoom() {
    final rNo = roomNo.text.trim();
    final cap = int.tryParse(capacity.text.trim()) ?? 0;
    if (rNo.isEmpty || cap <= 0) return;
    final r = Room(id: '', roomNo: rNo, capacity: cap);
    _fs.addRoom(r);
    roomNo.clear();
    capacity.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            TextField(controller: roomNo, decoration: const InputDecoration(labelText: 'Room No', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: capacity, decoration: const InputDecoration(labelText: 'Capacity', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _addRoom, child: const Text('Add Room')),
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<Room>>(
            stream: _fs.roomsStream(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final rooms = snap.data!;
              if (rooms.isEmpty) return const Center(child: Text('No rooms yet'));
              return ListView.separated(
                itemCount: rooms.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, i) {
                  final r = rooms[i];
                  return ListTile(
                    title: Text(r.roomNo),
                    subtitle: Text('Capacity: ${r.capacity}'),
                    trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _fs.deleteRoom(r.id)),
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

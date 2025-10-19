import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'student_screen.dart';
import 'room_screen.dart';
import 'exam_screen.dart';
import 'seat_plan_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [IconButton(onPressed: () => auth.signOut(), icon: const Icon(Icons.logout))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _tile(context, 'Students', Icons.people, const StudentScreen()),
            _tile(context, 'Rooms', Icons.meeting_room, const RoomScreen()),
            _tile(context, 'Exams', Icons.event_note, const ExamScreen()),
            _tile(context, 'Seat Plan', Icons.event_seat, const SeatPlanScreen()),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext ctx, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => screen)),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 48),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

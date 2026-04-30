import 'package:flutter/material.dart';
import '../theme.dart';
import 'exam_list_screen.dart';
import 'hall_list_screen.dart';
import 'Login.dart';
import 'generate_seat_plan.dart';
import 'student_list.dart';
import 'seat_plan_list_screen.dart';
class TeacherDashboard extends StatelessWidget {
  static const String routeName = '/teacher';
  const TeacherDashboard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView(children: [
          const Text('Teacher Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ActionCard(
            icon: Icons.list_alt,
            title: 'Manage Exams',
            onTap: () => Navigator.pushNamed(context, ExamListScreen.routeName),
          ),
          const SizedBox(height: 10),
          ActionCard(
            icon: Icons.domain,
            title: 'Manage Halls',
            onTap: () => Navigator.pushNamed(context, HallListScreen.routeName),
          ),
          const SizedBox(height: 10),
          ActionCard(
            icon: Icons.upload_file,
            title: 'View Student List',
            onTap: () =>
                Navigator.pushNamed(context, StudentListScreen.routeName),
          ),
          const SizedBox(height: 10),
          ActionCard(
            icon: Icons.auto_fix_high,
            title: 'Generate Master Plan',
            onTap: () =>
                Navigator.pushNamed(context, GenerateSeatPlanScreen.routeName),
          ),
          const SizedBox(height: 10),
          ActionCard(
            icon: Icons.grid_view,
            title: 'View Generated Plans',
            onTap: () =>
                Navigator.pushNamed(context, SeatPlanListScreen.routeName),
          ),
        ]),
      ),
    );
  }
}

// Your ActionCard widget (unchanged)
class ActionCard extends StatelessWidget {
// ... (same as before)
// ...
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ActionCard(
      {Key? key,
        required this.icon,
        required this.title,
        required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6)
            ]),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(children: [
          Container(
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: AppTheme.primary)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ]),
      ),
    );
  }
}
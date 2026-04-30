import 'package:flutter/material.dart';
import '../theme.dart';
import 'add_teacher.dart';
import 'add_student.dart';
import 'AddCourseScreen.dart';
import 'all_teachers_screen.dart';
import 'Login.dart';
class MainAdminDashboard extends StatelessWidget {
  static const String routeName = '/main-admin';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView(
          children: [
            const Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ActionCard(
              icon: Icons.person_add_alt_1,
              title: 'Add Student',
              onTap: () {
                Navigator.pushNamed(context, AddStudentScreen.routeName);
              },
            ),
            const SizedBox(height: 10),
            ActionCard(
              icon: Icons.school_outlined,
              title: 'Add Teacher',
              onTap: () {
                Navigator.pushNamed(context, AddTeacherScreen.routeName);
              },
            ),
            const SizedBox(height: 10),
            ActionCard(
              icon: Icons.book_outlined,
              title: 'Add Course',
              onTap: () {
                Navigator.pushNamed(context, AddCourseScreen.routeName);
              },
            ),
            const SizedBox(height: 10),
            ActionCard(
              icon: Icons.people_alt_outlined,
              title: 'View All Teachers',
              onTap: () {
                Navigator.pushNamed(context, '/all-teachers');
              },
            ),
          ],
        ),
      ),
    );
  }
}
class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ActionCard(
      {required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ]),
      ),
    );
  }
}
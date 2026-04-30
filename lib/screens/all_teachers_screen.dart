import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
class AllTeachersScreen extends StatefulWidget {
  static const String routeName = '/all-teachers';
  @override
  _AllTeachersScreenState createState() => _AllTeachersScreenState();
}
class _AllTeachersScreenState extends State<AllTeachersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> _promoteToAdmin(String teacherId) async {
    try {
      final currentAdminQuery = await _firestore
          .collection('teachers')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      if (currentAdminQuery.docs.isNotEmpty) {
        final currentAdminId = currentAdminQuery.docs.first.id;
        if (currentAdminId != teacherId) {
          await _firestore
              .collection('teachers')
              .doc(currentAdminId)
              .update({'role': 'teacher'});
        }
      }
      await _firestore.collection('teachers').doc(teacherId).update({
        'role': 'admin',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher promoted to admin successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error promoting teacher: $e')),
      );
    }
  }
  Future<void> _demoteAdmin(String teacherId) async {
    try {
      await _firestore.collection('teachers').doc(teacherId).update({
        'role': 'teacher',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin demoted to teacher successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error demoting admin: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Teachers')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('teachers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final teachers = snapshot.data!.docs;
          if (teachers.isEmpty) {
            return const Center(child: Text('No teachers found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              final data = teacher.data() as Map<String, dynamic>? ?? {};
              final name = data['name'] ?? '';
              final email = data['gmail'] ?? '';
              final role = data['role'] ?? 'teacher';
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text('$email - Role: $role'),
                  trailing: role == 'admin'
                      ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _demoteAdmin(teacher.id),
                    child: const Text('Demote'),
                  )
                      : ElevatedButton(
                    onPressed: () => _promoteToAdmin(teacher.id),
                    child: const Text('Make Admin'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
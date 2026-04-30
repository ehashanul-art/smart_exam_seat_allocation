import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
class StudentListScreen extends StatefulWidget {
  static const String routeName = '/students';
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}
class _StudentListScreenState extends State<StudentListScreen> {
  final teams = ['1-I', '1-II', '2-I', '2-II', '3-I', '3-II', '4-I', '4-II'];
  String selectedTeam = '1-I';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> _deleteStudent(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student?'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _firestore.collection('students').doc(docId).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting student: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student List')),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(children: [
          DropdownButtonFormField<String>(
            value: selectedTeam,
            items: teams.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
            onChanged: (v) => setState(() => selectedTeam = v!),
            decoration: const InputDecoration(
              hintText: 'Filter by Level-Team',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('students')
                  .where('level_team', isEqualTo: selectedTeam)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No students found for this team.'));
                }
                final students = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, idx) {
                    final s = students[idx];
                    final data = s.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'No Name';
                    final roll = data['roll'] ?? 'No Roll';
                    final team = data['level_team'] ?? 'No Team';
                    return Card(
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text('$roll • $team'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                          onPressed: () => _deleteStudent(s.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
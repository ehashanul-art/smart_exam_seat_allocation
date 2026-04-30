import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'create_exam.dart';
import '../theme.dart';
class ExamListScreen extends StatefulWidget {
  static const String routeName = '/exam-list';
  const ExamListScreen({Key? key}) : super(key: key);
  @override
  _ExamListScreenState createState() => _ExamListScreenState();
}
class _ExamListScreenState extends State<ExamListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Exams'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('exams').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No exams found. Create one!'));
          }
          final examDocs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(14.0),
            itemCount: examDocs.length,
            itemBuilder: (context, index) {
              final exam = examDocs[index];
              final data = exam.data() as Map<String, dynamic>;
              final courseName = data['course_name'] ?? 'No Course';
              final levelTeam = data['level_team'] ?? 'N/A';
              String examDate = 'No Date';
              if (data['timestamp'] != null) {
                final dt = (data['timestamp'] as Timestamp).toDate();
                examDate = DateFormat('yyyy-MM-dd – hh:mm a').format(dt);
              }
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$levelTeam\n$examDate'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.edit, color: AppTheme.primary),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateExamScreen(exam: exam),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateExamScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primary,
      ),
    );
  }
}
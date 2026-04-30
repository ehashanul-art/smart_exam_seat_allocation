import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_hall.dart';
import '../theme.dart';
class HallListScreen extends StatelessWidget {
  static const String routeName = '/hall-list';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  HallListScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Halls'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('halls').orderBy('hall_number').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No halls found. Add one!'));
          }
          final hallDocs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(14.0),
            itemCount: hallDocs.length,
            itemBuilder: (context, index) {
              final hall = hallDocs[index];
              final data = hall.data() as Map<String, dynamic>;
              final hallNumber = data['hall_number'] ?? 'No Number';
              final capacity = data['capacity']?.toString() ?? 'N/A';
              final layout = 'Rows: ${data['rows'] ?? 0}, Cols: ${data['cols'] ?? 0}, Per: ${data['branches'] ?? 0}';
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(hallNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Capacity: $capacity\n$layout'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.edit, color: AppTheme.primary),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddHallScreen(hall: hall),
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
              builder: (context) => const AddHallScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primary,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'seat_map_viewer.dart';
import '../theme.dart';
class SeatPlanListScreen extends StatefulWidget {
  static const String routeName = '/seat-plan-list';
  const SeatPlanListScreen({Key? key}) : super(key: key);
  @override
  _SeatPlanListScreenState createState() => _SeatPlanListScreenState();
}
class _SeatPlanListScreenState extends State<SeatPlanListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> _deletePlan(String planId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: const Text(
            'Are you sure you want to delete this seat plan? This action cannot be undone.'),
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
        await _firestore.collection('seatPlans').doc(planId).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seat plan deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting plan: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Seat Plans'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('seatPlans')
            .orderBy('generatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No seat plans generated yet.'));
          }
          final planDocs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(14.0),
            itemCount: planDocs.length,
            itemBuilder: (context, index) {
              final plan = planDocs[index];
              final data = plan.data() as Map<String, dynamic>;
              final planName = data['examName'] ?? 'Seat Plan';
              String generatedDate = 'Not specified';
              if (data['generatedAt'] != null) {
                final dt = (data['generatedAt'] as Timestamp).toDate();
                generatedDate = DateFormat('yyyy-MM-dd – hh:mm a').format(dt);
              }
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.grid_on, color: AppTheme.primary),
                  title: Text(planName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(generatedDate),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    onPressed: () => _deletePlan(plan.id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SeatMapViewerScreen(seatPlanId: plan.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
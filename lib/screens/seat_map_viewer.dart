import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../widgets/seat_grid.dart';
class SeatMapViewerScreen extends StatelessWidget {
  static const String routeName = '/seat-map';
  final String seatPlanId;
  const SeatMapViewerScreen({Key? key, required this.seatPlanId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seat Map Viewer')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('seatPlans')
            .doc(seatPlanId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Error: Seat plan not found.'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final examName = data['examName'] ?? 'Seat Plan';
          final generatedAt = data['generatedAt'] as Timestamp?;
          final seatMap = data['seatMap'] as Map<String, dynamic>;
          final hallNames = (data['halls'] as List<dynamic>).cast<String>();
          final hallLayouts = data['hallLayouts'] as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              Card(
                child: ListTile(
                  title: Text(examName),
                  subtitle: Text(
                    generatedAt != null
                        ? 'Generated: ${DateFormat.yMd().add_jm().format(generatedAt.toDate())}'
                        : 'Seat plan generated',
                  ),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: DefaultTabController(
                  length: hallNames.length,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        labelColor: AppTheme.primary,
                        unselectedLabelColor: Colors.grey,
                        tabs: hallNames
                            .map((name) => Tab(text: name))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TabBarView(
                          children: hallNames.map((hallName) {
                            final layout =
                            hallLayouts[hallName] as Map<String, dynamic>;
                            final int rows = layout['rows'] as int;
                            final int cols = layout['cols'] as int;
                            final int branches = layout['branches'] as int;
                            return SeatGrid(
                              hallName: hallName,
                              rows: rows,
                              columns: cols,
                              branches: branches,
                              seatMap: seatMap,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
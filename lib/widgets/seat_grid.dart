import 'package:flutter/material.dart';
class SeatGrid extends StatelessWidget {
  final String hallName;
  final int rows;
  final int columns;
  final int branches;
  final Map<String, dynamic> seatMap;
  const SeatGrid({
    Key? key,
    required this.hallName,
    required this.rows,
    required this.columns,
    required this.branches,
    required this.seatMap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 1.0 / (rows * 0.4),
      ),
      itemCount: columns,
      itemBuilder: (context, colIndex) {
        return Column(
          children: List.generate(rows, (rowIndex) {
            return Card(
              margin: const EdgeInsets.all(4.0),
              child: Container(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  children: List.generate(branches, (branchIndex) {
                    final seatId =
                        '$hallName-R${rowIndex + 1}-C${colIndex + 1}-B${branchIndex + 1}';
                    final seatData = seatMap[seatId];
                    return _SeatWidget(seatData: seatData, seatId: seatId);
                  }),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
class _SeatWidget extends StatelessWidget {
  final Map<String, dynamic>? seatData;
  final String seatId;
  const _SeatWidget({Key? key, this.seatData, required this.seatId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color seatColor = Colors.grey.shade300;
    IconData seatIcon = Icons.event_seat;
    String seatLabel = "Empty";
    String seatSubLabel = seatId.split('-').skip(1).join('-');
    final data = seatData;
    if (data != null) {
      final state = data['state'];
      if (state == 'assigned') {
        seatColor = Colors.blue.shade100;
        seatIcon = Icons.person;
        seatLabel = data['roll'] ?? 'Assigned';
        seatSubLabel = data['level_team'] ?? '';
      } else if (state == 'reserved') {
        seatColor = Colors.orange.shade100;
        seatIcon = Icons.bookmark;
        seatLabel = "Reserved";
      }
    }
    return Expanded(
      child: Tooltip(
        message: '$seatLabel\n$seatSubLabel',
        child: Container(
          margin: const EdgeInsets.all(2.0),
          color: seatColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(seatIcon, size: 16),
              SizedBox(height: 2),
              Text(
                seatLabel,
                style: TextStyle(fontSize: 8),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
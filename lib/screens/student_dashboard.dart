import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import 'Login.dart';
import '../services/notification_service.dart';
class StudentDashboard extends StatefulWidget {
  static const String routeName = '/student-dashboard';
  final String studentRollId;
  const StudentDashboard({Key? key, required this.studentRollId})
      : super(key: key);
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}
class _StudentDashboardState extends State<StudentDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }
  Future<void> _initNotifications() async {
    await NotificationService().initNotifications(widget.studentRollId);
  }
  Future<Map<String, dynamic>> _findMySeatInfo() async {
    String studentName = "Student";
    String levelTeam = "";
    try {
      final studentQuery = await _firestore
          .collection('students')
          .where('roll', isEqualTo: widget.studentRollId)
          .limit(1)
          .get();
      if (studentQuery.docs.isNotEmpty) {
        final data = studentQuery.docs.first.data() as Map<String, dynamic>;
        studentName = data['name'] ?? 'Student';
        levelTeam = data['level_team'] ?? '';
      }
    } catch (e) {
    }
    final planQuery = await _firestore
        .collection('seatPlans')
        .orderBy('generatedAt', descending: true)
        .limit(1)
        .get();
    if (planQuery.docs.isEmpty) {
      throw Exception('Seat plan not generated yet.');
    }
    final seatPlan = planQuery.docs.first.data() as Map<String, dynamic>;
    final seatMap = seatPlan['seatMap'] as Map<String, dynamic>;
    String? foundSeatKey;
    for (final entry in seatMap.entries) {
      final seatData = entry.value as Map<String, dynamic>;
      if (seatData['roll'] == widget.studentRollId) {
        foundSeatKey = entry.key;
        break;
      }
    }
    if (foundSeatKey == null) {
      throw Exception('You have not been assigned a seat in this exam.');
    }
    final parts = foundSeatKey.split('-');
    final hallName = parts[0];
    final seatLocation = parts.sublist(1).join('-');
    final generatedAt = seatPlan['generatedAt'] as Timestamp?;
    String examTime = 'N/A';
    if(generatedAt != null) {
      examTime = DateFormat('yyyy-MM-dd – hh:mm a').format(generatedAt.toDate());
    }
    return {
      'studentName': studentName,
      'levelTeam': levelTeam,
      'examName': seatPlan['examName'] ?? 'Exam',
      'hallName': hallName,
      'seatLocation': seatLocation,
      'examTime': examTime,
    };
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _findMySeatInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Finding your seat...'),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'Could Not Find Seat',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll("Exception: ", ""),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(14.0),
              child: ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome,',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            data['studentName'],
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: AppTheme.primary),
                          ),
                          SizedBox(height: 8),
                          Text(
                              'Roll: ${widget.studentRollId} • Team: ${data['levelTeam']}'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your Upcoming Exam Seat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  Card(
                    color: AppTheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            data['examName'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data['examTime'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          Divider(color: Colors.white54, height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SeatInfoColumn(
                                title: 'Hall / Room',
                                value: data['hallName'],
                              ),
                              _SeatInfoColumn(
                                title: 'Your Seat',
                                value: data['seatLocation'],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }
}
class _SeatInfoColumn extends StatelessWidget {
  final String title;
  final String value;
  const _SeatInfoColumn({Key? key, required this.title, required this.value})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
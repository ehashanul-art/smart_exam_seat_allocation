import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import 'seat_map_viewer.dart';
class GenerateSeatPlanScreen extends StatefulWidget {
  static const String routeName = '/generate';
  @override
  _GenerateSeatPlanScreenState createState() => _GenerateSeatPlanScreenState();
}
class _GenerateSeatPlanScreenState extends State<GenerateSeatPlanScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = false;
  String? _selectedExamType;
  List<String> _selectedHallIds = [];
  Map<String, bool> _hallCheckboxes = {};
  final List<String> _allTeams = [
    '1-I', '1-II', '2-I', '2-II', '3-I', '3-II', '4-I', '4-II'
  ];
  Map<String, bool> _teamCheckboxes = {};
  @override
  void initState() {
    super.initState();
    _teamCheckboxes = {for (var team in _allTeams) team: false};
  }
  Future<void> _generatePlan() async {
    final List<String> teamsToSeat = _teamCheckboxes.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();
    if (_selectedExamType == null) {
      _showError('Please select an exam type (Mid/Final).');
      return;
    }
    if (teamsToSeat.isEmpty) {
      _showError('Please select at least one level-team.');
      return;
    }
    if (_selectedHallIds.isEmpty) {
      _showError('Please select at least one hall.');
      return;
    }
    setState(() => _loading = true);
    try {
      QuerySnapshot examSnapshot = await _firestore
          .collection('exams')
          .where('exam_type', isEqualTo: _selectedExamType)
          .where('level_team', whereIn: teamsToSeat)
          .get();
      if (examSnapshot.docs.length != teamsToSeat.length) {
        _showError(
            'Error: Could not find a "$_selectedExamType" exam for every team selected.');
        setState(() => _loading = false);
        return;
      }
      final firstTimestamp = examSnapshot.docs.first['timestamp'];
      final bool allSameTime = examSnapshot.docs
          .every((doc) => doc['timestamp'] == firstTimestamp);
      if (!allSameTime) {
        _showError(
            'Error: These teams do not have an exam at the same date and time.');
        setState(() => _loading = false);
        return;
      }
      List<List<String>> teamPattern = [];
      for (int i = 0; i < teamsToSeat.length; i += 2) {
        if (i + 1 < teamsToSeat.length) {
          teamPattern.add([teamsToSeat[i], teamsToSeat[i + 1]]);
        } else {
          teamPattern.add([teamsToSeat[i], 'EMPTY']);
        }
      }
      if (teamPattern.isEmpty) {
        _showError('Could not create team pattern.');
        setState(() => _loading = false);
        return;
      }
      QuerySnapshot studentSnapshot = await _firestore
          .collection('students')
          .where('level_team', whereIn: teamsToSeat)
          .get();
      Map<String, List<DocumentSnapshot>> studentsByTeam = {};
      for (var team in teamsToSeat) {
        studentsByTeam[team.trim().toUpperCase()] = [];
      }
      for (var doc in studentSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final team = (data['level_team'] as String? ?? '').trim().toUpperCase();
        if (studentsByTeam.containsKey(team)) {
          studentsByTeam[team]!.add(doc);
        }
      }
      for (var teamKey in studentsByTeam.keys) {
        studentsByTeam[teamKey]?.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          return (aData['roll'] as String).compareTo(bData['roll'] as String);
        });
      }
      String newPlanId = _firestore.collection('seatPlans').doc().id;
      Map<String, dynamic> finalSeatMap = {};
      List<String> hallNames = [];
      Map<String, dynamic> hallLayouts = {};
      for (String hallId in _selectedHallIds) {
        DocumentSnapshot hallDoc =
        await _firestore.collection('halls').doc(hallId).get();
        final data = hallDoc.data() as Map<String, dynamic>;
        final hallName = data['hall_number'];
        final rows = data['rows'] as int;
        final cols = data['cols'] as int;
        final branches = data['branches'] as int;
        hallNames.add(hallName);
        hallLayouts[hallName] = {
          'rows': rows,
          'cols': cols,
          'branches': branches,
        };
        for (int c = 0; c < cols; c++) {
          for (int r = 0; r < rows; r++) {
            final pattern = teamPattern[r % teamPattern.length];
            for (int b = 0; b < branches; b++) {
              String seatId = '$hallName-R${r + 1}-C${c + 1}-B${b + 1}';
              if (b >= pattern.length) {
                finalSeatMap[seatId] = {'state': 'empty'};
                continue;
              }
              String teamToAssign = pattern[b].trim().toUpperCase();

              if (teamToAssign != 'EMPTY' &&
                  (studentsByTeam[teamToAssign]?.isNotEmpty ?? false)) {
                final student = studentsByTeam[teamToAssign]!.removeAt(0);
                final studentData = student.data() as Map<String, dynamic>;
                finalSeatMap[seatId] = {
                  'state': 'assigned',
                  'student_name': studentData['name'],
                  'roll': studentData['roll'],
                  'level_team': studentData['level_team'],
                };
              } else {
                finalSeatMap[seatId] = {'state': 'empty'};
              }
            }
          }
        }
      }
      final examName =
          examSnapshot.docs.first['course_name'] ?? 'Combined Exam';
      await _firestore.collection('seatPlans').doc(newPlanId).set({
        'planId': newPlanId,
        'examId': examSnapshot.docs.first.id,
        'examName': '$examName & others',
        'halls': hallNames,
        'hallLayouts': hallLayouts,
        'seatMap': finalSeatMap,
        'generatedAt': firstTimestamp,
      });
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatMapViewerScreen(seatPlanId: newPlanId),
        ),
      );
    } catch (e) {
      if (kDebugMode) print(e);
      _showError('Failed to generate plan: $e');
    } finally {
      setState(() => _loading = false);
    }
  }
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Seat Plan')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: ListView(children: [
              Text('1. Select Exam Type',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(hintText: 'Select type (Mid/Final)'),
                value: _selectedExamType,
                items: ['Mid', 'Final']
                    .map((e) => DropdownMenuItem(child: Text(e), value: e))
                    .toList(),
                onChanged: (v) => setState(() => _selectedExamType = v),
              ),
              SizedBox(height: 16),
              Text('2. Select Level-Teams to include',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 3.5,
                children: _allTeams.map((team) {
                  return CheckboxListTile(
                    title: Text(team),
                    value: _teamCheckboxes[team] ?? false,
                    onChanged: (val) {
                      setState(() {
                        _teamCheckboxes[team] = val!;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text('3. Choose hall(s) to use',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('halls')
                    .orderBy('hall_number')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LinearProgressIndicator();
                  }
                  if (!snapshot.hasData) return Container();

                  for (var doc in snapshot.data!.docs) {
                    _hallCheckboxes.putIfAbsent(doc.id, () => false);
                  }
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final docData = doc.data() as Map<String, dynamic>;
                      return CheckboxListTile(
                        value: _hallCheckboxes[doc.id] ?? false,
                        title: Text(docData['hall_number'] ?? 'Unknown Hall'),
                        subtitle: Text('Capacity: ${docData['capacity'] ?? 0}'),
                        onChanged: (v) {
                          setState(() {
                            _hallCheckboxes[doc.id] = v!;
                            if (v!) {
                              _selectedHallIds.add(doc.id);
                            } else {
                              _selectedHallIds.remove(doc.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(children: [
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loading ? null : _generatePlan,
                      child: Text('Generate Seat Plan'),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating Plan...',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
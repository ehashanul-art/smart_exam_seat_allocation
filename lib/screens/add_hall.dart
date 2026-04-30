import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
class AddHallScreen extends StatefulWidget {
  static const String routeName = '/add-hall';
  final DocumentSnapshot? hall;
  const AddHallScreen({Key? key, this.hall}) : super(key: key);
  @override
  _AddHallScreenState createState() => _AddHallScreenState();
}
class _AddHallScreenState extends State<AddHallScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _hallNumberController;
  late TextEditingController _rowsController;
  late TextEditingController _colsController;
  late TextEditingController _branchesController;
  int _totalCapacity = 0;
  bool _isEditing = false;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _isEditing = widget.hall != null;
    final data = _isEditing ? widget.hall!.data() as Map<String, dynamic> : null;
    _hallNumberController = TextEditingController(text: data?['hall_number'] ?? '');
    _rowsController = TextEditingController(text: data?['rows']?.toString() ?? '8');
    _colsController = TextEditingController(text: data?['cols']?.toString() ?? '3');
    _branchesController = TextEditingController(text: data?['branches']?.toString() ?? '2');
    _updateCapacity();
    _rowsController.addListener(_updateCapacity);
    _colsController.addListener(_updateCapacity);
    _branchesController.addListener(_updateCapacity);
  }
  void _updateCapacity() {
    final rows = int.tryParse(_rowsController.text) ?? 0;
    final cols = int.tryParse(_colsController.text) ?? 0;
    final branches = int.tryParse(_branchesController.text) ?? 0;
    setState(() {
      _totalCapacity = rows * cols * branches;
    });
  }
  @override
  void dispose() {
    _hallNumberController.dispose();
    _rowsController.dispose();
    _colsController.dispose();
    _branchesController.dispose();
    super.dispose();
  }
  Future<void> _saveHall() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    final hallData = {
      'hall_number': _hallNumberController.text,
      'rows': int.tryParse(_rowsController.text) ?? 0,
      'cols': int.tryParse(_colsController.text) ?? 0,
      'branches': int.tryParse(_branchesController.text) ?? 0,
      'capacity': _totalCapacity,
    };
    try {
      if (_isEditing) {
        await _firestore.collection('halls').doc(widget.hall!.id).update(hallData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Hall updated successfully!')),
        );
      } else {
        await _firestore.collection('halls').add(hallData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Hall added successfully!')),
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving hall: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
  Future<void> _deleteHall() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hall?'),
        content: const Text('Are you sure you want to delete this hall?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _loading = true);
    try {
      await _firestore.collection('halls').doc(widget.hall!.id).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hall deleted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
    } finally {
      setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Hall' : 'Add Hall'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _loading ? null : _deleteHall,
            )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: _hallNumberController,
                      decoration: InputDecoration(hintText: 'Room Number'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter a room number' : null,
                    ),
                    SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _rowsController,
                          decoration: InputDecoration(hintText: 'Rows'),
                          keyboardType: TextInputType.number,
                          validator: (v) => (int.tryParse(v ?? '0') ?? 0) <= 0 ? 'Invalid' : null,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _colsController,
                          decoration: InputDecoration(hintText: 'Columns'),
                          keyboardType: TextInputType.number,
                          validator: (v) => (int.tryParse(v ?? '0') ?? 0) <= 0 ? 'Invalid' : null,
                        ),
                      ),
                    ]),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _branchesController,
                      decoration: InputDecoration(hintText: 'Students per bench'),
                      keyboardType: TextInputType.number,
                      validator: (v) => (int.tryParse(v ?? '0') ?? 0) <= 0 ? 'Invalid' : null,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Total Capacity: $_totalCapacity',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loading ? null : _saveHall,
                      child: Text(_isEditing ? 'Update Hall' : 'Add Hall'),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
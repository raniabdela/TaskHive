import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';

class CreateTaskPage extends StatefulWidget {
  final String projectId;
  final String projectName;

  const CreateTaskPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _selectedDate;
  String _priority = 'Medium';
  String _status = 'To Do';
  bool _isLoading = false;

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _statuses = ['To Do', 'In Progress', 'Done'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: TH.blush),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      await FirebaseFirestore.instance.collection('tasks').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'projectId': widget.projectId,
        'projectName': widget.projectName,
        'status': _status,
        'priority': _priority,
        'deadline': _selectedDate != null
            ? Timestamp.fromDate(_selectedDate!)
            : null,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save task: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TH.canvas,
      appBar: TH.appBar(context, title: 'Create Task'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: TH.blushGrad,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: TH.floatShadow,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.task_alt_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Task',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              fontFamily: 'Georgia',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.projectName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Task Title
              TextFormField(
                controller: _titleController,
                style: const TextStyle(
                    color: TH.ink, fontWeight: FontWeight.w600),
                decoration: TH.inputDecoration(
                  context,
                  label: 'Task Title',
                  icon: Icons.title_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(color: TH.ink),
                decoration: TH.inputDecoration(
                  context,
                  label: 'Description (Optional)',
                  icon: Icons.description_rounded,
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 18),

              // Deadline Picker
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: TH.surface1,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TH.ink4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          color: TH.blush, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deadline',
                              style: TextStyle(
                                  color: TH.ink3,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _selectedDate == null
                                  ? 'Tap to set a deadline'
                                  : DateFormat('MMM d, yyyy')
                                      .format(_selectedDate!),
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? TH.ink3
                                    : TH.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _selectedDate != null
                            ? Icons.check_circle_rounded
                            : Icons.chevron_right_rounded,
                        color: _selectedDate != null ? TH.green : TH.ink3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Priority & Status row
              Row(
                children: [
                  Expanded(
                    child: _StyledDropdown(
                      label: 'Priority',
                      value: _priority,
                      items: _priorities,
                      icon: Icons.flag_rounded,
                      onChanged: (val) {
                        if (val != null) setState(() => _priority = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _StyledDropdown(
                      label: 'Status',
                      value: _status,
                      items: _statuses,
                      icon: Icons.check_circle_outline_rounded,
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              TH.primaryButton(
                label: 'Save Task',
                onPressed: _saveTask,
                isLoading: _isLoading,
                icon: Icons.save_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  final String label, value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: TH.ink3, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: TH.blush, size: 20),
        filled: true,
        fillColor: TH.surface1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TH.ink4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TH.ink4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TH.blush, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: TH.ink3),
      dropdownColor: TH.white,
      style: const TextStyle(
          color: TH.ink, fontWeight: FontWeight.w700, fontSize: 14),
      items: items
          .map((item) =>
              DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

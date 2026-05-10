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
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: TH.blush)),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save task: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const softRose = Color(0xFFBF5A6E);
    const lightRoseGrad = LinearGradient(
      colors: [Color(0xFFD4758A), Color(0xFFBF5A6E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: TH.canvas,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: softRose,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'New Task',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(gradient: lightRoseGrad),
                  ),
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.task_alt_rounded,
                      color: Colors.white12,
                      size: 80,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: softRose, 
              child: Container(
                decoration: const BoxDecoration(
                  color: TH.canvas,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Task Details',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: TH.ink,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Project: ${widget.projectName}',
                                  style: const TextStyle(
                                    color: TH.ink3,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          color: TH.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Task Title',
                          labelStyle: const TextStyle(
                            fontFamily: 'Georgia',
                            color: TH.ink3,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Icon(
                            Icons.title_rounded,
                            color: softRose,
                          ),
                          filled: true,
                          fillColor: TH.surface1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: TH.ink4,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: TH.ink4,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: softRose,
                              width: 1.8,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      
                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          color: TH.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          alignLabelWithHint: true,
                          labelStyle: const TextStyle(
                            fontFamily: 'Georgia',
                            color: TH.ink3,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 60),
                            child: Icon(
                              Icons.description_rounded,
                              color: softRose,
                            ),
                          ),
                          filled: true,
                          fillColor: TH.surface1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: TH.ink4,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: TH.ink4,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: softRose,
                              width: 1.8,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      
                      GestureDetector(
                        onTap: _pickDeadline,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: TH.surface1,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: TH.ink4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_rounded,
                                color: softRose,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Deadline',
                                      style: TextStyle(
                                          fontFamily: 'Georgia',
                                          color: TH.ink3,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _selectedDate == null
                                          ? 'Tap to set a deadline'
                                          : DateFormat(
                                              'MMM d, yyyy',
                                            ).format(_selectedDate!),
                                      style: TextStyle(
                                        fontFamily: 'Georgia',
                                        color: _selectedDate == null
                                            ? TH.ink3
                                            : TH.ink,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _selectedDate != null
                                    ? Icons.check_circle_rounded
                                    : Icons.chevron_right_rounded,
                                color: _selectedDate != null
                                    ? TH.green
                                    : TH.ink3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

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
                                if (val != null)
                                  setState(() => _priority = val);
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
                      const SizedBox(height: 40),

                      SizedBox(
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: lightRoseGrad,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: softRose.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save_rounded, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save Task',
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
        labelStyle: const TextStyle(
          fontFamily: 'Georgia',
          color: TH.ink3,
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, color: TH.softRose, size: 20),
        filled: true,
        fillColor: TH.surface1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TH.ink4, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TH.ink4, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TH.softRose, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: TH.ink3),
      dropdownColor: TH.white,
      style: const TextStyle(
        fontFamily: 'Georgia',
        color: TH.ink,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

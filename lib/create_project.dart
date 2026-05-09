import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Logic: Persistence layer interaction adding a new project document linked to the current user
      await FirebaseFirestore.instance.collection('projects').add({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create project: $e')),
        );
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
      appBar: TH.appBar(context, title: 'Create Project'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 48),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: lightRoseGrad,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: softRose.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(Icons.folder_special_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Project',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fill in the details to get started.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const _SectionLabel(text: 'Project Details'),
              const SizedBox(height: 16),
              
              // Logic: Utilizing centralized TH input styling for visual consistency
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  color: TH.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                decoration: TH.inputDecoration(
                  context,
                  label: 'Project Name',
                  icon: Icons.folder_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  color: TH.ink,
                  fontSize: 14,
                ),
                decoration: TH.inputDecoration(
                  context,
                  label: 'Description (Optional)',
                  icon: Icons.description_rounded,
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 36),

              // Logic: Primary submission action with global loading state handling
              TH.primaryButton(
                label: 'Create Project',
                onPressed: _createProject,
                isLoading: _isLoading,
                icon: Icons.add_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFE08898),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: TH.ink2,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

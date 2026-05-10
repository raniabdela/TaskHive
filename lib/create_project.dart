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
      if (user == null) throw Exception('Auth required');

      // Map local input to Firestore document
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
          SnackBar(
            backgroundColor: TH.crimson,
            content: Text('Error creating project: $e'),
          ),
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: TH.softRose,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text('New Project', 
                style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(decoration: const BoxDecoration(gradient: TH.softRoseGrad)),
                  // Subtle decorative UI elements
                  Positioned(
                    top: -30,
                    right: -30,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.auto_awesome_motion_rounded, 
                      color: Colors.white12, size: 80),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: TH.softRose, 
              child: Container(
                decoration: const BoxDecoration(
                  color: TH.canvas,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Project Details',
                        style: TextStyle(fontFamily: 'Georgia', fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 28),
                      
                      TextFormField(
                        controller: _nameController,
                        decoration: TH.inputDecoration(context, label: 'Project Name', icon: Icons.folder_rounded),
                        validator: (val) => (val?.isEmpty ?? true) ? 'Project name is required' : null,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        decoration: TH.inputDecoration(
                          context, 
                          label: 'Description (Optional)', 
                          icon: Icons.description_rounded,
                          maxLines: 4
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      TH.primaryButton(
                        label: 'Create Project',
                        isLoading: _isLoading,
                        onPressed: _createProject,
                        icon: Icons.add_rounded,
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

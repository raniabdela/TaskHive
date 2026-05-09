import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';
import 'create_project.dart';
import 'project_detail.dart';

// Soft rose to keep colours lighter and consistent with create_project page
const _softRose = Color(0xFFBF5A6E);
const _lightRoseGrad = LinearGradient(
  colors: [Color(0xFFD4758A), Color(0xFFBF5A6E)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  Future<void> _confirmDelete(
      BuildContext context, String docId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TH.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Delete Project?',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
            color: TH.ink,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$name"? This action cannot be undone.',
          style: const TextStyle(color: TH.ink2, fontSize: 14, height: 1.5),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: TH.ink2,
              side: const BorderSide(color: TH.ink4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: TH.crimson,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: TH.canvas,
      appBar: AppBar(
        backgroundColor: TH.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 22,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'My ',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: TH.ink,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Projects',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: _softRose,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateProjectPage()),
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: _lightRoseGrad,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _softRose.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child:
              const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please login to view projects'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('projects')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _softRose));
                }
                if (snapshot.hasError) {
                  return _ErrorState(message: '${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const _EmptyState();
                }

                final projects = snapshot.data!.docs.toList();
                projects.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['createdAt'] as Timestamp?;
                  final bTime = bData['createdAt'] as Timestamp?;
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime);
                });

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Summary banner
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: _SummaryBanner(count: projects.length),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = projects[index];
                            final data =
                                doc.data() as Map<String, dynamic>;
                            return _ProjectCard(
                              index: index,
                              id: doc.id,
                              name: data['name'] ?? 'Untitled Project',
                              description: data['description'] ?? '',
                              createdAt:
                                  data['createdAt'] as Timestamp?,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProjectDetailPage(
                                    projectId: doc.id,
                                    projectName:
                                        data['name'] ?? 'Project',
                                  ),
                                ),
                              ),
                              onDelete: () => _confirmDelete(
                                  context,
                                  doc.id,
                                  data['name'] ?? 'this project'),
                            );
                          },
                          childCount: projects.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

// ─── Summary Banner ───────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: _lightRoseGrad,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _softRose.withValues(alpha: 0.35),
            blurRadius: 20,
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.folder_copy_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workspace',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count Active ${count == 1 ? 'Project' : 'Projects'}',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Project Card ─────────────────────────────────────────────────────────────

// Cycling accent colours for project cards
const _cardAccents = [
  Color(0xFFE08898), // soft rose
  Color(0xFF7B9ED9), // soft blue
  Color(0xFF7EC8A0), // soft green
  Color(0xFFD4A056), // soft amber
  Color(0xFF9D82C8), // soft purple
];

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.index,
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.onTap,
    required this.onDelete,
  });

  final int index;
  final String id, name, description;
  final Timestamp? createdAt;
  final VoidCallback onTap, onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = createdAt != null
        ? DateFormat('MMM d, yyyy').format(createdAt!.toDate())
        : 'Just now';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final accent = _cardAccents[index % _cardAccents.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: BoxDecoration(
              color: TH.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: TH.ink4.withValues(alpha: 0.7)),
              boxShadow: TH.cardShadow,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Accent left bar
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(22),
                        bottomLeft: Radius.circular(22),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Initial circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                  color: accent.withValues(alpha: 0.25)),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: TH.ink,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: TH.ink3,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 12, color: accent),
                                    const SizedBox(width: 5),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            accent.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                            color: accent.withValues(
                                                alpha: 0.2)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 11, color: accent),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Open',
                                            style: TextStyle(
                                              color: accent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (val) {
                              if (val == 'delete') onDelete();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            icon: Icon(Icons.more_vert_rounded,
                                color: TH.ink3, size: 20),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded,
                                        color: TH.crimson, size: 18),
                                    SizedBox(width: 10),
                                    Text('Delete',
                                        style:
                                            TextStyle(color: TH.crimson)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: _lightRoseGrad,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _softRose.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.folder_open_rounded,
                  size: 42, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'No projects yet',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: TH.ink,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap the + button to create\nyour first project.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: TH.ink3, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 40, color: TH.crimson),
            const SizedBox(height: 12),
            const Text('Could not load projects',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: TH.ink, fontSize: 16)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: TH.ink3, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

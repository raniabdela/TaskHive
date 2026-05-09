import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';
import 'create_task.dart';
import 'task_detail_page.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['To Do', 'In Progress', 'Done'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TH.canvas,
      appBar: AppBar(
        backgroundColor: TH.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: TH.ink),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.projectName,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TH.ink,
                letterSpacing: -0.4,
              ),
            ),
            const Text(
              'Project Board',
              style: TextStyle(
                  fontSize: 12, color: TH.ink3, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: TH.surface1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TH.ink4),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: _statuses
                  .map((s) => Tab(
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ))
                  .toList(),
              indicator: BoxDecoration(
                gradient: TH.blushGrad,
                borderRadius: BorderRadius.circular(11),
                boxShadow: TH.floatShadow,
              ),
              indicatorPadding: const EdgeInsets.all(3),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: TH.ink2,
              dividerColor: Colors.transparent,
            ),
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateTaskPage(
              projectId: widget.projectId,
              projectName: widget.projectName,
            ),
          ),
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: TH.blushGrad,
            shape: BoxShape.circle,
            boxShadow: TH.floatShadow,
          ),
          child:
              const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statuses
            .map((status) => _TaskListView(
                  projectId: widget.projectId,
                  status: status,
                  onTap: (taskId, data) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailPage(
                        taskId: taskId,
                        taskData: data,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─── Task List per status ─────────────────────────────────────────────────────

class _TaskListView extends StatelessWidget {
  const _TaskListView({
    required this.projectId,
    required this.status,
    required this.onTap,
  });

  final String projectId, status;
  final void Function(String taskId, Map<String, dynamic> data) onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: TH.blush));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyColumn(status: status);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _TaskCard(
              taskId: doc.id,
              data: data,
              onTap: () => onTap(doc.id, data),
            );
          },
        );
      },
    );
  }
}

// ─── Task Card ────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.taskId,
    required this.data,
    required this.onTap,
  });

  final String taskId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Untitled Task';
    final priority = data['priority'] ?? 'Medium';

    DateTime? deadline;
    if (data['deadline'] is Timestamp) {
      deadline = (data['deadline'] as Timestamp).toDate();
    }
    final deadlineStr = deadline != null
        ? DateFormat('MMM d, yyyy').format(deadline)
        : null;

    final pColor = TH.priorityColor(priority);
    final pFaint = TH.priorityFaint(priority);
    final pBorder = TH.priorityBorder(priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: TH.cardDecoration(radius: 18),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TH.ink,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: pFaint,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: pBorder),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          color: pColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (deadlineStr != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          size: 13, color: TH.ink3),
                      const SizedBox(width: 5),
                      Text(
                        deadlineStr,
                        style: const TextStyle(
                            fontSize: 12, color: TH.ink3, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty Column ─────────────────────────────────────────────────────────────

class _EmptyColumn extends StatelessWidget {
  const _EmptyColumn({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (status == 'Done') {
      icon = Icons.check_circle_outline_rounded;
    } else if (status == 'In Progress') {
      icon = Icons.pending_outlined;
    } else {
      icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: TH.blushFaint,
              shape: BoxShape.circle,
              border: Border.all(color: TH.blushBorder),
            ),
            child: Icon(icon, size: 32, color: TH.blush),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks in "$status"',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: TH.ink,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to add a task.',
            style: TextStyle(color: TH.ink3, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
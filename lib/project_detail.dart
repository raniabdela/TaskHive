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
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: const Color(0xFFBF5A6E),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: Text(
                  widget.projectName,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFD4758A), Color(0xFFBF5A6E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
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
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: _statuses
                      .map((s) => Tab(
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ))
                      .toList(),
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(color: Color(0xFFBF5A6E), width: 3),
                    insets: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  labelColor: const Color(0xFFBF5A6E),
                  unselectedLabelColor: TH.ink3,
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  dividerColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(const Color(0xFFBF5A6E).withValues(alpha: 0.1)),
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: TH.canvas,
          child: TabBarView(
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
        ),
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
                        'Due Date: $deadlineStr',
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

// ─── Tab Bar Delegate ─────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height + 24;
  @override
  double get maxExtent => tabBar.preferredSize.height + 24;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFBF5A6E), // This ensures the background behind the rounded corners is pink
      child: Container(
        decoration: const BoxDecoration(
          color: TH.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        alignment: Alignment.center,
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

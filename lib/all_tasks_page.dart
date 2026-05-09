import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';
import 'task_detail_page.dart';

class AllTasksPage extends StatefulWidget {
  const AllTasksPage({super.key});

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text(
          'All Tasks',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: TH.ink,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: TH.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TH.ink4),
                    boxShadow: TH.cardShadow,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.toLowerCase()),
                    style:
                        const TextStyle(color: TH.ink, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: const TextStyle(color: TH.ink3),
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: TH.ink3),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: TH.ink3, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: false,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'To Do', 'In Progress', 'Done']
                        .map((status) {
                      final isSelected = _statusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _statusFilter = status),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected ? TH.blushGrad : null,
                              color: isSelected ? null : TH.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : TH.ink4,
                              ),
                              boxShadow:
                                  isSelected ? TH.floatShadow : null,
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : TH.ink2,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please login to view tasks'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: TH.blush),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allTasks = snapshot.data?.docs ?? [];

                // Local filter
                final filtered = allTasks.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title =
                      (data['title'] ?? '').toString().toLowerCase();
                  final status = data['status'] ?? 'To Do';
                  return title.contains(_searchQuery) &&
                      (_statusFilter == 'All' || status == _statusFilter);
                }).toList();

                // Sort: soonest deadline first, then newest
                filtered.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aD = aData['deadline'] as Timestamp?;
                  final bD = bData['deadline'] as Timestamp?;
                  if (aD != null && bD != null) return aD.compareTo(bD);
                  if (aD != null) return -1;
                  if (bD != null) return 1;
                  final aC = aData['createdAt'] as Timestamp?;
                  final bC = bData['createdAt'] as Timestamp?;
                  if (aC == null || bC == null) return 0;
                  return bC.compareTo(aC);
                });

                if (filtered.isEmpty) {
                  return _EmptyState(
                    isSearching: _searchQuery.isNotEmpty ||
                        _statusFilter != 'All',
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(18, 12, 18, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _TaskCard(
                      taskId: doc.id,
                      data: data,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailPage(
                            taskId: doc.id,
                            taskData: data,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
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
    final projectName = data['projectName'] ?? '';
    final status = data['status'] ?? 'To Do';
    final priority = data['priority'] ?? 'Medium';

    DateTime? deadline;
    if (data['deadline'] is Timestamp) {
      deadline = (data['deadline'] as Timestamp).toDate();
    }
    final deadlineStr = deadline != null
        ? DateFormat('MMM d, yyyy').format(deadline)
        : 'No deadline';

    final sColor = TH.statusColor(status);
    final sFaint = TH.statusFaint(status);
    final pColor = TH.priorityColor(priority);
    final pFaint = TH.priorityFaint(priority);
    final pBorder = TH.priorityBorder(priority);

    final isOverdue = deadline != null &&
        deadline.isBefore(DateTime.now()) &&
        status != 'Done';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: TH.cardDecoration(radius: 20),
            padding: const EdgeInsets.all(18),
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
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: TH.ink,
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: sFaint,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                            color: sColor.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: sColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Project
                    if (projectName.isNotEmpty) ...[
                      const Icon(Icons.folder_open_rounded,
                          size: 13, color: TH.blush),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          projectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: TH.blush,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],

                    // Deadline
                    Icon(
                      Icons.event_rounded,
                      size: 13,
                      color: isOverdue ? TH.crimson : TH.ink3,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deadlineStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? TH.crimson : TH.ink3,
                      ),
                    ),
                    const Spacer(),

                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: pFaint,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: pBorder),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          color: pColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching});
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TH.blushFaint,
              shape: BoxShape.circle,
              border: Border.all(color: TH.blushBorder),
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.task_alt_rounded,
              size: 36,
              color: TH.blush,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'No tasks match' : 'No tasks yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: TH.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search or filter.'
                : 'Create a task inside any project.',
            style: const TextStyle(fontSize: 14, color: TH.ink3),
          ),
        ],
      ),
    );
  }
}
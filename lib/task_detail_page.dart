import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;
  final Map<String, dynamic> taskData;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    required this.taskData,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late String _status;
  final _commentController = TextEditingController();
  bool _isSending = false;

  final List<String> _statuses = ['To Do', 'In Progress', 'Done'];

  @override
  void initState() {
    super.initState();
    _status = widget.taskData['status'] ?? 'To Do';
    if (!_statuses.contains(_status)) _status = 'To Do';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _status = newStatus);
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .update({'status': newStatus});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .collection('comments')
          .add({
        'text': text,
        'userId': user.uid,
        'userName': user.displayName ?? 'User',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.taskData['title'] ?? 'Untitled Task';
    final desc = widget.taskData['description'] ?? '';
    final priority = widget.taskData['priority'] ?? 'Medium';
    final projectName = widget.taskData['projectName'] ?? '';

    DateTime? deadline;
    if (widget.taskData['deadline'] is Timestamp) {
      deadline = (widget.taskData['deadline'] as Timestamp).toDate();
    }
    final deadlineText = deadline != null
        ? DateFormat('MMM d, yyyy').format(deadline)
        : 'No deadline';

    final pColor = TH.priorityColor(priority);
    final pFaint = TH.priorityFaint(priority);
    final pBorder = TH.priorityBorder(priority);
    final sColor = TH.statusColor(_status);
    final sFaint = TH.statusFaint(_status);

    return Scaffold(
      backgroundColor: TH.canvas,
      appBar: TH.appBar(context, title: 'Task Details'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                // Title + project badge
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: TH.ink,
                    letterSpacing: -0.6,
                    height: 1.2,
                  ),
                ),
                if (projectName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.folder_open_rounded,
                          size: 14, color: TH.blush),
                      const SizedBox(width: 6),
                      Text(
                        projectName,
                        style: const TextStyle(
                          color: TH.blush,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),

                // Status + Priority row
                Row(
                  children: [
                    // Status dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: sFaint,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: sColor.withValues(alpha: 0.25)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _status,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down_rounded,
                                color: sColor),
                            dropdownColor: TH.white,
                            style: TextStyle(
                              color: sColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            items: _statuses
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) _updateStatus(val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: pFaint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: pBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.flag_rounded, color: pColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            priority,
                            style: TextStyle(
                              color: pColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Deadline
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: TH.cardDecoration(radius: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: TH.blushFaint,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: TH.blushBorder),
                        ),
                        child: const Icon(Icons.event_rounded,
                            color: TH.blush, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deadline',
                            style: TextStyle(
                                fontSize: 11.5,
                                color: TH.ink3,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            deadlineText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: TH.ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                if (desc.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: TH.cardDecoration(radius: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: TH.ink3,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          desc,
                          style: const TextStyle(
                            color: TH.ink2,
                            fontSize: 14.5,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Comments header
                const Row(
                  children: [
                    SizedBox(width: 18, child: Divider(color: TH.blush, thickness: 1.5)),
                    SizedBox(width: 10),
                    Text(
                      'COMMENTS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: TH.ink2,
                        letterSpacing: 1.4,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: Divider(color: TH.ink4, thickness: 0.8)),
                  ],
                ),
                const SizedBox(height: 16),

                // Comments stream
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(widget.taskId)
                      .collection('comments')
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: TH.blush),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: TH.blushFaint,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: TH.blushBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded,
                                color: TH.blush, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'No comments yet. Be the first!',
                              style: TextStyle(color: TH.ink3, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cData = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        final text = cData['text'] ?? '';
                        final userName = cData['userName'] ?? 'User';
                        final time = cData['createdAt'] as Timestamp?;
                        final timeStr = time != null
                            ? DateFormat('MMM d, h:mm a')
                                .format(time.toDate())
                            : 'Just now';

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: TH.blushGrad,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  userName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: TH.cardDecoration(radius: 16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: TH.ink,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          timeStr,
                                          style: const TextStyle(
                                            color: TH.ink3,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      text,
                                      style: const TextStyle(
                                        color: TH.ink2,
                                        fontSize: 13.5,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Comment input bar
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: TH.white,
              border: Border(top: BorderSide(color: TH.ink4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3D1F26).withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: TH.ink, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle:
                          const TextStyle(color: TH.ink3, fontSize: 14),
                      filled: true,
                      fillColor: TH.surface1,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isSending ? null : _addComment,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: TH.blushGrad,
                      shape: BoxShape.circle,
                      boxShadow: TH.floatShadow,
                    ),
                    child: _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

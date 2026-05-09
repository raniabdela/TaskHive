import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'projects_page.dart';
import 'all_tasks_page.dart';
import 'profile_page.dart';
import 'task_detail_page.dart';



class _TH {
  // Canvas & surfaces
  static const canvas = Color(0xFFFDFBFA); // barely-warm white
  static const white = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF2EDEB); // secondary surface

  // Blush — used sparingly as THE brand signature
  static const blush = Color(0xFFCB6679); // mature rose, not candy
  static const blushFaint = Color(0xFFFAEFF1); // barely-there tint
  static const blushBorder = Color(0xFFEDD3D8);

  // Ink — warm charcoal family, zero blue-grey
  static const ink = Color(0xFF211418); // near-black warm
  static const ink2 = Color(0xFF5A3D44); // body text
  static const ink3 = Color(0xFF9A7E86); // muted / placeholder
  static const ink4 = Color(0xFFD8C8CB); // divider / border

  // Semantic — desaturated, professional
  static const green = Color(0xFF2E8B65);
  static const greenFaint = Color(0xFFE4F5EE);
  static const greenBorder = Color(0xFFB4DDD0);
  static const amber = Color(0xFF9B6E1A);
  static const amberFaint = Color(0xFFF9F0E0);
  static const amberBorder = Color(0xFFDFC89A);
  static const crimson = Color(0xFFB03040);
  static const crimsonFaint = Color(0xFFFBE9EC);
  static const crimsonBorder = Color(0xFFE5B0B8);

  // Gradients
  static const blushGrad = LinearGradient(
    colors: [Color(0xFFD97080), Color(0xFFCB6679)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const headerGrad = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF5F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows — deliberately warm-grey, not coloured
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF3D1F26).withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: const Color(0xFF3D1F26).withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> floatShadow = [
    BoxShadow(
      color: const Color(0xFFCB6679).withValues(alpha: 0.22),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> navShadow = [
    BoxShadow(
      color: const Color(0xFF3D1F26).withValues(alpha: 0.07),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];
}

// ─── Shell ────────────────────────────────────────────────────────────────────

class TaskHiveHomeShell extends StatefulWidget {
  const TaskHiveHomeShell({super.key});

  @override
  State<TaskHiveHomeShell> createState() => _TaskHiveHomeShellState();
}

class _TaskHiveHomeShellState extends State<TaskHiveHomeShell> {
  int _navIndex = 0;

  final List<Widget> _tabs = const [
    _DashboardTab(),
    _ProjectsTab(),
    _TasksTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _TH.canvas,
      body: SafeArea(
        child: IndexedStack(index: _navIndex, children: _tabs),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (idx) {
          if (idx == _navIndex) return;
          setState(() => _navIndex = idx);
        },
      ),
    );
  }
}

// ─── Tabs ─────────────────────────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab>
    with AutomaticKeepAliveClientMixin<_DashboardTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _TH.canvas,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _AppBarSliver(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _GreetingHeader(
                  displayName: user?.displayName,
                  fallbackEmail: user?.email,
                ),
                const SizedBox(height: 28),
                _StatsAndRecentSection(
                  userId: user?.uid,
                  onTaskTap: (task) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TaskDetailPage(
                          taskId: task.id,
                          taskData: task.rawData,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const _QuickTipCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsTab extends StatefulWidget {
  const _ProjectsTab();
  @override
  State<_ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<_ProjectsTab>
    with AutomaticKeepAliveClientMixin<_ProjectsTab> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const ProjectsPage();
  }
}

class _TasksTab extends StatefulWidget {
  const _TasksTab();
  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab>
    with AutomaticKeepAliveClientMixin<_TasksTab> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const AllTasksPage();
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();
  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab>
    with AutomaticKeepAliveClientMixin<_ProfileTab> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const ProfilePage();
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _AppBarSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _TH.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: false,
      floating: true,
      snap: true,
      toolbarHeight: 64,
      titleSpacing: 22,
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Task',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _TH.ink,
                letterSpacing: -0.6,
              ),
            ),
            TextSpan(
              text: 'Hive',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                color: _TH.blush,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
      ),
      actions: const [],
    );
  }
}

// ─── Greeting Header ──────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({
    required this.displayName,
    required this.fallbackEmail,
  });
  final String? displayName;
  final String? fallbackEmail;

  static String _weekday() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[DateTime.now().weekday - 1];
  }

  static String _shortDate() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final d = DateTime.now();
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final name = (displayName ?? '').trim().isNotEmpty
        ? displayName!
              .trim()
              .split(' ')
              .first // first name only, cleaner
        : 'there';

    return Container(
      decoration: BoxDecoration(
        gradient: _TH.headerGrad,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _TH.ink4.withValues(alpha: 0.7)),
        boxShadow: _TH.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date line — small, refined
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _TH.blush,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_weekday()}, ${_shortDate()}'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: _TH.ink3,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Greeting row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good to see you,',
                      style: TextStyle(
                        fontSize: 13,
                        color: _TH.ink3,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _TH.ink,
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar initials
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: _TH.blushGrad,
                  shape: BoxShape.circle,
                  boxShadow: _TH.floatShadow,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Subtle divider
          Container(height: 1, color: _TH.ink4.withValues(alpha: 0.5)),
          const SizedBox(height: 14),

          // Sub-caption
          const Text(
            'Here\'s an overview of your workspace today.',
            style: TextStyle(
              fontSize: 13,
              color: _TH.ink3,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats + Recent ───────────────────────────────────────────────────────────

class _StatsAndRecentSection extends StatelessWidget {
  const _StatsAndRecentSection({required this.userId, required this.onTaskTap});
  final String? userId;
  final void Function(TaskHiveTask) onTaskTap;

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return _EmptyStateCard(
        title: 'Not signed in',
        subtitle: 'Login to see your TaskHive dashboard.',
        icon: Icons.lock_outline_rounded,
        accent: _TH.blush,
        faint: _TH.blushFaint,
        border: _TH.blushBorder,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _TaskHiveQueries.tasksForUser(userId!).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _EmptyStateCard(
            title: 'Could not load tasks',
            subtitle: 'Please check your connection and try again.',
            icon: Icons.wifi_off_rounded,
            accent: _TH.crimson,
            faint: _TH.crimsonFaint,
            border: _TH.crimsonBorder,
          );
        }

        if (!snapshot.hasData) {
          return const Column(
            children: [
              _StatsSkeleton(),
              SizedBox(height: 14),
              _RecentTasksSkeleton(),
            ],
          );
        }

        final tasks = snapshot.data!.docs.map(TaskHiveTask.fromDoc).toList();
        final total = tasks.length;
        final completed = tasks.where((t) => t.isCompleted).length;
        final pending = (total - completed).clamp(0, total);
        final recent = tasks.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryCardsRow(
              total: total,
              completed: completed,
              pending: pending,
            ),
            const SizedBox(height: 28),
            _SectionLabel(text: 'Recent Tasks'),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              _EmptyStateCard(
                title: 'No tasks yet',
                subtitle: 'Create your first task to see it here.',
                icon: Icons.inbox_outlined,
                accent: _TH.blush,
                faint: _TH.blushFaint,
                border: _TH.blushBorder,
              )
            else
              for (final t in recent)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TaskCard(task: t, onTap: () => onTaskTap(t)),
                ),
          ],
        );
      },
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          child: Divider(color: _TH.blush, thickness: 1.5, endIndent: 0),
        ),
        const SizedBox(width: 10),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: _TH.ink2,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            color: _TH.ink4.withValues(alpha: 0.6),
            thickness: 0.8,
          ),
        ),
      ],
    );
  }
}

// ─── Summary Cards ────────────────────────────────────────────────────────────

class _SummaryCardsRow extends StatelessWidget {
  const _SummaryCardsRow({
    required this.total,
    required this.completed,
    required this.pending,
  });
  final int total, completed, pending;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total Tasks',
            value: '$total',
            icon: Icons.format_list_bulleted_rounded,
            accent: _TH.blush,
            faint: _TH.blushFaint,
            border: _TH.blushBorder,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Completed',
            value: '$completed',
            icon: Icons.check_rounded,
            accent: _TH.green,
            faint: _TH.greenFaint,
            border: _TH.greenBorder,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Pending',
            value: '$pending',
            icon: Icons.hourglass_empty_rounded,
            accent: _TH.amber,
            faint: _TH.amberFaint,
            border: _TH.amberBorder,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.faint,
    required this.border,
    this.isPrimary = false,
  });

  final String label, value;
  final IconData icon;
  final Color accent, faint, border;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? _TH.blushFaint : _TH.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPrimary ? _TH.blushBorder : _TH.ink4.withValues(alpha: 0.7),
          width: isPrimary ? 1.2 : 0.8,
        ),
        boxShadow: _TH.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isPrimary ? _TH.blush.withValues(alpha: 0.12) : faint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 16),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: isPrimary ? _TH.blush : _TH.ink,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _TH.ink3,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Task Card ────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onTap});
  final TaskHiveTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deadlineText = task.deadline == null
        ? 'No deadline'
        : MaterialLocalizations.of(context).formatMediumDate(task.deadline!);

    final Color accent, faint, border;
    final IconData icon;

    if (task.isCompleted) {
      accent = _TH.green;
      faint = _TH.greenFaint;
      border = _TH.greenBorder;
      icon = Icons.check_circle_outline_rounded;
    } else if (task.isOverdue) {
      accent = _TH.crimson;
      faint = _TH.crimsonFaint;
      border = _TH.crimsonBorder;
      icon = Icons.error_outline_rounded;
    } else {
      accent = _TH.blush;
      faint = _TH.blushFaint;
      border = _TH.blushBorder;
      icon = Icons.radio_button_unchecked_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _TH.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _TH.ink4.withValues(alpha: 0.7),
            width: 0.8,
          ),
          boxShadow: _TH.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent bar — 3px, full height
                Container(width: 3, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Status icon in subtle circle
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: faint,
                            shape: BoxShape.circle,
                            border: Border.all(color: border, width: 0.8),
                          ),
                          child: Icon(icon, color: accent, size: 17),
                        ),
                        const SizedBox(width: 14),
                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                task.title.isEmpty
                                    ? 'Untitled task'
                                    : task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _TH.ink,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _InlinePill(
                                    text: task.displayStatus,
                                    color: accent,
                                    bg: faint,
                                    borderColor: border,
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: _TH.ink3,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      deadlineText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: _TH.ink3,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: _TH.ink4,
                          size: 20,
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
    );
  }
}

// ─── Inline Pill ──────────────────────────────────────────────────────────────

class _InlinePill extends StatelessWidget {
  const _InlinePill({
    required this.text,
    required this.color,
    required this.bg,
    required this.borderColor,
  });
  final String text;
  final Color color, bg, borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─── Quick Tip Card ───────────────────────────────────────────────────────────

class _QuickTipCard extends StatelessWidget {
  const _QuickTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _TH.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _TH.ink4.withValues(alpha: 0.7), width: 0.8),
        boxShadow: _TH.cardShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Icon mark — small, elegant
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _TH.blushFaint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _TH.blushBorder, width: 0.8),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: _TH.blush,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro tip',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _TH.blush,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tap any task card to open its detail view and update the status.',
                  style: TextStyle(
                    fontSize: 13,
                    color: _TH.ink2,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
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

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (
      icon: Icons.dashboard_customize_outlined,
      active: Icons.dashboard_customize_rounded,
      label: 'Home',
    ),
    (
      icon: Icons.folder_outlined,
      active: Icons.folder_rounded,
      label: 'Projects',
    ),
    (
      icon: Icons.task_alt_outlined,
      active: Icons.task_alt_rounded,
      label: 'Tasks',
    ),
    (
      icon: Icons.person_outline_rounded,
      active: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _TH.white,
        border: Border(
          top: BorderSide(color: _TH.ink4.withValues(alpha: 0.6), width: 0.8),
        ),
        boxShadow: _TH.navShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final sel = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: 44,
                        height: 30,
                        decoration: BoxDecoration(
                          color: sel ? _TH.blushFaint : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: sel
                              ? Border.all(color: _TH.blushBorder, width: 0.8)
                              : null,
                        ),
                        child: Icon(
                          sel ? item.active : item.icon,
                          color: sel ? _TH.blush : _TH.ink3,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? _TH.blush : _TH.ink3,
                          letterSpacing: 0.1,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.faint,
    required this.border,
  });
  final String title, subtitle;
  final IconData icon;
  final Color accent, faint, border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _TH.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _TH.ink4.withValues(alpha: 0.7), width: 0.8),
        boxShadow: _TH.cardShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: faint,
              shape: BoxShape.circle,
              border: Border.all(color: border, width: 0.8),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _TH.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _TH.ink3,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
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

// ─── Skeletons ────────────────────────────────────────────────────────────────

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  Widget _shimBox(double w, double h, {double r = 8}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: _TH.surface2,
      borderRadius: BorderRadius.circular(r),
    ),
  );

  Widget _card() => Expanded(
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        color: _TH.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _TH.ink4.withValues(alpha: 0.6), width: 0.8),
        boxShadow: _TH.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimBox(34, 34, r: 999),
          const SizedBox(height: 14),
          _shimBox(36, 22, r: 6),
          const SizedBox(height: 7),
          _shimBox(58, 11, r: 5),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _card(),
        const SizedBox(width: 10),
        _card(),
        const SizedBox(width: 10),
        _card(),
      ],
    );
  }
}

class _RecentTasksSkeleton extends StatelessWidget {
  const _RecentTasksSkeleton();

  Widget _shimBox(double? w, double h, {double r = 8}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: _TH.surface2,
      borderRadius: BorderRadius.circular(r),
    ),
  );

  Widget _item() => Container(
    margin: const EdgeInsets.only(bottom: 10),
    height: 70,
    decoration: BoxDecoration(
      color: _TH.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _TH.ink4.withValues(alpha: 0.6), width: 0.8),
      boxShadow: _TH.cardShadow,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Container(width: 3, color: _TH.surface2),
          const SizedBox(width: 14),
          _shimBox(34, 34, r: 999),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimBox(null, 12, r: 5),
                const SizedBox(height: 8),
                _shimBox(100, 10, r: 5),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(children: [_item(), _item(), _item()]);
  }
}

// ─── Data model (logic unchanged) ─────────────────────────────────────────────

class TaskHiveTask {
  TaskHiveTask({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.deadline,
    required this.rawStatus,
    required this.rawData,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? deadline;
  final String? rawStatus;
  final Map<String, dynamic> rawData;

  bool get isOverdue =>
      !isCompleted && deadline != null && deadline!.isBefore(DateTime.now());

  String get displayStatus {
    if (isCompleted) return 'Completed';
    final s = (rawStatus ?? '').trim();
    if (s.isNotEmpty) return _titleCase(s);
    return 'Pending';
  }

  static TaskHiveTask fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final title =
        (data['title'] as String?) ??
        (data['name'] as String?) ??
        (data['taskTitle'] as String?) ??
        '';
    final statusStr = (data['status'] as String?) ?? (data['state'] as String?);
    final completedBool =
        (data['completed'] as bool?) ?? (data['isCompleted'] as bool?);
    final isCompleted =
        completedBool ??
        _normalizeStatus(statusStr) == _TaskHiveStatus.completed;

    DateTime? deadline;
    final d = data['deadline'] ?? data['dueDate'] ?? data['dueAt'];
    if (d is Timestamp) deadline = d.toDate();
    if (d is DateTime) deadline = d;
    if (d is String) deadline = DateTime.tryParse(d);

    return TaskHiveTask(
      id: doc.id,
      title: title,
      isCompleted: isCompleted,
      deadline: deadline,
      rawStatus: statusStr,
      rawData: data,
    );
  }
}

class _TaskHiveQueries {
  static Query<Map<String, dynamic>> tasksForUser(
    String userId, {
    int limit = 20,
  }) {
    // Tasks are stored in the root 'tasks' collection with a 'userId' field
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .limit(limit);
  }
}

enum _TaskHiveStatus { completed, pending, unknown }

_TaskHiveStatus _normalizeStatus(String? raw) {
  final s = (raw ?? '').trim().toLowerCase();
  if (s.isEmpty) return _TaskHiveStatus.unknown;
  if (s == 'done' || s == 'completed' || s == 'complete' || s == 'closed') {
    return _TaskHiveStatus.completed;
  }
  if (s == 'pending' ||
      s == 'open' ||
      s == 'to do' ||
      s == 'todo' ||
      s == 'in progress') {
    return _TaskHiveStatus.pending;
  }
  return _TaskHiveStatus.unknown;
}

String _titleCase(String input) {
  if (input.isEmpty) return input;
  return input
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .map(
        (p) => p.length == 1
            ? p.toUpperCase()
            : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}',
      )
      .join(' ');
}

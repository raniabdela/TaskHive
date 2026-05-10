import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';
import 'splashscreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);
    try {
      await user.updateDisplayName(_nameController.text.trim());
      await user.reload();
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TH.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
            color: TH.ink,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: TH.ink2, fontSize: 14, height: 1.6),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600)),
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
            child: const Text('Log Out',
                style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (_) => false,
    );
  }

  //Change Password
  //Re-authenticate and Update
  Future<void> _handlePasswordUpdate(
    String currentPassword,
    String newPassword,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {
      // This part is crucial: Firebase won't let you change password without a fresh login
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (mounted) {
        Navigator.pop(context); // Close the popup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  //The Popup Dialog
  void _showPasswordPopup() {
    final TextEditingController currentController = TextEditingController();
    final TextEditingController newController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Update Password',
          style: TextStyle(
            fontFamily: 'Georgia',
            color: TH.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPopupField(currentController, 'Current Password'),
              const SizedBox(height: 12),
              _buildPopupField(newController, 'New Password'),
              const SizedBox(height: 12),
              _buildPopupField(confirmController, 'Confirm New Password'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, color: TH.ink)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBF5A6E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // 1. Check if fields are empty
              if (currentController.text.isEmpty ||
                  newController.text.isEmpty) {
                print("Debug: Fields are empty");
                return;
              }

              // 2. Check if passwords match
              if (newController.text != confirmController.text) {
                print("Debug: Passwords do not match");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              // 3. Firebase requires 6+ characters
              if (newController.text.length < 6) {
                print("Debug: Password too short");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters'),
                  ),
                );
                return;
              }

              print(
                "Debug: All checks passed. Calling _handlePasswordUpdate...",
              );
              _handlePasswordUpdate(currentController.text, newController.text);
            },
            child: const Text('Update', style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  //Notifications
  Future<void> _showNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final in7Days = now.add(const Duration(days: 7));

    // Fetch tasks for current user from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: user.uid)
        .get();

    final overdue = <Map<String, dynamic>>[];
    final upcoming = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] ?? '';
      if (status == 'Done') continue;
      final deadline = data['deadline'];
      if (deadline is! Timestamp) continue;
      final date = deadline.toDate();
      if (date.isBefore(now)) {
        overdue.add({...data, 'id': doc.id});
      } else if (date.isBefore(in7Days)) {
        upcoming.add({...data, 'id': doc.id});
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _NotificationsSheet(overdue: overdue, upcoming: upcoming),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: TH.canvas,
        body: Center(child: Text('Please login to view your profile')),
      );
    }

    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : 'User';
    final initial = name[0].toUpperCase();
    final email = user.email ?? '';

    return Scaffold(
      backgroundColor: TH.canvas,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          //Curved Hero SliverAppBar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFFBF5A6E),
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD4758A), Color(0xFFBF5A6E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: -40,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: 30,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),

                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Avatar
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Color(0xFFF5D6DC)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: user.photoURL != null
                                    ? ClipOval(
                                        child: Image.network(
                                          user.photoURL!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          initial,
                                          style: const TextStyle(
                                            fontFamily: 'Georgia',
                                            fontSize: 38,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFBF5A6E),
                                          ),
                                        ),
                                      ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Photo upload coming soon!',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFBF5A6E),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14,
                                    color: Color(0xFFBF5A6E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                email,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
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
            // Pinned title when collapsed
            title: const Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Georgia',
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          // Body Content 
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //Quick Info Tiles
                  Row(
                    children: [
                      _QuickTile(
                        icon: Icons.verified_user_rounded,
                        label: 'Account',
                        value: 'Active',
                        color: TH.green,
                        faint: TH.greenFaint,
                        border: TH.greenBorder,
                      ),
                      const SizedBox(width: 12),
                      _QuickTile(
                        icon: Icons.shield_rounded,
                        label: 'Auth',
                        value: 'Email',
                        color: const Color(0xFFBF5A6E),
                        faint: TH.blushFaint,
                        border: TH.blushBorder,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  //Personal Info Card
                  _SectionHeader(
                    label: 'Personal Information',
                    trailing: GestureDetector(
                      onTap: () {
                        if (_isEditing) {
                          _updateProfile();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: _isEditing
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFD4758A),
                                    Color(0xFFBF5A6E),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _isEditing ? null : TH.blushFaint,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isEditing
                                ? Colors.transparent
                                : TH.blushBorder,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isEditing
                                        ? Icons.check_rounded
                                        : Icons.edit_rounded,
                                    size: 14,
                                    color: _isEditing
                                        ? Colors.white
                                        : const Color(0xFFBF5A6E),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _isEditing ? 'Save' : 'Edit',
                                    style: TextStyle(
                                      color: _isEditing
                                          ? Colors.white
                                          : const Color(0xFFBF5A6E),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: TH.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: TH.ink4.withValues(alpha: 0.7)),
                      boxShadow: TH.cardShadow,
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.person_rounded,
                          label: 'Full Name',
                          isFirst: true,
                          child: _isEditing
                              ? TextField(
                                  controller: _nameController,
                                  autofocus: true,
                                  style: const TextStyle(
                                    color: TH.ink,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: TH.surface1,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFBF5A6E),
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: TH.ink4,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFBF5A6E),
                                        width: 1.8,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: TH.ink,
                                  ),
                                ),
                        ),
                        Divider(
                          height: 1,
                          color: TH.ink4.withValues(alpha: 0.5),
                        ),
                        _InfoRow(
                          icon: Icons.email_rounded,
                          label: 'Email Address',
                          isFirst: false,
                          isLast: true,
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: TH.ink2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  //Account Actions
                  const _SectionHeader(label: 'Account'),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: TH.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: TH.ink4.withValues(alpha: 0.7)),
                      boxShadow: TH.cardShadow,
                    ),
                    child: Column(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('tasks')
                              .where('userId', isEqualTo: user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            int count = 0;
                            if (snapshot.hasData) {
                              final now = DateTime.now();
                              final in7Days = now.add(const Duration(days: 7));
                              for (var doc in snapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                final status = data['status'] ?? '';
                                if (status == 'Done') continue;
                                final deadline = data['deadline'];
                                if (deadline is! Timestamp) continue;
                                final date = deadline.toDate();
                                if (date.isBefore(in7Days)) {
                                  count++;
                                }
                              }
                            }
                            return _ActionRow(
                              icon: Icons.notifications_rounded,
                              label: 'Notifications',
                              isFirst: true,
                              color: const Color(0xFFBF5A6E),
                              faint: TH.blushFaint,
                              onTap: _showNotifications,
                              trailingWidget: count > 0
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: TH.blushFaint,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFBF5A6E)
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                          color: Color(0xFFBF5A6E),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          color: TH.ink4.withValues(alpha: 0.5),
                        ),
                        _ActionRow(
                          icon: Icons.lock_reset_rounded,
                          label: 'Change Password',
                          color: const Color(0xFFBF5A6E),
                          faint: TH.blushFaint,
                          onTap: _showPasswordPopup,
                        ),
                        Divider(
                          height: 1,
                          color: TH.ink4.withValues(alpha: 0.5),
                        ),
                        _ActionRow(
                          icon: Icons.logout_rounded,
                          label: 'Log Out',
                          isLast: true,
                          color: TH.crimson,
                          faint: TH.crimsonFaint,
                          showChevron: false,
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App version footer
                  const Center(
                    child: Text(
                      'TaskHive  •  v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: TH.ink3,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 

  
  Widget _buildPopupField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(
        fontFamily: 'Georgia',
        color: TH.ink,
        fontSize: 15,
        fontWeight: FontWeight.w400, 
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: TH.ink4, fontSize: 13),
        filled: true,
        fillColor: Color(0xFFF5F5F5), 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
} // This is the end of _ProfilePageState



class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.faint,
    required this.border,
  });
  final IconData icon;
  final String label, value;
  final Color color, faint, border;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: faint,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//Section Header

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.trailing});
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFBF5A6E),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label, 
          style: const TextStyle(
            fontFamily: 'Georgia', 
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: TH.ink, 
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}



class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
  });
  final IconData icon;
  final String label;
  final Widget child;
  final bool isFirst, isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, isFirst ? 20 : 16, 18, isLast ? 20 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: TH.blushFaint,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: TH.blushBorder),
            ),
            child: Icon(icon, color: const Color(0xFFBF5A6E), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: TH.ink3,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                // This ensures any text passed as 'child' (Name/Email)
                
                DefaultTextStyle(
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 15,
                    fontWeight: FontWeight.w400, 
                    color: TH.ink, 
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.faint,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.showChevron = true,
    this.trailingWidget,
  });
  final IconData icon;
  final String label;
  final Color color, faint;
  final VoidCallback onTap;
  final bool isFirst, isLast, showChevron;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: faint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TH.ink,
              ),
            ),
            const Spacer(),
            if (trailingWidget != null) ...[
              trailingWidget!,
              const SizedBox(width: 8),
            ],
            if (showChevron)
              Icon(Icons.chevron_right_rounded, color: TH.ink4, size: 20),
          ],
        ),
      ),
    );
  }
}



class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({required this.overdue, required this.upcoming});

  final List<Map<String, dynamic>> overdue;
  final List<Map<String, dynamic>> upcoming;

  @override
  Widget build(BuildContext context) {
    final hasAny = overdue.isNotEmpty || upcoming.isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: TH.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TH.ink4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4758A), Color(0xFFBF5A6E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: TH.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                if (hasAny)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: TH.blushFaint,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TH.blushBorder),
                    ),
                    child: Text(
                      '${overdue.length + upcoming.length}',
                      style: const TextStyle(
                        color: Color(0xFFBF5A6E),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: TH.ink4.withValues(alpha: 0.5)),
          Flexible(
            child: hasAny
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      if (overdue.isNotEmpty) ...[
                        _SheetLabel(
                          label: 'Overdue',
                          color: TH.crimson,
                          icon: Icons.warning_amber_rounded,
                        ),
                        const SizedBox(height: 10),
                        ...overdue.map(
                          (t) => _NotifCard(data: t, isOverdue: true),
                        ),
                        if (upcoming.isNotEmpty) const SizedBox(height: 18),
                      ],
                      if (upcoming.isNotEmpty) ...[
                        _SheetLabel(
                          label: 'Due This Week',
                          color: TH.amber,
                          icon: Icons.schedule_rounded,
                        ),
                        const SizedBox(height: 10),
                        ...upcoming.map(
                          (t) => _NotifCard(data: t, isOverdue: false),
                        ),
                      ],
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: TH.greenFaint,
                            shape: BoxShape.circle,
                            border: Border.all(color: TH.greenBorder),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 34,
                            color: TH.green,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "You're all caught up!",
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: TH.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No overdue or upcoming deadlines\nin the next 7 days.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TH.ink3,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel({
    required this.label,
    required this.color,
    required this.icon,
  });
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 7),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: color.withValues(alpha: 0.2))),
      ],
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.data, required this.isOverdue});
  final Map<String, dynamic> data;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Untitled Task';
    final projectName = data['projectName'] ?? '';
    final deadline = (data['deadline'] as Timestamp).toDate();
    final dateStr = DateFormat('EEE, MMM d').format(deadline);
    final color = isOverdue ? TH.crimson : TH.amber;
    final faint = isOverdue ? TH.crimsonFaint : TH.amberFaint;
    final border = isOverdue ? TH.crimsonBorder : TH.amberBorder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: faint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isOverdue
                    ? Icons.report_problem_rounded
                    : Icons.access_time_rounded,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: TH.ink,
                    ),
                  ),
                  if (projectName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TH.ink3,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border),
              ),
              child: Text(
                dateStr,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

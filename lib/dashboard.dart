import 'package:flutter/material.dart';

import 'auth_store.dart';
import 'splashscreen.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton(
            onPressed: () async {
              await AuthStore.setAuthenticated(false);
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (_) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to TaskHive',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

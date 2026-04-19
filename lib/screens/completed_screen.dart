import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import 'add_edit_screen.dart';
import 'home_screen.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = TaskControllerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Completed')),
      body: !ctrl.loaded
          ? const Center(child: CircularProgressIndicator())
          : ctrl.completed.isEmpty
              ? const _Empty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: ctrl.completed.length,
                  itemBuilder: (_, i) {
                    final t = ctrl.completed[i];
                    return TaskCard(
                      task: t,
                      onToggle: (_) => ctrl.toggleDone(t.id),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditScreen(task: t),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nothing finished yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Completed tasks will appear here.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

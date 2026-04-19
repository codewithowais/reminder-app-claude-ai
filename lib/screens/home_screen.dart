import 'package:flutter/material.dart';

import '../models/task.dart';
import '../state/task_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TaskController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TaskControllerScope.of(context, listen: false);
  }

  Future<void> _openEdit(Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditScreen(task: task)),
    );
  }

  Future<bool> _confirmDelete(Task task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.priorityHigh,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Tasks'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.eco_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          if (!_ctrl.loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = _ctrl.pending;
          if (tasks.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: tasks.length,
            itemBuilder: (_, i) {
              final t = tasks[i];
              return Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.priorityHigh,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Delete',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                confirmDismiss: (_) => _confirmDelete(t),
                onDismissed: (_) => _ctrl.remove(t.id),
                child: TaskCard(
                  task: t,
                  onTap: () => _openEdit(t),
                  onToggle: (_) => _ctrl.toggleDone(t.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.eco_rounded,
                  size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'A fresh, peaceful day.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap "Add Task" to plant your first todo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inherited access to the singleton controller.
class TaskControllerScope extends InheritedNotifier<TaskController> {
  const TaskControllerScope({
    super.key,
    required TaskController controller,
    required super.child,
  }) : super(notifier: controller);

  static TaskController of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<TaskControllerScope>()
        : context
            .getElementForInheritedWidgetOfExactType<TaskControllerScope>()
            ?.widget as TaskControllerScope?;
    assert(scope != null, 'TaskControllerScope not found in widget tree');
    return scope!.notifier!;
  }
}

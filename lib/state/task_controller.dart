import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_storage.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._storage);

  final TaskStorage _storage;
  final List<Task> _tasks = [];
  bool _loaded = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get loaded => _loaded;

  List<Task> get pending => _tasks.where((t) => !t.done).toList()
    ..sort(_sortByDateThenPriority);
  List<Task> get completed => _tasks.where((t) => t.done).toList()
    ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

  Future<void> load() async {
    final loaded = await _storage.loadTasks();
    _tasks
      ..clear()
      ..addAll(loaded);
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(Task task) async {
    _tasks.add(task);
    await _persist();
  }

  Future<void> update(Task task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) return;
    _tasks[i] = task;
    await _persist();
  }

  Future<void> remove(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _persist();
  }

  Future<void> toggleDone(String id) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _tasks[i] = _tasks[i].copyWith(done: !_tasks[i].done);
    await _persist();
  }

  Future<void> _persist() async {
    notifyListeners();
    await _storage.saveTasks(_tasks);
  }

  int _sortByDateThenPriority(Task a, Task b) {
    final d = a.dueDate.compareTo(b.dueDate);
    if (d != 0) return d;
    return b.priority.index.compareTo(a.priority.index);
  }
}

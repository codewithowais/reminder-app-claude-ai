import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class AddEditScreen extends StatefulWidget {
  const AddEditScreen({super.key, this.task});

  final Task? task;
  bool get isEdit => task != null;

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late DateTime _date;
  TimeOfDayData? _time;
  late Priority _priority;
  late bool _done;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _date = t?.dueDate ?? DateTime.now();
    _time = t?.dueTime;
    _priority = t?.priority ?? Priority.medium;
    _done = t?.done ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final initial = _time == null
        ? TimeOfDay.now()
        : TimeOfDay(hour: _time!.hour, minute: _time!.minute);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() =>
          _time = TimeOfDayData(hour: picked.hour, minute: picked.minute));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = TaskControllerScope.of(context, listen: false);
    final existing = widget.task;
    if (existing == null) {
      final task = Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        dueDate: _date,
        dueTime: _time,
        priority: _priority,
        done: _done,
      );
      ctrl.add(task);
    } else {
      ctrl.update(existing.copyWith(
        title: _titleCtrl.text.trim(),
        dueDate: _date,
        dueTime: _time,
        clearTime: _time == null,
        priority: _priority,
        done: _done,
      ));
    }
    Navigator.of(context).pop();
  }

  void _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.priorityHigh),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      TaskControllerScope.of(context, listen: false).remove(widget.task!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, MMM d, y').format(_date);
    final timeLabel = _time == null
        ? 'Add time (optional)'
        : DateFormat.jm()
            .format(DateTime(2024, 1, 1, _time!.hour, _time!.minute));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Task' : 'Add Task'),
        actions: [
          if (widget.isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.priorityHigh),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _Label('Title'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Buy groceries'),
              textInputAction: TextInputAction.done,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a title'
                  : null,
            ),
            const SizedBox(height: 18),
            const _Label('Due Date'),
            const SizedBox(height: 6),
            _PickerTile(
              icon: Icons.calendar_today_rounded,
              label: dateLabel,
              onTap: _pickDate,
            ),
            const SizedBox(height: 14),
            const _Label('Due Time'),
            const SizedBox(height: 6),
            _PickerTile(
              icon: Icons.access_time_rounded,
              label: timeLabel,
              onTap: _pickTime,
              trailing: _time == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted),
                      onPressed: () => setState(() => _time = null),
                    ),
            ),
            const SizedBox(height: 18),
            const _Label('Priority'),
            const SizedBox(height: 6),
            _PrioritySelector(
              value: _priority,
              onChanged: (p) => setState(() => _priority = p),
            ),
            const SizedBox(height: 18),
            Card(
              child: SwitchListTile.adaptive(
                value: _done,
                onChanged: (v) => setState(() => _done = v),
                title: const Text('Mark as done',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                activeThumbColor: AppColors.primary,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _save,
              child: Text(widget.isEdit ? 'Save Changes' : 'Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.4));
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0EBE3)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({required this.value, required this.onChanged});
  final Priority value;
  final ValueChanged<Priority> onChanged;

  Color _color(Priority p) => switch (p) {
        Priority.low => AppColors.priorityLow,
        Priority.medium => AppColors.priorityMedium,
        Priority.high => AppColors.priorityHigh,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values.map((p) {
        final selected = p == value;
        final color = _color(p);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.18) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? color : const Color(0xFFE0EBE3),
                    width: selected ? 1.6 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.flag_rounded, color: color),
                    const SizedBox(height: 4),
                    Text(
                      p.label,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

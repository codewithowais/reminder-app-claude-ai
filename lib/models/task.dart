import 'dart:convert';

enum Priority { low, medium, high }

extension PriorityX on Priority {
  String get label => switch (this) {
        Priority.low => 'Low',
        Priority.medium => 'Medium',
        Priority.high => 'High',
      };
}

class Task {
  final String id;
  String title;
  DateTime dueDate;
  TimeOfDayData? dueTime;
  Priority priority;
  bool done;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    this.dueTime,
    this.priority = Priority.medium,
    this.done = false,
  });

  Task copyWith({
    String? title,
    DateTime? dueDate,
    TimeOfDayData? dueTime,
    bool clearTime = false,
    Priority? priority,
    bool? done,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      dueTime: clearTime ? null : (dueTime ?? this.dueTime),
      priority: priority ?? this.priority,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dueDate': dueDate.toIso8601String(),
        'dueTime': dueTime?.toJson(),
        'priority': priority.name,
        'done': done,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        dueDate: DateTime.parse(json['dueDate'] as String),
        dueTime: json['dueTime'] == null
            ? null
            : TimeOfDayData.fromJson(
                Map<String, dynamic>.from(json['dueTime'] as Map)),
        priority: Priority.values.firstWhere(
          (p) => p.name == json['priority'],
          orElse: () => Priority.medium,
        ),
        done: json['done'] as bool? ?? false,
      );

  static String encodeList(List<Task> tasks) =>
      jsonEncode(tasks.map((t) => t.toJson()).toList());

  static List<Task> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

/// Storage-friendly time representation independent of BuildContext.
class TimeOfDayData {
  final int hour;
  final int minute;
  const TimeOfDayData({required this.hour, required this.minute});

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};
  factory TimeOfDayData.fromJson(Map<String, dynamic> json) =>
      TimeOfDayData(hour: json['hour'] as int, minute: json['minute'] as int);
}

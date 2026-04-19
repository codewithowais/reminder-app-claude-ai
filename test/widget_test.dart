import 'package:flutter_test/flutter_test.dart';

import 'package:reminderappbyclaude/services/task_storage.dart';
import 'package:reminderappbyclaude/state/task_controller.dart';
import 'package:reminderappbyclaude/main.dart';

void main() {
  testWidgets('App boots to splash screen', (tester) async {
    final controller = TaskController(TaskStorage());
    await tester.pumpWidget(RemindersApp(controller: controller));
    expect(find.text('Reminders'), findsOneWidget);
  });
}

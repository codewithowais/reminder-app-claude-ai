import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/task_storage.dart';
import 'state/task_controller.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = TaskController(TaskStorage())..load();
  runApp(RemindersApp(controller: controller));
}

class RemindersApp extends StatelessWidget {
  const RemindersApp({super.key, required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return TaskControllerScope(
      controller: controller,
      child: MaterialApp(
        title: 'Reminders',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}

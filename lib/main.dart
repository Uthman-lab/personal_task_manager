import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'presentation/pages/home_page.dart';
import 'core/services/background_task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background task manager
  await BackgroundTaskManager(workManager: Workmanager()).initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

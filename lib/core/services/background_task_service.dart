import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import '../../domain/model/task.dart';
import '../../data/datasources/hive_datasource.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(_handleBackgroundTask);
}

Future<bool> _handleBackgroundTask(
  String task,
  Map<String, dynamic>? inputData,
) async {
  try {
    final overdueTasks = await _getOverdueTasks();
    _logOverdueTasks(overdueTasks);
    return true;
  } catch (e) {
    debugPrint('Error in background task: $e');
    return false;
  }
}

Future<List<Task>> _getOverdueTasks() async {
  final dataSource = await HiveDataSourceImpl.create();
  final tasks = await dataSource.getTasks();
  return _filterOverdueTasks(tasks);
}

List<Task> _filterOverdueTasks(List<Task> tasks) {
  final now = DateTime.now();
  return tasks
      .where((task) => !task.isCompleted && task.dueDate.isBefore(now))
      .toList();
}

void _logOverdueTasks(List<Task> overdueTasks) {
  if (overdueTasks.isNotEmpty) {
    debugPrint('Overdue Tasks:');
    for (var task in overdueTasks) {
      debugPrint('Task: ${task.title}, Due Date: ${task.dueDate}');
    }
  } else {
    debugPrint('No overdue tasks found');
  }
}

class BackgroundTaskManager {
  final Workmanager _workManager;

  BackgroundTaskManager({required Workmanager workManager})
    : _workManager = workManager;

  Future<void> initialize() async {
    // Initialize WorkManager
    await _workManager.initialize(callbackDispatcher, isInDebugMode: true);

    // Schedule periodic task
    await _workManager.registerPeriodicTask(
      "taskCheck",
      "checkOverdueTasks",
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: true,
      ),
    );
  }
}

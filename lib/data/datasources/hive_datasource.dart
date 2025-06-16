import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/model/task.dart';

abstract class HiveDataSource {
  Future<void> addTask(Task task);
  Future<List<Task>> getTasks();
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
}

class HiveDataSourceImpl implements HiveDataSource {
  final Box _box;

  HiveDataSourceImpl._(this._box);

  static Future<HiveDataSourceImpl> create() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<Map>('tasks');
    return HiveDataSourceImpl._(box);
  }

  @override
  Future<void> addTask(Task task) async {
    await _box.add(task.toMap());
  }

  @override
  Future<List<Task>> getTasks() async {
    return _box.values
        .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _box.values.toList().indexWhere(
      (t) => t["title"] == task.title,
    );
    if (index != -1) {
      await _box.putAt(index, task.toMap());
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // Implementation for delete functionality
    final index = _box.values.toList().indexWhere(
      (t) => t["title"] == taskId, // Using title as ID for now
    );
    if (index != -1) {
      await _box.deleteAt(index);
    }
  }
}


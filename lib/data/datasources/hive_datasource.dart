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
    // Find the key for the task with the matching ID
    dynamic keyToUpdate;
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value != null && value["id"] == task.id) {
        keyToUpdate = key;
        break;
      }
    }
    
    if (keyToUpdate != null) {
      await _box.put(keyToUpdate, task.toMap());
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // Find the key for the task with the matching ID
    dynamic keyToDelete;
    for (var key in _box.keys) {
      final value = _box.get(key);
      if (value != null && value["id"] == taskId) {
        keyToDelete = key;
        break;
      }
    }
    
    if (keyToDelete != null) {
      await _box.delete(keyToDelete);
    }
  }
}


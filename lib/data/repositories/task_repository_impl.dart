import '../../domain/model/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/hive_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final HiveDataSource dataSource;

  TaskRepositoryImpl(this.dataSource);

  @override
  Future<void> addTask(Task task) async {
    await dataSource.addTask(task);
  }

  @override
  Future<List<Task>> getTasks() async {
    return await dataSource.getTasks();
  }

  @override
  Future<void> updateTask(Task task) async {
    await dataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await dataSource.deleteTask(taskId);
  }
}


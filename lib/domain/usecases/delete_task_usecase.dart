import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<void> call(String taskId) async {
    await repository.deleteTask(taskId);
  }
}


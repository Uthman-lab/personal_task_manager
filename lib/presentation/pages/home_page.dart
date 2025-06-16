import 'package:flutter/material.dart';
import '../../domain/model/task.dart';
import '../../data/datasources/hive_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../widgets/add_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GetTasksUseCase _getTasksUseCase;
  late AddTaskUseCase _addTaskUseCase;
  late UpdateTaskUseCase _updateTaskUseCase;
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUseCases();
  }

  Future<void> _initializeUseCases() async {
    final dataSource = await HiveDataSourceImpl.create();
    final repository = TaskRepositoryImpl(dataSource);

    _getTasksUseCase = GetTasksUseCase(repository);
    _addTaskUseCase = AddTaskUseCase(repository);
    _updateTaskUseCase = UpdateTaskUseCase(repository);

    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      tasks = await _getTasksUseCase();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Task Manager"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet. Add your first task!',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                    ),
                    trailing: _completionCheckBox(task),
                  ),
                );
              },
            ),
      floatingActionButton: AddButton(
        onAddTask: (task) async {
          await _addTaskUseCase(task);
          await _loadTasks();
        },
      ),
    );
  }

  Checkbox _completionCheckBox(Task task) {
    return Checkbox(
      value: task.isCompleted,
      onChanged: (val) async {
        task.isCompleted = val!;
        await _updateTaskUseCase(task);
        setState(() {});
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../domain/model/task.dart';
import '../../data/datasources/hive_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
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
  late DeleteTaskUseCase _deleteTaskUseCase;
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
    _deleteTaskUseCase = DeleteTaskUseCase(repository);
    
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
                return Dismissible(
                  key: Key(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteConfirmationDialog(context, task);
                  },
                  onDismissed: (direction) async {
                    await _deleteTask(task);
                  },
                  child: Card(
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

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, Task task) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await _deleteTaskUseCase(task.id);
      await _loadTasks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${task.title}" deleted successfully'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                // Re-add the task
                await _addTaskUseCase(task);
                await _loadTasks();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

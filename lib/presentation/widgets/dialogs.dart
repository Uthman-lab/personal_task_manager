import 'package:flutter/material.dart';
import '../../domain/model/task.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key, this.onAddTask});

  final Function(Task)? onAddTask;

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: "Enter Task title"),
              ),
              ElevatedButton(
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  final task = Task.create(
                    title: _controller.text,
                    dueDate: DateTime.now().add(const Duration(days: 1)),
                    isCompleted: false,
                  );
                  widget.onAddTask?.call(task);
                  Navigator.pop(context);
                }
              },
                child: Text("Add Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

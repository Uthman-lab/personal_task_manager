import 'package:flutter/material.dart';
import '../../domain/model/task.dart';
import 'dialogs.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key, this.onAddTask});
  final Function(Task)? onAddTask;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AddTaskDialog(onAddTask: onAddTask);
          },
        );
      },
    );
  }
}

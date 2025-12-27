import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/task_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  AddEditTaskScreen({this.task});
  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descController.text = widget.task!.description;
    }
  }

  void _saveTask() async {
    final title = titleController.text;
    final desc = descController.text;
    if (title.isEmpty || desc.isEmpty) return;
    if (widget.task == null) {
      await DatabaseHelper.instance.insertTask(
        Task(title: title, description: desc),
      );
    } else {
      await DatabaseHelper.instance.updateTask(
        Task(
          id: widget.task!.id,
          title: title,
          description: desc,
          isCompleted: widget.task!.isCompleted,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveTask, child: Text('Save Task')),
          ],
        ),
      ),
    );
  }
}

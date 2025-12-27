import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/task_model.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() async {
    tasks = await DatabaseHelper.instance.getTasks();
    setState(() {});
  }

  void _toggleComplete(Task task) async {
    task.isCompleted = task.isCompleted == 0 ? 1 : 0;
    await DatabaseHelper.instance.updateTask(task);
    _refreshTasks();
  }

  void _deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tasks Manager')),
      body: tasks.isEmpty
          ? Center(child: Text('No tasks yet'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted == 1
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(task.description),
                  leading: Checkbox(
                    value: task.isCompleted == 1,
                    onChanged: (_) => _toggleComplete(task),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditTaskScreen(task: task),
                            ),
                          );
                          _refreshTasks();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTask(task.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditTaskScreen()),
          );
          _refreshTasks();
        },
      ),
    );
  }
}

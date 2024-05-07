import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ToDoList(),
    );
  }
}

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _taskEditController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add task"),
          content: Form(
            key: _formKey,
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter task";
                } else {
                  return null;
                }
              },
              controller: _taskController,
              decoration: InputDecoration(
                  labelText: "Task",
                  suffixIcon: IconButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            tasks.add(_taskController.text);
                            _taskController.clear();
                            Navigator.pop(context);
                          });
                        }
                      },
                      icon: const Icon(Icons.check))),
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    _taskEditController.text = tasks[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit task"),
          actions: [
            TextField(
              controller: _taskEditController,
              decoration: InputDecoration(
                  labelText: "Task",
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          tasks[index] = _taskEditController.text;
                          _taskEditController.clear();
                          Navigator.pop(context);
                        });
                      },
                      icon: const Icon(Icons.check))),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "To Do List",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text("No tasks"),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: ((context, index) {
                        return ListTile(
                            leading: Text("${index + 1}"),
                            title: Text("${tasks[index]}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _showEditDialog(context, index);
                                      });
                                    },
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        tasks.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.delete))
                              ],
                            ));
                      })))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _showAddDialog(context);
            });
          },
          child: const Icon(Icons.add)),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_app/models/task_model.dart';
import 'package:to_do_app/services/utilities/app_url.dart';
import 'package:http/http.dart' as http;

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

List<TaskModel> tasksData = [];

class _ToDoListState extends State<ToDoList> {
  List tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _taskEditController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Future<List<TaskModel>> getApi() async {
    print('get api called');
    var response = await http.get(Uri.parse(AppUrl.postUrl));
    print('response body: ${response.body}');
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      print("json list: ${json}");
      for (dynamic map in json) {
        tasksData.add(TaskModel.fromJson(Map<String, dynamic>.from(map)));
      }
      print(tasksData[0].task);
      print('passed');
      return tasksData;
    } else {
      throw Exception("Error");
    }
  }

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
              decoration: const InputDecoration(labelText: "Task"),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final TaskModel? newTask =
                          await TaskModel.createTask(_taskController.text);
                      if (newTask != null) {
                        setState(() {
                          tasksData.add(newTask);
                        });
                        _taskController.clear();
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Failed to add task: $e"),
                      ));
                    }
                  }
                },
                child: const Center(
                  child: Text("Add"),
                ))
          ],
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
      body: FutureBuilder(
        future: getApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                    child: snapshot.data!.isEmpty
                        ? Center(child: Text("No tasks"))
                        : ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: ((context, index) {
                              return ListTile(
                                leading: Text("${index + 1}"),
                                title: Text(
                                    snapshot.data![index].task ?? 'no task'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _showEditDialog(context, index);
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          tasks.removeAt(index);
                                        });
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                  ),
                ],
              );
            } else {
              return Center(child: Text("No data available"));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddDialog(context);
          },
          child: const Icon(Icons.add)),
    );
  }
}

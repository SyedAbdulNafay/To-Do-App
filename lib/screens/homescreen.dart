import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_app/models/task_model.dart';
import 'package:to_do_app/services/tasks_services.dart';
import 'package:to_do_app/services/utilities/app_url.dart';
import 'package:http/http.dart' as http;

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List tasks = [];
  List<TaskModel> tasksData = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _taskEditController = TextEditingController();
  final _textKey = GlobalKey<FormState>();
  final _editKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Future<List<TaskModel>> getApi() async {
    var response = await http.get(Uri.parse(AppUrl.postUrl));
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      for (dynamic map in json) {
        tasksData.add(TaskModel.fromJson(Map<String, dynamic>.from(map)));
      }
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
            key: _textKey,
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
                  if (_textKey.currentState!.validate()) {
                    try {
                      await TaskServices.postTaskApi(_taskController.text);
                      tasksData.clear();
                      setState(() {});
                      Navigator.pop(context);
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
    _taskEditController.text = tasksData[index].task ?? "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit task"),
          content: Form(
            key: _editKey,
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter task";
                } else {
                  return null;
                }
              },
              controller: _taskEditController,
              decoration: const InputDecoration(labelText: "Task"),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  if (_editKey.currentState!.validate()) {
                    try {
                      Navigator.pop(context);
                      await TaskServices.updateTaskApi(
                          tasksData[index].id!, _taskEditController.text);
                      tasksData.clear();
                      setState(() {});
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Failed to update task: $e"),
                      ));
                    }
                  }
                },
                child: const Center(
                  child: Text("Update"),
                ))
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
                        ? const Center(child: Text("No tasks"))
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
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        TaskServices.deleteTaskApi(
                                            snapshot.data![index].id!);
                                        tasksData.clear();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.delete),
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
              return const Center(child: Text("No data available"));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _showAddDialog(context);
          },
          child: const Icon(Icons.add)),
    );
  }
}

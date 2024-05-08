import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:to_do_app/services/utilities/app_url.dart';

class TaskModel {
  String? id;
  String? task;

  TaskModel({this.task, this.id});

  TaskModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    task = json['task'];
  }

  static Future<TaskModel> createTask(String task) async {
    Map<String, dynamic> data = {"task": task};
    print("task created");
    var response = await http.post(Uri.parse(AppUrl.postUrl), body: jsonEncode(data));
    print('response code: ${response.statusCode}');
    if (response.statusCode == 201) {
      return TaskModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create task");
    }
  }
}

import 'dart:convert';

import 'package:to_do_app/services/utilities/app_url.dart';
import 'package:http/http.dart' as http;

class TaskServices {
  static Future postTaskApi(String task) async {
    var response = await http.post(Uri.parse(AppUrl.postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"task": task}));
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
  }

  static Future updateTaskApi(String id, String task) async {
    await http.put(Uri.parse("${AppUrl.postUrl}/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"task": task}));
  }

  static Future deleteTaskApi(String id) async {
    await http.delete(Uri.parse("${AppUrl.postUrl}/$id"));
  }
}

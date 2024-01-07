import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model_task.dart';

// https://pub.dev/packages/shared_preferences
// https://docs.flutter.dev/cookbook/persistence/key-value
class Data {
  static Future<void> save() async {
    List<String> sTodos = [];
    for (Task t in Task.todos) {
      sTodos.add(json.encode(t.toJson()));
    }
    List<String> sDone = [];
    for (Task t in Task.done) {
      sDone.add(json.encode(t.toJson()));
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setStringList('todos', sTodos);
    await preferences.setStringList('done', sDone);
    // https://stackoverflow.com/questions/73669989
    if (kDebugMode) {
      print('saved ${Task.todos.length} todos');
      print('saved ${Task.done.length} done');
    }
  }

  static Future<void> load() async {
    Task.todos.clear();
    Task.star.clear();
    Task.done.clear();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('todos')) {
      List<String> sTodos = preferences.getStringList('todos')!;
      for (String s in sTodos) {
        Task task = Task.fromJson(json.decode(s));
        Task.todos.add(task);
      }
    } else {
      await preferences.setStringList('todos', []);
    }
    if (preferences.containsKey('done')) {
      List<String> sDone = preferences.getStringList('done')!;
      for (String s in sDone) {
        Task.done.add(Task.fromJson(json.decode(s)));
      }
    } else {
      await preferences.setStringList('done', []);
    }
    if (kDebugMode) {
      print('loaded ${Task.todos.length} todos');
      print('loaded ${Task.done.length} done, ${Task.star.length} star');
    }
  }

  static Future<void> dummy() async {
    Task task2 = Task(title: 'Test 2', deadline: DateTime.now(), starred: true);
    Task.todos.insertAll(Task.todos.length, [Task(title: 'Test 1'), task2]);
    Task.done.insert(Task.done.length, Task(title: 'Test 3'));
    Task.sortAll();
    await save();
  }

  static Future<void> nuke() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await load();
  }
}

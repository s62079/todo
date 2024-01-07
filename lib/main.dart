import 'package:flutter/material.dart';

import 'data.dart';
import 'view_home.dart';

void main() async {
  // https: //stackoverflow.com/questions/65141485
  WidgetsFlutterBinding.ensureInitialized();
  await Data.load();
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do',
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

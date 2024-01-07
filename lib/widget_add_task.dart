import 'dart:math';

import 'package:flutter/material.dart';

import 'model_task.dart';
import 'view_edit_task.dart';
import 'widget_set_datetime.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddTaskViewState();
  }
}

class _AddTaskViewState extends State<AddTaskView> {
  final GlobalKey<FormFieldState> _key = GlobalKey();

  String title = '';
  DateTime? deadline;

  DateTime? getDeadline() => deadline;

  void setDeadline(DateTime? dateTime) {
    deadline = dateTime;
  }

  Task createTask() {
    return Task(
      title: title,
      deadline: deadline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);

    // https://stackoverflow.com/questions/53869078
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double keyboardPadding = max(mediaQuery.viewInsets.bottom - 24, 0);

    return Container(
      padding: EdgeInsets.only(bottom: keyboardPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Task'),
                autofocus: true,
                key: _key,
                validator: (value) => (value != null && value.isEmpty)
                    ? 'You have no task?'
                    : null,
                onSaved: (value) => title = value!,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                DateTimePickerView(getDeadline, setDeadline),
                IconButton(
                  onPressed: () {
                    if (_key.currentState!.validate()) {
                      _key.currentState!.save();
                      Task task = createTask();
                      navigator.pop(task);
                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => EditTaskPage(task: task),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.notes),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    if (_key.currentState!.validate()) {
                      _key.currentState!.save();
                      return navigator.pop(createTask());
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

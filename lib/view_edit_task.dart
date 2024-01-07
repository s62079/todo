import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'data.dart';
import 'model_task.dart';
import 'widget_set_datetime.dart';

class EditTaskPage extends StatefulWidget {
  final Function? refreshParent;
  final Task task;

  const EditTaskPage({
    super.key,
    required this.task,
    this.refreshParent,
  });

  @override
  State<StatefulWidget> createState() {
    return _EditTaskPageState();
  }
}

class _EditTaskPageState extends State<EditTaskPage> {
  final DateFormat df = DateFormat("yyyy/MM/dd HH:mm");
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  List<Widget> partDeadline = <Widget>[];

  Future<void> updateTodo() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      Task.sortTodos();
      if (widget.refreshParent != null) {
        widget.refreshParent!();
      }
      await Data.save();
    }
  }

  DateTime? getDeadline() => widget.task.deadline;

  void setDeadline(DateTime? date) {
    widget.task.deadline = date;
    updateTodo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NavigatorState navigator = Navigator.of(context);

    final Task task = widget.task;
    final DateTime? deadline = widget.task.deadline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => task.flipStar()),
            icon: Icon(
              Icons.star,
              color: (task.starred) ? Colors.yellow : null,
            ),
          ),
          IconButton(
              onPressed: () => navigator.pop('delete'),
              icon: const Icon(Icons.delete)),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            children: <Widget>[
              _FormSaveWrapper(
                onFocusChange: updateTodo,
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Task'),
                  initialValue: task.title,
                  validator: (value) => (value != null && value.isEmpty)
                      ? 'You have no task?'
                      : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onSaved: (value) => task.title = value!,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    DateTimePickerView(getDeadline, setDeadline),
                    const SizedBox(width: 8),
                    Text((deadline != null) ? df.format(deadline) : ''),
                  ],
                ),
              ),
              _FormSaveWrapper(
                  onFocusChange: updateTodo,
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Details'),
                    initialValue: task.details,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onSaved: (value) => task.details = value!,
                  ))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigator.pop('done'),
        child: const Icon(Icons.check),
      ),
    );
  }
}

// https://stackoverflow.com/questions/58522998
class _FormSaveWrapper extends StatelessWidget {
  final Future<void> Function() onFocusChange;
  final Widget child;

  const _FormSaveWrapper({required this.onFocusChange, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: FocusScope(
        onFocusChange: (value) async {
          if (!value) await onFocusChange();
        },
        child: child,
      ),
    );
  }
}

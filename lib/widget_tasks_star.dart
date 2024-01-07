import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:what_todo/utils.dart';

import 'data.dart';
import 'model_task.dart';
import 'view_edit_task.dart';

class StarTasksView extends StatefulWidget {
  const StarTasksView({super.key});

  @override
  State<StarTasksView> createState() {
    return StarTasksViewState();
  }
}

class StarTasksViewState extends State<StarTasksView> {
  final DateFormat df = DateFormat("yyyy/MM/dd HH:mm");

  List<Task> todos = Task.todos, done = Task.done, star = Task.star;

  void refresh() => setState(() {});

  void removeTask(Task task) async {
    setState(() => task.removeTodo());
    snackWithUndo(
      ScaffoldMessenger.of(context),
      'Task Removed',
      () => setState(() => task.addTodo(wasStarred: true)),
    );
    await Data.save();
  }

  void removeStar(Task task) {
    setState(() => task.flipStar());
    snackWithUndo(
      ScaffoldMessenger.of(context),
      'Removed from Starred',
      () => setState(() => task.flipStar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScaffoldMessengerState state = ScaffoldMessenger.of(context);
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    Color yellowTint = tintColor(Colors.yellow, backgroundColor, 5);

    return (Task.star.isEmpty)
        ? const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No starred tasks, '),
                Icon(Icons.star),
                Text(' task when editing.'),
              ],
            ),
          )
        : ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: star.length,
            itemBuilder: (BuildContext context, int i) {
              return InkWell(
                // edit existing task
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTaskPage(
                        refreshParent: refresh,
                        task: star[i],
                      ),
                    ),
                  ).then((value) {
                    if (value == 'done') {
                      setState(() {
                        Task cache = star.removeAt(i);
                        todos.remove(cache);
                        done.add(cache);
                      });
                      snack(state, 'Marked as done');
                    } else if (value == 'delete') {
                      removeTask(star[i]);
                    }
                  });
                },
                child: Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      removeTask(star[i]);
                    } else if (direction == DismissDirection.startToEnd) {
                      removeStar(star[i]);
                    }
                  },
                  background: Container(
                    color: yellowTint,
                    padding: const EdgeInsets.all(16),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.star_border, size: 32),
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.all(16),
                    child: const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.delete_outline, size: 32)),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      shape: const CircleBorder(),
                      value: false,
                      onChanged: (bool? value) {
                        setState(() {
                          Task cache = star.removeAt(i);
                          todos.remove(cache);
                          done.add(cache);
                        });
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    title: Text(star[i].title),
                    subtitle: (star[i].deadline != null)
                        ? Text(df.format(star[i].deadline!.toLocal()))
                        : null,
                  ),
                ),
              );
            },
          );
  }
}

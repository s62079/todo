import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'model_task.dart';
import 'utils.dart';
import 'widget_add_task.dart';
import 'widget_tasks.dart';
import 'widget_tasks_star.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 1;
  double navElevation = 3;

  Widget addTaskButton() => FloatingActionButton(
        // https://stackoverflow.com/questions/54515186
        onPressed: () async {
          setState(() => navElevation = 1);
          // https://stackoverflow.com/questions/53869078
          await showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => const AddTaskView(),
          ).then((task) async {
            if (task is Task) {
              setState(() {
                task.addTodo();
                pageIndex = 1;
              });
              await Data.save();
            }
          });
          setState(() => navElevation = 3);
        },
        child: const Icon(Icons.add),
      );

  @override
  Widget build(BuildContext context) {
    // https://api.flutter.dev/flutter/material/NavigationBar/backgroundColor.html
    final ColorScheme scheme = Theme.of(context).colorScheme;
    Color navColor = tintColor(scheme.surface, scheme.primary, navElevation);

    final ScaffoldMessengerState mState = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          // https://stackoverflow.com/questions/51012360
          systemNavigationBarColor: navColor,
          // https://stackoverflow.com/questions/55211640
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
        ),
        title: Text(['Important Tasks', 'Tasks'][pageIndex]),
        centerTitle: true,
      ),
      // ignore: prefer_const_constructors
      body: <Widget>[StarTasksView(), TasksView()][pageIndex],
      // https://stackoverflow.com/questions/73669989
      floatingActionButton: kReleaseMode
          ? addTaskButton()
          : InkWell(
              // demo purposes
              onLongPress: () async {
                await Data.dummy();
                setState(() {});
                snack(mState, 'DEBUG: DUMMY DATA ADDED');
              },
              onDoubleTap: () async {
                await Data.nuke();
                setState(() {});
                snack(mState, 'DEBUG: BOOM');
              },
              // add task
              child: addTaskButton(),
            ),
      // https://api.flutter.dev/flutter/material/NavigationBar-class.html
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          mState.removeCurrentSnackBar();
          setState(() => pageIndex = index);
        },
        selectedIndex: pageIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.star), label: 'Starred'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Tasks'),
        ],
        // selectedItemColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

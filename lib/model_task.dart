class Task {
  // https://www.geeksforgeeks.org/dart-static-keyword/
  static final List<Task> todos = [], done = [], star = [];

  // https://stackoverflow.com/questions/53547997
  static int _rules(Task a, Task b) {
    if (a.deadline != null) {
      if (b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      } else {
        return -1;
      }
    } else {
      if (b.deadline != null) {
        return 1;
      } else {
        return a.title.compareTo(b.title);
      }
    }
  }

  static void _sortDone() {
    done.sort((a, b) => a.title.compareTo(b.title));
  }

  static void _sortStar() {
    star.sort(_rules);
  }

  static void sortTodos() {
    todos.sort(_rules);
  }

  static void sortAll() {
    sortTodos();
    _sortDone();
    _sortStar();
  }

  DateTime? deadline;
  String title;
  String details;
  bool starred;

  Task({
    required this.title,
    this.deadline,
    this.details = "",
    this.starred = false,
  }) {
    if (starred) {
      addStar();
    }
  }

  // https://docs.flutter.dev/data-and-backend/serialization/json
  Task.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        details = json['details'] as String,
        deadline = DateTime.tryParse(json['deadline']),
        starred = json['starred'] ??= false {
    if (starred) {
      addStar();
    }
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'details': details,
        'deadline': (deadline != null) ? deadline.toString() : '',
        'starred': starred
      };

  void addTodo({bool wasStarred = false}) {
    todos.add(this);
    sortTodos();
    starred = wasStarred;
    addStar();
  }

  bool removeTodo() {
    todos.remove(this);
    if (starred && star.contains(this)) {
      starred = false;
      removeStar();
    }
    return !starred;
  }

  void addDone() {
    done.add(this);
    _sortDone();
  }

  void removeDone() {
    done.remove(this);
  }

  void flipDone() {
    if (done.contains(this)) {
      removeDone();
      addTodo();
    } else {
      addDone();
      removeTodo();
    }
  }

  void addStar() {
    if (starred) {
      star.add(this);
      _sortStar();
    }
  }

  void removeStar() {
    if (!starred) {
      star.remove(this);
    }
  }

  void flipStar() {
    starred = !starred;
    if (star.contains(this)) {
      removeStar();
    } else {
      addStar();
    }
  }
}

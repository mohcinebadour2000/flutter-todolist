import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Map<String, dynamic>> _todoList = []; // Liste des tâches avec état (complète ou non)
  final _textController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // Charger les tâches depuis SharedPreferences
  void _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todos = prefs.getStringList('todos') ?? [];
    setState(() {
      _todoList = todos.map((todo) {
        final parts = todo.split('|');
        return {
          'text': parts[0],
          'completed': parts[1] == 'true',
        };
      }).toList();
    });
  }

  // Sauvegarder les tâches dans SharedPreferences
  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todos = _todoList.map((todo) {
      return '${todo['text']}|${todo['completed']}';
    }).toList();
    prefs.setStringList('todos', todos);
  }

  void _addTodoItem(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _todoList.add({'text': task, 'completed': false});
        _saveTodos(); // Sauvegarder après ajout
      });
      _textController.clear();
    }
  }

  void _toggleCompletion(int index) {
    setState(() {
      _todoList[index]['completed'] = !_todoList[index]['completed'];
      _saveTodos(); // Sauvegarder après modification
    });
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoList.removeAt(index);
      _saveTodos(); // Sauvegarder après suppression
    });
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoList.length,
      itemBuilder: (context, index) {
        return _buildTodoItem(_todoList[index], index);
      },
    );
  }

  Widget _buildTodoItem(Map<String, dynamic> todo, int index) {
    return ListTile(
      leading: Checkbox(
        value: todo['completed'],
        onChanged: (bool? value) {
          _toggleCompletion(index);
        },
      ),
      title: Text(
        todo['text'],
        style: TextStyle(
          fontSize: 18,
          decoration: todo['completed'] ? TextDecoration.lineThrough : null,
          color: todo['completed'] ? Colors.grey : Colors.black,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          _removeTodoItem(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('To-Do List App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter a new task',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _addTodoItem(_textController.text);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildTodoList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                _showFilterDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Tasks'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('All'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement filter logic if needed
                },
              ),
              ListTile(
                title: Text('Completed'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement filter logic if needed
                },
              ),
              ListTile(
                title: Text('Pending'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement filter logic if needed
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

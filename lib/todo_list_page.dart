import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  static const String _storageKey = 'todo_list';

  final TextEditingController _textController = TextEditingController();
  List<String> _todos = <String>[];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_storageKey) ?? <String>[];
    setState(() {
      _todos = List<String>.from(items);
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _todos);
  }

  void _addTodoItem(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return;
    }
    setState(() {
      _todos.add(trimmed);
    });
    _saveTodos();
    _textController.clear();
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  Future<void> _displayAddDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nouvelle tache'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: 'Entrez votre tache',
            ),
            autofocus: true,
            onSubmitted: (value) {
              _addTodoItem(value);
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _textController.clear();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _addTodoItem(_textController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes taches'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Text('Aucune tache pour le moment.'),
            )
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(_todos[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeTodoItem(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayAddDialog,
        tooltip: 'Ajouter une tache',
        child: const Icon(Icons.add),
      ),
    );
  }
}

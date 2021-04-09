import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Lista de Afazeres',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: TodoList());
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class Todo {
  String name;
  String description;
}

class _TodoListState extends State<TodoList> {
  final _todos = <Todo>[];

  final _biggerFont = TextStyle(fontSize: 18.0);

  Widget _buildList() {
    if (_todos.isEmpty) {
      return Center(
        child: Text(
          'Sua lista está vazia! Adicione alguns itens nela :)',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;

        return _buildRow(_todos[index]);
      },
    );
  }

  Widget _buildRow(Todo todo) {
    return ListTile(
      title: Text(
        todo.name,
        style: _biggerFont,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
      body: _buildList(),
    );
  }
}

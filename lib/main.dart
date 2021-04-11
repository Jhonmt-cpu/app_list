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
  String name = '';
  String description = '';
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

  void _pushAddTodo() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

      final form = Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Insira o título da tarefa',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Título obrigatório';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                minLines: 7,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText: 'Insira a descrição da tarefa',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Descrição obrigatória';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print(_formKey.currentState?.context);
                  }
                },
                style: ButtonStyle(),
                child: Text('Cadastrar'),
              ),
            )
          ],
        ),
      );

      return Scaffold(
        appBar: AppBar(
          title: Text('Adicionar tarefa'),
        ),
        body: form,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _pushAddTodo();
        },
      ),
      body: _buildList(),
    );
  }
}

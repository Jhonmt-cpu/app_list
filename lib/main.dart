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
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class Todo {
  var name;
  var description;

  Todo(String name, String description) {
    this.name = name;
    this.description = description;
  }
}

class _TodoListState extends State<TodoList> {
  final _todos = <Todo>[];

  final _biggerFont = TextStyle(fontSize: 18.0);

  void _pushAddTodo() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    var _todoName;
    var _todoDescription = "";
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      final form = Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: (InputDecoration(
                    labelText: "Nome do Afazer",
                    icon: Icon(Icons.library_add),
                  )),
                  onSaved: (String value) {
                    _todoName = value;
                  },
                  validator: (String value) {
                    return (value == null || value.isEmpty
                        ? "Nome obrigatório"
                        : null);
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: "Descrição do Afazer",
                    icon: Icon(Icons.list_alt),
                  ),
                  onSaved: (String value) {
                    _todoDescription = value;
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        setState(() {
                          _todos.add(new Todo(_todoName, _todoDescription));
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("$_todoName adicionada!"),
                        ));
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Adicionar Afazer"))
              ],
            ),
          ),
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

  void _pushShowTodo(Todo todo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext coontext) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Afazer"),
            ),
            body: ListView(
              children: [
                ListTile(
                  title: Text(
                    todo.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    todo.description,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
        if (i < _todos.length) {
          return Card(
            child: _buildRow(_todos[i]),
          );
        }

        return null;
      },
    );
  }

  Widget _buildRow(Todo todo) {
    return ListTile(
      title: Text(
        todo.name,
        style: _biggerFont,
      ),
      onTap: () => _pushShowTodo(todo),
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
        onPressed: () {
          _pushAddTodo();
        },
      ),
      body: _buildList(),
    );
  }
}

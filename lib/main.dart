import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

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
  Todo({
    this.id,
    this.title,
    this.description,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        createdAt: DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "createdAt": createdAt,
      };
}

class _TodoListState extends State<TodoList> {
  var _todos = <Todo>[];

  final _biggerFont = TextStyle(fontSize: 18.0);

  var dio = Dio();

  Future<String> _getTodos() async {
    dio.options.baseUrl =
        "https://8zc8b4woh8.execute-api.us-east-2.amazonaws.com/staging";

    var response = await dio.get<List>('/todo');
    var todosList = response.data.map((todo) {
      return Todo.fromJson(todo);
    }).toList();
    _todos = todosList;
    return response.data.toString();
  }

  Future<Todo> _showTodo(String id) async {
    dio.options.baseUrl =
        "https://8zc8b4woh8.execute-api.us-east-2.amazonaws.com/staging";
    var response = await dio.get("/todo/$id");
    var todo = Todo.fromJson(response.data);
    print(todo.description);
    return todo;
  }

  Future<void> _createTodo({String title, String description}) async {
    dio.options.baseUrl =
        "https://8zc8b4woh8.execute-api.us-east-2.amazonaws.com/staging";
    var response = await dio
        .post("/todo", data: {"title": title, "description": description});
    var todo = Todo.fromJson(response.data);
    _todos.add(todo);
  }

  Future<void> _updateTodo({
    String title,
    String description,
    String id,
    String createdAt,
  }) async {
    dio.options.baseUrl =
        "https://8zc8b4woh8.execute-api.us-east-2.amazonaws.com/staging";
    await dio.put(
      "/todo",
      data: {
        "title": title,
        "description": description,
        "id": id,
        "createdAt": createdAt,
      },
    );
  }

  Future<void> _deleteTodo(String id) async {
    dio.options.baseUrl =
        "https://8zc8b4woh8.execute-api.us-east-2.amazonaws.com/staging";
    dio.delete("/todo/$id");
  }

  void _pushAddTodo() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    var _todoTitle;
    var _todoDescription = "";
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
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
                    _todoTitle = value;
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
                  validator: (String value) {
                    return (value == null || value.isEmpty
                        ? "Nome obrigatório"
                        : null);
                  },
                  decoration: InputDecoration(
                    labelText: "Descrição do Afazer",
                    icon: Icon(Icons.list_alt),
                  ),
                  onSaved: (String value) {
                    _todoDescription = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      await _createTodo(
                          title: _todoTitle, description: _todoDescription);
                      setState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("$_todoTitle adicionada!"),
                      ));
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Adicionar Afazer"),
                )
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

  Future<void> _pushShowTodo(String id) async {
    var todo = await _showTodo(id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext coontext) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Afazer"),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _pushEditTodo(todo);
                    setState(() {});
                  },
                )
              ],
            ),
            body: ListView(
              children: [
                ListTile(
                  title: Text(
                    todo.title,
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

  Future<void> _pushEditTodo(Todo todo) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    var _todoTitle = todo.title;
    var _todoDescription = todo.description;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
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
                  initialValue: todo.title,
                  decoration: (InputDecoration(
                    labelText: "Nome do Afazer",
                    icon: Icon(Icons.library_add),
                  )),
                  onSaved: (String value) {
                    _todoTitle = value;
                  },
                  validator: (String value) {
                    return (value == null || value.isEmpty
                        ? "Nome obrigatório"
                        : null);
                  },
                ),
                TextFormField(
                  initialValue: todo.description,
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
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      await _updateTodo(
                        title: _todoTitle,
                        description: _todoDescription,
                        id: todo.id,
                        createdAt: todo.createdAt.toString(),
                      );
                      setState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("$_todoTitle atualizado!"),
                      ));
                      Navigator.popUntil(context,
                          (route) => Navigator.of(context).canPop() == false);
                    }
                  },
                  child: Text("Adicionar Afazer"),
                )
              ],
            ),
          ),
        ),
      );

      return Scaffold(
        appBar: AppBar(
          title: Text("Editar tarefa"),
        ),
        body: form,
      );
    }));
  }

  FutureBuilder<String> _buildList() {
    return FutureBuilder(
      future: _getTodos(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text(
              'Sua lista está vazia! Adicione alguns itens nela :)',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          );
        } else {
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
      },
    );
  }

  Widget _buildRow(Todo todo) {
    return ListTile(
      title: Text(
        todo.title,
        style: _biggerFont,
      ),
      onTap: () => _pushShowTodo(todo.id),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            onPressed: () async {
              await _deleteTodo(todo.id);
              setState(
                () {
                  _todos.remove(todo);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${todo.title} removida"),
                    ),
                  );
                },
              );
            },
          ),
        ],
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
        onPressed: () {
          _pushAddTodo();
        },
      ),
      body: _buildList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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
    // dio.options.baseUrl = "http://10.0.0.121:3001";

    try {
      var response = await dio.get<List>('/todo');
      var todosList = response.data.map((todo) {
        return Todo.fromJson(todo);
      }).toList();
      _todos = todosList;
      return response.data.toString();
    } catch (e) {
      return "error";
    }
  }

  Future<Todo> _showTodo(String id) async {
    dio.options.baseUrl =
        "https://8zc8b4woh8.execute-api.us-east-2.amazonaws.com/staging";
    var response = await dio.get("/todo/$id");
    var todo = Todo.fromJson(response.data);
    print(todo.description);
    return todo;
  }

  Future<int> _createTodo({String title, String description}) async {
    dio.options.baseUrl =
        "https://8zc8b4woh8.execute-api.us-east-2.amazonaws.com/staging";
    // dio.options.baseUrl = "http://10.0.0.121:3001";

    try {
      var response = await dio
          .post("/todo", data: {"title": title, "description": description});
      var todo = Todo.fromJson(response.data);
      _todos.add(todo);
      return response.statusCode;
    } on DioError catch (e) {
      return e.response.statusCode;
    }
  }

  Future<int> _updateTodo({
    String title,
    String description,
    String id,
    String createdAt,
  }) async {
    dio.options.baseUrl =
        "https://8zc8b4woh8.execute-api.us-east-2.amazonaws.com/staging";
    // dio.options.baseUrl = "http://10.0.0.121:3001";
    try {
      var response = await dio.put(
        "/todo",
        data: {
          "title": title,
          "description": description,
          "id": id,
          "createdAt": createdAt,
        },
      );

      return response.statusCode;
    } on DioError catch (e) {
      return e.response.statusCode;
    }
  }

  Future<int> _deleteTodo(String id) async {
    dio.options.baseUrl =
        "https://8zc8b4woh8.execute-api.us-east-2.amazonaws.com/staging";
    // dio.options.baseUrl = "http://10.0.0.121:3001";
    try {
      var response = await dio.delete("/todo/$id");
      return response.statusCode;
    } on DioError catch (e) {
      return e.response.statusCode;
    }
  }

  Future<void> _reloadPage() async {
    setState(() {});
    await Future.delayed(Duration(seconds: 4), () {});
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
                  textCapitalization: TextCapitalization.sentences,
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
                      var response = await _createTodo(
                          title: _todoTitle, description: _todoDescription);

                      if (response == 200) {
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("$_todoTitle adicionada!"),
                        ));
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Afazer não salvo, tente mais tarde"),
                        ));
                      }
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

  Future<void> _pushShowTodo(Todo todo) async {
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
                  textCapitalization: TextCapitalization.sentences,
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
                      var responseStatus = await _updateTodo(
                        title: _todoTitle,
                        description: _todoDescription,
                        id: todo.id,
                        createdAt: todo.createdAt.toString(),
                      );
                      if (responseStatus == 200) {
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("$_todoTitle atualizado!"),
                        ));
                        Navigator.popUntil(context,
                            (route) => Navigator.of(context).canPop() == false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("Afazer não atualizado! Tente novamente"),
                        ));
                      }
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
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data.toString() == "error") {
            return Center(
              child: Text(
                'Eita, parece que ocorreu um erro ao trazer suas tarefas :( Tente novamente mais tarde',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else if (snapshot.data.length == 2) {
            return Center(
              child: Text(
                'Parece que você não tem afazeres cadastrados, adicione alguns :)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _reloadPage,
              child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemBuilder: (context, i) {
                  if (i < _todos.length) {
                    return Card(
                      child: _buildRow(_todos[i]),
                    );
                  }

                  return null;
                },
              ),
            );
          }
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
      onTap: () => _pushShowTodo(todo),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            onPressed: () async {
              var responseStatus = await _deleteTodo(todo.id);
              if (responseStatus == 200) {
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
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Erro ao deletar o afazer, tente novamente"),
                  ),
                );
              }
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo.dart';
import 'addTodo.dart';
import 'clearList.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future<Database> database = initDatabase();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {   //한곳에서 모든 경로를 관리하여, 편리하게 화면 이동을 구현
        '/': (context) => DatabaseApp(database), //database 객체를 전달하게 함 [한 곳에서 데이터베이스를 호출하고, 페이지 별로 한 번 호출된 데이터베이스를 사용할 수 있음]
        '/add': (context) => AddTodoApp(database),
        '/clear': (context) => ClearListApp(database)
      },
    );
  }

  Future<Database> initDatabase() async{        //데이터베이스를 열어서 반환
    return openDatabase(
      join(await getDatabasesPath(), 'todo_database.db'), //getDatabasesPath()함수가 반환하는 경로에 파일명으로 저장되어 있음
      onCreate: (db, version){
        return db.execute(
          "CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "title TEXT, content TEXT, active INTEGER)",
        );
      },
      version: 1,
    );
  }
}

class DatabaseApp extends StatefulWidget {
  final Future<Database> db;  //MyApp에서 객체 전달을 해주어서, 그에 따라서 필요
  DatabaseApp(this.db);

  @override
  State<StatefulWidget> createState() => _DatabaseApp();
}

class _DatabaseApp extends State<DatabaseApp> {
  Future<List<Todo>>? todoList;

  Future<List<Todo>> getTodos() async{
    final Database database = await widget.db; //widget.db에서 가져온 데이터베이스를 '선언'
    final List<Map<String,dynamic>> maps = await database.query('todos'); //todos 테이블을 가져와서 maps목록에 넣음

    return List.generate(maps.length, (i){ //할일 목록에 표시할 목록(각 아이템)을 생성
      int active = maps [i]['active'] == 1? 1 :0;
      return Todo(
        title: maps[i]['title'].toString(),
        content: maps[i]['content'].toString(),
        active: active,
        id: maps[i]['id']);
    });
  }

  @override
  void initState(){ //해야할 일 목록은 계속해서 변하니까 따로 호출
    super.initState();
    todoList = getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Example'),
        actions: <Widget>[
          TextButton(
            onPressed: ()async{
              await Navigator.of(context).pushNamed('/clear');
              setState((){
                todoList = getTodos();
              });
            },
            child: Text(
              '완료한 일',
              style: TextStyle(color: Colors.white),
            )
          )
        ],
      ),
      body: Container(
        child: Center(
          child: FutureBuilder(             // 서버에서 데이터를 받거나, 파일에서 데이터를 불러올 때 사용합니다. 시간이 소요되어, 그 사이에 표시할 위젯을 만들기 위해서 지금상태를 확인
            builder: (context, snapshot){
              switch(snapshot.connectionState){
                case ConnectionState.none:
                  return CircularProgressIndicator();
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                case ConnectionState.active:
                  return CircularProgressIndicator();
                case ConnectionState.done:
                  if(snapshot.hasData){
                    return ListView.builder( //화면에 목록 표시 함수
                      itemBuilder: (context,index){
                        Todo todo = (snapshot.data as List<Todo>)[index];
                        return ListTile(
                          title:Text(
                            todo.title!,
                            style: TextStyle(fontSize: 20),
                          ),
                          subtitle:Container(
                            child : Column(
                              children: <Widget>[
                                Text(todo.title!),
                                Text(todo.content!),
                                Text('${todo.active == 1? 'true' : 'false'}'),
                                Container(
                                  height: 1,
                                  color: Colors.blue,
                                )
                              ],
                            ),
                          ),
                          onTap: () async{
                            TextEditingController controller = // 내용도 고칠 수 있게 선언
                            new TextEditingController(text: todo.content);
                            Todo result = await showDialog( //알림 창 호출 (비동기로)
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog( // 실제 알림창, 예 고르면 변경 후 데이터 전달
                                  title: Text('${todo.id} : ${todo.title}'),
                                  content: TextField(
                                    controller: controller,
                                      keyboardType: TextInputType.text,
                                  ),

                                  actions: <Widget>[
                                    TextButton(
    onPressed:(){
    todo.active ==1
    ? todo.active=0
    : todo.active=1;
    todo.content = controller.value.text;
    Navigator.of(context).pop(todo);
    },
    child: Text('예')),
    TextButton(
    onPressed: (){
    Navigator.of(context).pop(todo);
    },
    child: Text('아니오')),
    ],

                                );
                              });
                            _updateTodo(result);
                          },
                          onLongPress: () async{
                            Todo result = await showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                    title: Text('${todo.id} : ${todo.title}'),
                                    content: Text('${todo.content}를 삭제하시겠습니까?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: (){
                                        Navigator.of(context).pop(todo);
                                      },
                                      child: Text('예')),
                                TextButton(
                                  onPressed:(){
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('아니요')),

                                  ],
                                );
                              }
                            );
                            _deleteTodo(result);
                          },
                        );
                      },
                      itemCount: (snapshot.data as List<Todo>).length,
                    );
                  } else {
                    return Text('No data');
                  }
              }
              return CircularProgressIndicator();   //왜 dead code라고 뜨는 거지 ?
            },
            future:todoList,
          ),
        ),
      ),
      floatingActionButton: Column(
        children: <Widget>[FloatingActionButton(
          onPressed: () async{
            final todo = await Navigator.of(context).pushNamed('/add');
            if(todo != null){
              _insertTodo(todo as Todo);
            }
          },
          heroTag: null, // Column 위젯에서는 중요, 설정하지않으면 오류가 발생함. 화면을 넘길 때 자연스러운 애니메이션을 추가. 받아줄 태그가 필요
          child: Icon(Icons.add),),
        SizedBox(
          height: 10,
        ),
          FloatingActionButton(
              onPressed: () async {
                _allUpdate();
              },
    heroTag: null,
    child: Icon(Icons.update),
    ),
    ],
    mainAxisAlignment: MainAxisAlignment.end,
    ));
  }

  void _insertTodo(Todo todo) async{ //widget.db 이용해 객체를 선언하고 전달받은 데이터를 입력하는함수
    final Database database = await widget.db;
    await database.insert('todos', todo.toMap(), // 'todos' (첫번째 인자) 는 테이블 이름 / 두번째 인자로 전달한 toMap() 은
        // todo 클래스를 map 형태로 바꿔줌
      conflictAlgorithm: ConflictAlgorithm.replace); //충돌 발생을 대비한 것임 (id값 중복 시 새 데이터로 교체해라고 replace선언
    setState(() { //갱신
      todoList = getTodos();
    });
  }

  void _updateTodo(Todo todo) async{
    final Database database = await widget.db;
    await database.update(  //수정할 데이터
      'todos',
      todo.toMap(),
      where: 'id =?',         // id값으로 수정할 데이터 찾기
      whereArgs: [todo.id], // 전달받은 할일 데이터 값을 설정

    );
    setState((){
      todoList = getTodos();
    });
  }

  void _deleteTodo(Todo todo) async{
    final Database database = await widget.db;
    await database.delete('todos', where: 'id=?', whereArgs: [todo.id]);
    setState(() {
      todoList= getTodos();
    });
  }

  void _allUpdate() async{
    final Database database = await widget.db;
    await database.rawUpdate('update todos set active = 1 where active = 0');
    setState(() {
      todoList = getTodos();
    });
  }
}

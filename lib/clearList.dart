import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqlite_api.dart';
import 'todo.dart';

class ClearListApp extends StatefulWidget{
  Future<Database> database;
  ClearListApp(this.database);

  @override
  State<StatefulWidget> createState() => _ClearListApp();
}

class _ClearListApp extends State<ClearListApp>{
  Future<List<Todo>>? clearList;

  @override
  void initState(){
    super.initState();
    clearList= getClearList();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('완료한 일'),
      ),
      body: Container(
        child: Center(
          child: FutureBuilder(
            builder: (context, snapshot){
              switch (snapshot.connectionState){
                case ConnectionState.none:
                  return CircularProgressIndicator();
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                case ConnectionState.active:
                  return CircularProgressIndicator();
                case ConnectionState.done:
                  if(snapshot.hasData){
                    return ListView.builder(
                        itemBuilder:(context,index){
                          Todo todo = (snapshot.data as List<Todo>)[index];
                          return ListTile(
                            title : Text(
                              todo.title!,
                              style : TextStyle(fontSize:20),
                            ),
                            subtitle:Container(
                              child: Column(
                                children:<Widget>[
                                  Text(todo.content!),
                                  Container(
                                    height: 1,
                                    color: Colors.blue,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      itemCount: (snapshot.data as List<Todo>).length,
                    );
                  }
              }
              return Text('No data');
            },
            future: clearList,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final result =await showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text('완료한 일 삭제'),
                content: Text('완료한 일을 모두 삭제할까요?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop(true);
                    },
                    child: Text('예')),
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop(false);
                },
                child: Text('아니요')),

                ],
              );
            });
          if(result==true){
            _removeAllTodos();
          }
        },
        child: Icon(Icons.remove),
      ),
    );
  }
  void _removeAllTodos() async{
    final Database database = await widget.database;
    database.rawDelete('delete from todos where active=1'); //database에서 데이터를 삭제하는 rawDelete 함수로 질의문 전달
    setState(() {
      clearList = getClearList();
    });
  }

  Future<List<Todo>> getClearList() async{ // rawQuery함수 : 직접 SQL질의문을 전달해 데이터베이스에 질의 (select)
    final Database database = await widget.database;
    List<Map<String, dynamic>> maps = await database
        .rawQuery('select title, content, id from todos where active=1'); //todos에서 active=1의 값인 title. content, id값을 대입

    return List.generate(maps.length, (i){
      return Todo(
        title: maps[i]['title'].toString(),
        content: maps[i]['content'].toString(),
        id: maps[i]['id']);
      });
  }
}
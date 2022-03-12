import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _FileApp();
}

class _FileApp extends State<FileApp>{
  int _count = 0;
  List<String> itemList = new List.empty(growable: true);
  TextEditingController controller = new TextEditingController();

  @override
  void initState(){
    super.initState();
    readCountFile();
    initData();
  }

  void initData() async{
    var result = await readListFile();
    setState(() {
      itemList.addAll(result);
    });
  }

  Future<List<String>> readListFile() async{  // 처음 실행 시 에셋의 파일을 읽어서, 내부 저장소에 다시저장. 이후 다음실행시 부터는 내부저장소에서 대상을 불러옴
    List<String> itemList = new List.empty(growable: true);
    var key = 'first';    // 키값 지정.
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? firstCheck = pref.getBool(key); //키값을 통한 불값을 가져와서 저장(할당) => 이후 파일을 처음 열었는지 확인하는 용도로 사용
    var dir = await getApplicationDocumentsDirectory();
    bool fileExist = await File(dir.path + '/fruit.txt').exists(); //지정한 파일 경로에 파일이 존재하는지 여부 확인

    if(firstCheck == null || firstCheck == false || fileExist == false){
      pref.setBool(key,true);
      var file =
          await DefaultAssetBundle.of(context).loadString('repo/fruit.txt');

      File(dir.path + '/fruit.txt').writeAsStringSync(file);

      var array = file.split('\n'); //개행으로 구분하여 배열 형태로
      for (var item in array){
        print(item);
        itemList.add(item);
      }
      return itemList;
    } else {
      var file = await File(dir.path + '/fruit.txt').readAsString();
      var array = file.split('\n');
      for (var item in array){
        print(item);
        itemList.add(item);
      }
      return itemList;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
    appBar:AppBar(
    title: Text('File Example'),
    ),
    body: Container(
      child:Center(
        child:Column(
          children: <Widget>[
            TextField(
              controller: controller,
              keyboardType: TextInputType.text,
            ),
            Expanded(
                child: ListView.builder(
                  itemBuilder: (context,index){
                    return Card(
                      child:Center(
                        child:Text(
                          itemList[index],
                          style:TextStyle(fontSize:30),
                        ),
                      ),
                    );
                  },
                  itemCount: itemList.length,
                ),
            )
          ],
        ),
      ),
    ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          writeFruit(controller.value.text);
          setState(() {
            itemList.add(controller.value.text);
          });
          },
        child: Icon(Icons.add),
      ),
    );
  }

  void writeCountFile(int count) async{ //파일 입출력은 작업 종료 예측이 불가능, async 이용하여 비동기 처리
    var dir = await getApplicationDocumentsDirectory(); // 내부저장소의 경로를 가져옴
    File(dir.path + '/count.txt').writeAsStringSync(count.toString());
  }

  void readCountFile() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var file = await File(dir.path + '/count.txt').readAsString();
      print(file);
      setState(() {
        _count = int.parse(file);   //count 값을 파일에서 불러서 할당
      });
    } catch(e){
      print(e.toString());
    }
  }

  void writeFruit(String fruit) async{
    var dir = await getApplicationDocumentsDirectory();
    var file = await File(dir.path + '/fruit.txt').readAsString();
    file = file + '\n' + fruit;
    File(dir.path + '/fruit.txt').writeAsStringSync(file);
  }
}
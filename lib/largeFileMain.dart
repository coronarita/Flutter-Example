import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LargeFileMain extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LargeFileMain();

}
class _LargeFileMain extends State<LargeFileMain>{
  //img address
/*  final imgUrl = 'https://images.pexels.com/photos/240040/pexels-photo-240040.jpeg'
      '?auto=compress';*/
  TextEditingController? _editingController;
  bool downloading = false;
  var progressString = "";
 // var file;
  String? file = "";

  @override
  void initState(){
    super.initState();
    _editingController = new TextEditingController(
      text: 'https://images.pexels.com/photos/240040/pexels-photo-240040.jpeg'
          '?auto=compress');

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:
        //Text('Large File Example'),
        TextField(
          controller: _editingController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
            decoration: InputDecoration(hintText: 'url 입력하세요'),
        ),
      ),
      body: Center(
        child : downloading
            ? Container(
              height: 120.0,
              width: 200.0,
              child : Card(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(
                        height:20.0,
                      ),
                      Text(
                        'Downloading File: $progressString',
                        style: TextStyle(
                          color:Colors.white,
                        ),
                      )
                    ],
                ),
              ),
        )
            : FutureBuilder( //이 위젯으로 이미지 내려받기 화면 생성, '데이터 비동기방식처리'로 Future이용, snapshot변수를 반환하는데, dynamic변수임
            builder: (context, snapshot){
              switch ( snapshot.connectionState){
                case ConnectionState.none:
                  print('none');
                  return Text('데이터 없음');
                case ConnectionState.waiting:
                  print('waiting');
                  return CircularProgressIndicator();
                case ConnectionState.active:
                  print('active');
                  return CircularProgressIndicator();
                case ConnectionState.done:
                  print('done');
                  if(snapshot.hasData){
                    return snapshot.data as Widget; // 저자 코드보고 수정
                  }
              }
              print('end process');
              return Text('데이터 없음');
            },
    future: downloadWidget(file!),
        )),
            floatingActionButton: FloatingActionButton(
          onPressed: (){
            downloadFile();
            },
          child:Icon(Icons.file_download),
       ),
      );
  }

  Future<void> downloadFile() async{
    Dio dio = Dio();
    try{
      var dir = await getApplicationDocumentsDirectory(); //플러터앱의 내부디렉토리 불러옴
      await dio.download(_editingController!.value.text, '${dir.path}/myimage.jpg', // url에 담긴 파일을 내려받아,myimage.jpg 로 저장
      onReceiveProgress: (rec, total){ // 데이터 받으면서 진행상황 표시
        print('Rec: $rec, Total: $total'); //rec : 현재까지 , total : 전체크기
        file = '${dir.path}/myimage.jpg';
        setState(() { //파일 내려받기 시작하면 true 선언 후 계산해서 progress 표시 문자열에 입력
          downloading = true;
          progressString = ((rec/total) * 100).toStringAsFixed(0) + '%';
        });
      });
    } catch(e){ //error발생 시
      print(e);
    }
    setState(() { //다 내려받고 false로 고침
      downloading = false;
      progressString = 'Completed';
    });
    print('Download completed');
  }

  Future<Widget> downloadWidget(String filePath) async{  //img 파일을 확인 후 있으면 보여주는 위젯 반환 없으면 No Data 출력
    File file = File(filePath);
    bool exist = await file.exists();
    new FileImage(file).evict(); // evict : 캐시*임시저장메모리 초기화

    if(exist){
      return Center(
        child: Column(
          children: <Widget>[Image.file(File(filePath))],
        ),
      );

    } else {
      return Text('No Data');
    }
  }
}
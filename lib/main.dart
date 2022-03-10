import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: HttpApp(),
    );
  }
}

class HttpApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _HttpApp();
}

class _HttpApp extends State<HttpApp>{
  String result = '';
  List? data;
  TextEditingController? _editingController;
  ScrollController? _scrollController;
  int page = 1;

  @override
  void initState(){
    super.initState();
    data= new List.empty(growable: true);
    _editingController = new TextEditingController();
    _scrollController = new ScrollController();

    _scrollController!.addListener(() {
      if(_scrollController!.offset>=        // scroll 현재 위치가 double형 변수로
      _scrollController!.position.maxScrollExtent &&
      !_scrollController!.position.outOfRange){
        print('bottom');
        page++;
        getJSONData();
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        title: TextField(
         controller: _editingController,
         style: TextStyle(color:Colors.white),
         keyboardType: TextInputType.text,
         decoration: InputDecoration(hintText: '검색어를 입력하세요'),
        ),
      ),
      body: Container(
        child: Center(
          child: data!.length ==0                                             //null safety 처리
            ? Text(
              '데이터가 없습니다.',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        )
        : ListView.builder(
          itemBuilder: (context,index){
            return Card(
              child: Container(
                child:Row(
                  children:<Widget>[
/*                    Text(data![index]['title'].toString()),                   //null safety 처리
                    Text(data![index]['authors'].toString()),
                    Text(data![index]['sale_price'].toString()),
                    Text(data![index]['status'].toString()),*/
                    Image.network(data![index]['thumbnail'],                              //null safety 처리
                      height: 100,
                      width:100,
                      fit: BoxFit.contain,
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width - 150,
                          child: Text(
                            data![index]['title'].toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text('저자 : ${data![index]['authors'].toString()}'), //저자 정보가 너무 길면, 개행을 해야되는 문제가 있음
                        Text('가격 : ${data![index]['sale_price'].toString()}'),
                        Text('판매중 : ${data![index]['status'].toString()}'),

                      ],
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
            );
          },
          itemCount: data!.length,
          controller: _scrollController,
          ),
        ),
    ),


      floatingActionButton: FloatingActionButton(
        onPressed: () {
          page =1;        //
          data!.clear();
          getJSONData();
        },
          child: Icon(Icons.file_download),
      ),
    );
  }

  Future<String> getJSONData() async{
    var url = 'https://dapi.kakao.com/v3/search/book?target=title&page=$page&query=${_editingController?.value.text}'; // dapi.kakao.com서버에 있는 v3/search/book API에게, title(제목)에 doit이 포함된 책을 검색하라고 호출
    var response = await http.get(Uri.parse(url),
    headers: {"Authorization": "KakaoAK 205b5b06216b204e07db600b8e04d450"}); // 카카오 서버와 직접통신하기에, REST API 키 삽입, http.get코드로 호출해서 책정보 가져옴
//    print(response.body);
    setState((){
      var dataConvertedToJSON = json.decode(response.body);
      List result = dataConvertedToJSON['documents'];
      data!.addAll(result); //null safety 처리
    });
    return "Successfull";
  }
}

// 추후 해결해야 할 것 : 새로운 거 검색 할 때, 화면 clear/reset한번 해야..

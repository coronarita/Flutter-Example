import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubPage Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
//      home: FirstPage(),
        initialRoute: '/',  // home 대신 initialRoute 와 routes 사용 ->>
        routes: {'/': (context) => FirstPage(), //<String[사용 할 문자열] :Widget[해당 경로가 가르키는 위젯]> 형태로 경로를 선언
                '/second': (context) => SecondPage()},
    );
  }
}

class FirstPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _FirstPage();
}

class _FirstPage extends State<FirstPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sub Page Main'),
        ),
        body: Container(
          child: Center(
           child: Text('첫 번째 페이지'),
           ),
         ),
      floatingActionButton: FloatingActionButton(
      onPressed: (){//현재 페이지에 SecondPage를 쌓는 것으로 해석
        Navigator.of(context) //Navigator : 스택 을 이용해 페이지를 관리 / of(context) 함수는 현재 페이지를 나타내고. push()함수는 스택에 페이지를 쌓는 역할을 함.
//            .push(MaterialPageRoute(builder: (context) => SecondPage())); //MaterialPageRoute는 머터리얼스타일로 페이지를 이동하게 해 줌.
              .pushNamed('/second'); //위에서 문자열로 route를 지정하여 위젯을 가리키게 하였음. [대소문자 구별 주의]
          },
        child: Icon(Icons.add),
        ),
      );
    }
}

class SecondPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        title: Text('Second Page'),
      ),
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed:(){
              Navigator.of(context).pop(); // pop()함수가 스택 메모리에서 맨위에 있는 페이지를 '제거'하는 의미.
            },
            child: Text('돌아가기'),
          ),
        ),
      ),
    );
  }
}
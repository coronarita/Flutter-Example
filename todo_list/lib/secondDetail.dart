import 'package:flutter/material.dart';

class SecondDetail extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    TextEditingController controller = new TextEditingController();

    return Scaffold(
      appBar:AppBar(
        title: Text('Second Page'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              TextField(
              controller: controller,
            keyboardType: TextInputType.text,
          ),
            ElevatedButton(
              onPressed:(){
                Navigator.of(context).pop(controller.value.text); // pop()함수가 스택 메모리에서 맨위에 있는 페이지를 '제거'하는 의미.
              },
              child: Text('저장하기'),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
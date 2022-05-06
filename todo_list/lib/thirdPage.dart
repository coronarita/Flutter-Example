import 'package:flutter/material.dart';

class ThirdDetail extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final String args = ModalRoute.of(context)!.settings.arguments.toString(); //라우터로 전달받은 데이터 가져오기 => args로 ///String으로 형변환 까지(자료형을 알 수 없음)

    return Scaffold(
      appBar: AppBar(
        title: Text('Third Page'),
      ),
      body: Container(
        child: Center(
          child: Text(
            args,
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}
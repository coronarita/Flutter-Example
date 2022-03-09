import 'package:flutter/material.dart';
import '../animalItem.dart';

class FirstApp extends StatelessWidget{
  final List<Animal> list;
  FirstApp({Key? key, required this.list}) : super(key: key); // required ?

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
          child: Center(
            child: ListView.builder(itemBuilder: (context,position){
              return GestureDetector( //터치이벤트 처리함수
                  child : Card(
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          list[position].imagePath!, //여기 nullable error 관련 처리 시 !로
                          height:100,
                          width:100,
                          fit: BoxFit.contain,
                        ),
                        Text(list[position].animalName!)
                      ],
                    ),
                  ),
                onTap: (){
                    AlertDialog dialog = AlertDialog(
                      content: Text(
                        '이 동물은 ${list[position].kind}입니다.',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    );
                    showDialog(context: context, builder: (BuildContext context) => dialog);
                },
              );
            },
            itemCount: list.length),
            ),
           ),
        );
  }
}
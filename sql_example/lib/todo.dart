class Todo {
  String? title;
  String? content;
  int? active;      //완료여부, sqLite 는 bool이 없어, 1/0으로 체크여부를 처리
  int? id;
  Todo({this.title, this.content, this.active, this.id});

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'title' : title,
      'content' : content,
      'active' : active,
    };
  }
}
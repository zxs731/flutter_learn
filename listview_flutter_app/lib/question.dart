import 'package:json_annotation/json_annotation.dart';

// question.g.dart 将在我们运行生成命令后自动生成
part 'question.g.dart';

///这个标注是告诉生成器，这个类是需要生成Model类的
@JsonSerializable()
class Question {
  int id;
  String title;
  String userAnswer;
  String correctedAnswer;
  Question(this.id, this.title, this.correctedAnswer);
  //不同的类使用不同的mixin即可
  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}


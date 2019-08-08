import 'package:json_annotation/json_annotation.dart';

// question.g.dart 将在我们运行生成命令后自动生成
part 'exam.g.dart';

///这个标注是告诉生成器，这个类是需要生成Model类的
@JsonSerializable()
class Exam {
  DateTime date;
  int duration;
  int score;
  Exam(this.score, this.date, this.duration);
  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
  Map<String, dynamic> toJson() => _$ExamToJson(this);
}
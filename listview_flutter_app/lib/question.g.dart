// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return Question(
    json['id'] as int,
    json['title'] as String,
    json['correctedAnswer'] as String,
  )..userAnswer = json['userAnswer'] as String;
}

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'userAnswer': instance.userAnswer,
      'correctedAnswer': instance.correctedAnswer,
    };

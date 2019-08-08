// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exam _$ExamFromJson(Map<String, dynamic> json) {
  return Exam(
    json['score'] as int,
    json['date'] == null ? null : DateTime.parse(json['date'] as String),
    json['duration'] as int,
  );
}

Map<String, dynamic> _$ExamToJson(Exam instance) => <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'duration': instance.duration,
      'score': instance.score,
    };

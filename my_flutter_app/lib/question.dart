class Question {
  final String title;
  final String answer;

  Question({this.title, this.answer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      title: json['title'],
      answer: json['answer'],
    );
  }
}

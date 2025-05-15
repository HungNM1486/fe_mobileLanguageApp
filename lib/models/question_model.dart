class QuestionModel {
  int id;
  String question;
  List<String> options;
  String answer;
  String hint;

  QuestionModel({
    required this.question,
    required this.options,
    required this.answer,
    required this.hint,
    this.id = 0,
  });
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] ?? 'No question',
      options: List<String>.from(json['options']) ?? [],
      answer: json['answer'] ?? 'No answer',
      hint: json['hint'] ?? 'No hint',
      id: json['id'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
      'hint': hint,
      'id': id,
    };
  }
}

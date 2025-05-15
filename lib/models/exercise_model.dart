import 'package:language_app/models/question_model.dart';

class ExerciseModel {
  int id;
  String name;
  String type;
  String level;
  String audio;
  String theory;
  String description;
  int duration;
  List<QuestionModel> questions;
  int result;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.level,
    required this.type,
    this.audio = "",
    this.theory = "",
    this.questions = const [],
    this.result = -1,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    // Xử lý kết quả cao nhất từ exerciseResults
    int highestScore = -1;
    if (json.containsKey('exerciseResults') &&
        json['exerciseResults'] != null) {
      List<dynamic> results = json['exerciseResults'];
      if (results.isNotEmpty) {
        try {
          highestScore = results
              .map((e) => e['score'] as int)
              .reduce((a, b) => a > b ? a : b);
        } catch (e) {
          print('Error calculating highest score: $e');
        }
      }
    }

    return ExerciseModel(
      id: json['id'] ?? 0,
      name: json['title'] ?? 'Unknown',
      description: json['description'] ?? 'No description',
      duration: json['duration'] ?? 0,
      type: json['type'] ?? 'Unknown',
      audio: json['audioText'] ?? 'No audio',
      level: json['difficulty'] ?? 'Unknown',
      theory: json['theory'] ?? 'No theory',
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((question) => QuestionModel.fromJson(question))
          .toList(),
      result: highestScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'description': description,
      'duration': duration,
      'type': type,
      'audioUrl': audio,
      'difficulty': level,
      'theory': theory,
      'questions': questions.map((question) => question.toJson()).toList(),
      'result': result,
    };
  }

  @override
  String toString() {
    return 'ExerciseModel{id: $id, name: $name, type: $type, level: $level, audio: ${audio ?? 'null'}, theory: ${theory ?? 'null'}, description: $description, duration: $duration, result: $result}';
  }
}

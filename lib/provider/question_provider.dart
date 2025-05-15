import 'package:flutter/material.dart';
import 'package:language_app/models/question_model.dart';

class QuestionProvider with ChangeNotifier {
  List<QuestionModel> _questions = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<QuestionModel> get questions => _questions;

  void addQuestion(String question) {
    notifyListeners();
  }

  void removeQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _questions.removeAt(index);
      notifyListeners();
    }
  }

  void clearQuestions() {
    _questions.clear();
    notifyListeners();
  }
}

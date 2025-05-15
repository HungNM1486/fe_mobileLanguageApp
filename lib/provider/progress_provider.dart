import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider with ChangeNotifier {
  String baseUrl = UrlUtils.getBaseUrl();
  bool _isLoading = false;
  int _topicCompleted = 0;
  int _totalTopic = 50;
  int _exerciseCompleted = 0;
  int _totalExercise = 50;
  int _examCompleted = 0;
  int _totalExam = 50;
  int _completed = 0;
  bool get isLoading => _isLoading;
  int get topicCompleted => _topicCompleted;
  int get totalTopic => _totalTopic;
  int get exerciseCompleted => _exerciseCompleted;
  int get totalExercise => _totalExercise;
  int get examCompleted => _examCompleted;
  int get totalExam => _totalExam;
  int get completed =>
      (_topicCompleted + _exerciseCompleted + _examCompleted) ~/
      (_totalTopic + _totalExercise + _totalExam) *
      100;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getProgress() async {
    // Simulate a network call
    await Future.delayed(const Duration(seconds: 2));
    _topicCompleted = 20; // Example data
    _exerciseCompleted = 30; // Example data
    _examCompleted = 10; // Example data
    _totalTopic = 50; // Example data
    _totalExercise = 50; // Example data
    _totalExam = 50; // Example data
    notifyListeners();
  }

  Future<void> getTopicProgress() async {
    isLoading = true;
    _topicCompleted = 0;
    _totalTopic = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    try {
      final uri = Uri.parse("${baseUrl}vocab-topics/for-user");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> topics = data['data']['data'];
        int doneCount =
            topics.where((topic) => topic['hasProgress'] == true).length;
        int total = data['data']['meta']['total'];
        _topicCompleted = doneCount;
        _totalTopic = total;
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load topics: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getExerciseProgress() async {
    _exerciseCompleted = 10;
    _totalExercise = 20;
    notifyListeners();
  }

  Future<void> getExamProgress() async {
    _examCompleted = 5;
    _totalExam = 10;
    notifyListeners();
  }

  Future<bool> createProgress(int lnaguageId) async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}progress"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "language_id": lnaguageId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:language_app/models/exam_model.dart';
import 'package:language_app/models/common_response.dart';
import 'package:language_app/models/exams/exam_overview.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:http/http.dart' as http;

class ExamProvider with ChangeNotifier {
  List<ExamModel> _exams = [];
  List<ExamModel> get exams => _exams;

  CommonResponse<ExamOverviewData>? examOverviewData;
  bool isLoading = false;
  String? errorMessage;

  final String baseUrl;
  final AuthProvider authProvider;

  ExamProvider({
    required this.baseUrl,
    required this.authProvider,
  });

  Future<void> fetchExamOverview() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = authProvider.token;

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('${baseUrl}exams/overview'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        examOverviewData = CommonResponse<ExamOverviewData>.fromJson(
          jsonData,
          (data) => ExamOverviewData.fromJson(data as Map<String, dynamic>),
        );

        print('Exam Overview: ${examOverviewData?.data.toString()}');
      } else {
        throw Exception('Server returned an error: ${response.statusCode}');
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double getCompletionPercentage(String examType) {
    if (examOverviewData == null) return 0.0;

    ExamTypeStats? stats;

    switch (examType) {
      case 'weeklyExams':
        stats = examOverviewData!.data.weeklyExams;
        break;
      case 'comprehensiveExams':
        stats = examOverviewData!.data.comprehensiveExams;
        break;
      case 'vocabGames':
        stats = examOverviewData!.data.vocabGames;
        break;
      default:
        return 0.0;
    }

    if (stats.total == 0) return 0.0;

    print(stats.completed);
    print(stats.total);

    return stats.completed / stats.total;
  }
}

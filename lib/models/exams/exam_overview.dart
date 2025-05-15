class ExamOverviewData {
  final ExamTypeStats weeklyExams;
  final ExamTypeStats comprehensiveExams;
  final ExamTypeStats vocabGames;

  ExamOverviewData({
    required this.weeklyExams,
    required this.comprehensiveExams,
    required this.vocabGames,
  });

  factory ExamOverviewData.fromJson(Map<String, dynamic> json) {
    return ExamOverviewData(
      weeklyExams: ExamTypeStats.fromJson(json['weeklyExams']),
      comprehensiveExams: ExamTypeStats.fromJson(json['comprehensiveExams']),
      vocabGames: ExamTypeStats.fromJson(json['vocabGames']),
    );
  }
}

class ExamTypeStats {
  final int total;
  final int completed;

  ExamTypeStats({
    required this.total,
    required this.completed,
  });

  factory ExamTypeStats.fromJson(Map<String, dynamic> json) {
    return ExamTypeStats(
      total: json['total'],
      completed: json['completed'],
    );
  }
}

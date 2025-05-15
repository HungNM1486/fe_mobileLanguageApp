class UserSessionModel {
  final int id;
  final DateTime loginTime;
  final DateTime? logoutTime;
  final DateTime createdAt;

  UserSessionModel({
    required this.id,
    required this.loginTime,
    this.logoutTime,
    required this.createdAt,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      id: json['id'],
      loginTime: DateTime.parse(json['loginTime']),
      logoutTime: json['logoutTime'] != null ? DateTime.parse(json['logoutTime']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class SessionStatisticItem {
  final String dayOrMonth;
  final double totalTime;

  SessionStatisticItem({
    required this.dayOrMonth,
    required this.totalTime,
  });

  factory SessionStatisticItem.fromJson(Map<String, dynamic> json) {
    return SessionStatisticItem(
      dayOrMonth: json['dayOrMonth'],
      totalTime: json['totalTime'].toDouble(),
    );
  }
}

class LoginStreakModel {
  final int currentStreak;
  final List<String> streakDates;

  LoginStreakModel({
    required this.currentStreak,
    required this.streakDates,
  });

  factory LoginStreakModel.fromJson(Map<String, dynamic> json) {
    return LoginStreakModel(
      currentStreak: json['currentStreak'],
      streakDates: List<String>.from(json['streakDates']),
    );
  }
}

class UserSessionOverview {
  final LoginStreakModel streak;
  final List<SessionStatisticItem> dailyData;
  final List<SessionStatisticItem> weeklyData;
  final List<SessionStatisticItem> monthlyData;
  final double totalStudyTime;

  UserSessionOverview({
    required this.streak,
    required this.dailyData,
    required this.weeklyData,
    required this.monthlyData,
    required this.totalStudyTime,
  });

  factory UserSessionOverview.fromJson(Map<String, dynamic> json) {
    return UserSessionOverview(
      streak: LoginStreakModel.fromJson(json['streak']),
      dailyData: (json['dailyData'] as List)
          .map((item) => SessionStatisticItem.fromJson(item))
          .toList(),
      weeklyData: (json['weeklyData'] as List)
          .map((item) => SessionStatisticItem.fromJson(item))
          .toList(),
      monthlyData: (json['monthlyData'] as List)
          .map((item) => SessionStatisticItem.fromJson(item))
          .toList(),
      totalStudyTime: json['totalStudyTime'].toDouble(),
    );
  }
}
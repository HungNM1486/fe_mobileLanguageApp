import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/models/achievement_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementProvider with ChangeNotifier {
  String baseUrl = "${UrlUtils.getBaseUrl()}achievements/";
  bool _isLoading = false;
  List<AchievementModel> _achievements = [];

  bool get isLoading => _isLoading;
  List<AchievementModel> get achievements => _achievements;

  Future<bool> getUserAchievements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.get(
        Uri.parse("${baseUrl}user-achievements"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final achievementsData = data['data'];
        
        _achievements = (achievementsData as List)
            .map((item) => AchievementModel.fromJson(item))
            .toList();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Lỗi khi gọi API achievement: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getAllAchievements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.get(
        Uri.parse("${baseUrl}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final achievementsData = data['data'];
        
        // Lấy tất cả thành tựu
        final List<AchievementModel> allAchievements = (achievementsData as List)
            .map((item) => AchievementModel.fromJson(item))
            .toList();

        // Gọi API để lấy các thành tựu đã mở khóa
        final userAchievementsResponse = await http.get(
          Uri.parse("${baseUrl}user-achievements"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
        );

        if (userAchievementsResponse.statusCode == 200) {
          final userAchievementsData = json.decode(userAchievementsResponse.body);
          final userAchievements = userAchievementsData['data'] as List;
          
          // Đánh dấu những thành tựu đã mở khóa
          for (var achievement in allAchievements) {
            final unlockedAchievement = userAchievements.firstWhere(
              (a) => a['achievement']['id'] == achievement.id,
              orElse: () => null
            );
            
            if (unlockedAchievement != null) {
              achievement = AchievementModel(
                id: achievement.id,
                title: achievement.title,
                description: achievement.description,
                badgeImageUrl: achievement.badgeImageUrl,
                triggerCondition: achievement.triggerCondition,
                conditionValue: achievement.conditionValue,
                unlockedAt: DateTime.parse(unlockedAchievement['unlockedAt']),
                isUnlocked: true,
              );
            }
          }
          
          _achievements = allAchievements;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Lỗi khi gọi API achievement: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
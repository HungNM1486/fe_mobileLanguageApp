import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/models/user_session_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionProvider with ChangeNotifier {
  String baseUrl = "${UrlUtils.getBaseUrl()}user-session/";
  bool _isLoading = false;
  int? _currentSessionId;
  LoginStreakModel? _loginStreak;
  List<SessionStatisticItem> _dailyData = [];
  List<SessionStatisticItem> _weeklyData = [];
  List<SessionStatisticItem> _monthlyData = [];
  double _totalStudyTime = 0;
  UserSessionOverview? _overview;

  bool get isLoading => _isLoading;
  int? get currentSessionId => _currentSessionId;
  LoginStreakModel? get loginStreak => _loginStreak;
  List<SessionStatisticItem> get dailyData => _dailyData;
  List<SessionStatisticItem> get weeklyData => _weeklyData;
  List<SessionStatisticItem> get monthlyData => _monthlyData;
  double get totalStudyTime => _totalStudyTime;
  UserSessionOverview? get overview => _overview;

  // Tạo phiên học tập mới
  Future<bool> createSession() async {
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
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _currentSessionId = data['data']['id'];
        
        // Lưu ID phiên hiện tại vào SharedPreferences
        await prefs.setInt('current_session_id', _currentSessionId!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Lỗi khi tạo phiên học tập: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cập nhật thời gian đăng xuất
  Future<bool> updateLogoutTime(int sessionId) async {
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
      
      final response = await http.patch(
        Uri.parse("$baseUrl$sessionId/logout"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        // Xóa ID phiên hiện tại khỏi SharedPreferences
        await prefs.remove('current_session_id');
        _currentSessionId = null;
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Lỗi khi cập nhật thời gian đăng xuất: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy thống kê theo ngày
  Future<bool> getDailyStatistics() async {
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
        Uri.parse("${baseUrl}statistics/daily"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _dailyData = (data['data'] as List)
            .map((item) => SessionStatisticItem.fromJson(item))
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
      print("Lỗi khi lấy thống kê theo ngày: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy thống kê theo tuần
  Future<bool> getWeeklyStatistics() async {
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
        Uri.parse("${baseUrl}statistics/weekly"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _weeklyData = (data['data'] as List)
            .map((item) => SessionStatisticItem.fromJson(item))
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
      print("Lỗi khi lấy thống kê theo tuần: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy thống kê theo tháng
  Future<bool> getMonthlyStatistics() async {
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
        Uri.parse("${baseUrl}statistics/monthly"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _monthlyData = (data['data'] as List)
            .map((item) => SessionStatisticItem.fromJson(item))
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
      print("Lỗi khi lấy thống kê theo tháng: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy thông tin streak
  Future<bool> getLoginStreak() async {
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
        Uri.parse("${baseUrl}login-streak"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _loginStreak = LoginStreakModel.fromJson(data['data']);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Lỗi khi lấy thông tin streak: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy tổng quan học tập
  Future<bool> getOverview() async {
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
        Uri.parse("${baseUrl}overview"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _overview = UserSessionOverview.fromJson(data['data']);
        
        // Cập nhật các thuộc tính riêng lẻ cho tiện sử dụng
        _loginStreak = _overview!.streak;
        _dailyData = _overview!.dailyData;
        _weeklyData = _overview!.weeklyData;
        _monthlyData = _overview!.monthlyData;
        _totalStudyTime = _overview!.totalStudyTime;
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Lỗi khi lấy tổng quan học tập: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Kiểm tra và quản lý phiên học tập
  Future<void> checkAndManageSession() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSessionId = prefs.getInt('current_session_id');
    
    if (currentSessionId != null) {
      // Đã có phiên đang hoạt động, cập nhật biến nội bộ
      _currentSessionId = currentSessionId;
    } else {
      // Chưa có phiên, tạo phiên mới
      await createSession();
    }
    
    // Tải dữ liệu tổng quan
    await getOverview();
  }

  // Đóng phiên khi người dùng đăng xuất
  Future<void> closeSessionOnLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSessionId = prefs.getInt('current_session_id');
    
    if (currentSessionId != null) {
      await updateLogoutTime(currentSessionId);
    }
  }
}
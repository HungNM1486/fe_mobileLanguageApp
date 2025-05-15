import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/models/language_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  final String baseUrl = "${UrlUtils.getBaseUrl()}languages/";

  // Lấy token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Tạo headers với token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // Lấy danh sách ngôn ngữ
  Future<List<LanguageModel>> getAllLanguages() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data']['data'] as List)
            .map((item) => LanguageModel.fromJson(item))
            .toList();
      } else {
        debugPrint('Không thể lấy danh sách ngôn ngữ: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách ngôn ngữ: $e');
      return [];
    }
  }

  // Lấy thông tin ngôn ngữ theo mã
  Future<LanguageModel?> getLanguageByCode(String code) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${baseUrl}code/$code'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LanguageModel.fromJson(data['data']);
      } else {
        debugPrint('Không thể lấy thông tin ngôn ngữ: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy thông tin ngôn ngữ: $e');
      return null;
    }
  }

  // Lấy thông tin ngôn ngữ theo ID
  Future<LanguageModel?> getLanguageById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LanguageModel.fromJson(data['data']);
      } else {
        debugPrint('Không thể lấy thông tin ngôn ngữ: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy thông tin ngôn ngữ: $e');
      return null;
    }
  }
}

// Dữ liệu ngôn ngữ cũ giữ lại để tránh lỗi với các phần khác của ứng dụng
Map<String, String> languageData = {
  "@@locale": "vi",
  "settings": "Cài đặt",
  "language": "Ngôn ngữ",
  "selectAppLanguage": "Chọn ngôn ngữ ứng dụng",
  "profileInfo": "Thông tin hồ sơ",
  "logout": "Đăng xuất",
  "courses": "Khóa học",
  "learningGoals": "Mục tiêu học tập",
  "theme": "Chủ đề",
  "sound": "Âm thanh",
  "notifications": "Thông báo",
  "support": "Hỗ trợ",
  "about": "Thông tin ứng dụng",
  "areYouSureLogout": "Bạn có chắc muốn đăng xuất?",
  "cancel": "Hủy",
  "agree": "Đồng ý",
  "avatar": "Ảnh đại diện",
  "forgotPassword": "Quên mật khẩu?",
  "username": "Tên người dùng",
  "signup": "Đăng ký",
  "or": "Hoặc",
  "loginName": "Tên đăng nhập",
  "password": "Mật khẩu",
  "login": "Đăng nhập",
  "email": "Email",
  "deleteAccount": "Xóa tài khoản",
  "enterYourEmail": "Nhập email của bạn",
  "addCourse": "Thêm khóa học",
  "removeCourse": "Xóa khóa học",
  "goalsUnderDevelopment": "Trang cài đặt mục tiêu học tập (đang phát triển)",
  "themeUnderDevelopment": "Trang cài đặt chủ đề (đang phát triển)",
  "soundUnderDevelopment": "Trang cài đặt âm thanh (đang phát triển)",
  "notificationsUnderDevelopment": "Trang cài đặt thông báo (đang phát triển)",
  "supportUnderDevelopment": "Trang hỗ trợ (đang phát triển)",
  "aboutUnderDevelopment": "Trang thông tin ứng dụng (đang phát triển)",
  "noAccount": "Bạn chưa có tài khoản?",
  "developmentTeamInfo": "Thông tin nhóm phát triển",
  "contactSupport": "Liên hệ hỗ trợ",
  "introduction": "Giới thiệu",
  "developmentTeam": "Nhóm phát triển",
  "contact": "Liên hệ",
  "saveChanges": "Lưu thay đổi",
  "deleteConfirmation":
      "Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.",
  "courseNotifications": "Thông báo khóa học",
  "courseNotificationsDesc": "Nhận thông báo về tiến độ và cập nhật khóa học.",
  "reminderNotifications": "Nhắc nhở học tập",
  "reminderNotificationsDesc": "Nhận nhắc nhở để duy trì thói quen học tập.",
  "updateNotifications": "Cập nhật ứng dụng",
  "updateNotificationsDesc": "Nhận thông báo khi có phiên bản mới.",
  "selectTheme": "Chọn giao diện",
  "light": "Sáng",
  "dark": "Tối",
  "system": "Theo hệ thống",
  "themeSaved": "Đã lưu cài đặt giao diện",
  "selectGoal": "Chọn mục tiêu học tập",
  "basic": "Cơ bản",
  "basicDesc": "Học các kỹ năng cơ bản, phù hợp cho người mới bắt đầu.",
  "advanced": "Nâng cao",
  "advancedDesc":
      "Phát triển kỹ năng chuyên sâu, dành cho người đã có nền tảng.",
  "expert": "Chuyên gia",
  "expertDesc": "Đạt trình độ cao cấp, phù hợp với người muốn thành thạo.",
  "continueButton": "Tiếp tục",
  "goalTime": "Thời gian hoàn thành mục tiêu",
  "selectGoalTime": "Chọn thời gian hoàn thành mục tiêu",
  "oneMonth": "1 tháng",
  "oneMonthDesc": "Hoàn thành mục tiêu trong thời gian ngắn và tập trung.",
  "threeMonths": "3 tháng",
  "threeMonthsDesc": "Tiến độ cân bằng để đạt được mục tiêu học tập.",
  "sixMonths": "6 tháng",
  "sixMonthsDesc": "Thời gian dài hơn để thành thạo hoàn toàn.",
  "goalTimeSaved": "Đã lưu thời gian hoàn thành mục tiêu",
  "selectStudyTime": "Chọn thời gian học",
  "breakfast": "Khi ăn sáng",
  "commuting": "Khi di chuyển",
  "lunch": "Khi ăn trưa",
  "dinner": "Khi ăn tối",
  "studyTimeSaved": "Đã lưu thời gian học",
  "goalCompletion": "Hoàn thành đặt mục tiêu",
  "congratulations": "Chúc mừng!",
  "goalSetSuccess": "Bạn đã đặt mục tiêu học tập thành công.",
  "goalOverview": "Tổng quan mục tiêu",
  "goalLabel": "Mục tiêu",
  "timeLabel": "Thời gian hoàn thành",
  "studyTimeLabel": "Thời gian học",
  "finishButton": "Hoàn tất",
  "activity": "Hoạt động",
  "activityOverview": "Tổng quan hoạt động",
  "studyTime": "Thời gian học",
  "totalStudyTime": "Tổng thời gian học",
  "totalCourses": "Tổng số khóa học",
  "community": "Cộng đồng học tập",
  "noPosts": "Chưa có bài viết nào",
  "createPost": "Viết bài",
  "postTitle": "Tiêu đề",
  "postContent": "Nội dung",
  "submitPost": "Đăng bài",
  "likes": "Lượt thích",
  "comments": "Bình luận",
  "addComment": "Thêm bình luận"
};

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:language_app/models/report_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportProvider with ChangeNotifier {
  final String baseUrl = UrlUtils.getBaseUrl();
  List<ReportModel> _reports = [];
  ReportModel? _reportDetail;
  bool _isLoading = false;
  bool _isAdmin = false; // Để kiểm soát quyền admin

  List<ReportModel> get reports => _reports;
  ReportModel? get reportDetail => _reportDetail;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;

  final Dio _dio = Dio()
    ..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

  // Kiểm tra quyền admin
  Future<bool> checkAdminPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString("userRole");
    _isAdmin = userRole == 'admin';
    return _isAdmin;
  }

  // Lấy danh sách tất cả báo cáo (chỉ dành cho admin)
  Future<bool> fetchAllReports({int page = 1, int limit = 10}) async {
    await checkAdminPermission();
    if (!_isAdmin) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}post-reports?page=$page&limit=$limit");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> reportsData = data['data']['data'];

        _reports = reportsData
            .map((e) {
              try {
                return ReportModel.fromJson(e);
              } catch (parseError) {
                debugPrint('Lỗi khi phân tích báo cáo: $parseError');
                return null;
              }
            })
            .whereType<ReportModel>()
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
      debugPrint('Error fetching all reports: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy báo cáo của người dùng hiện tại
  Future<bool> fetchMyReports({int page = 1, int limit = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
          "${baseUrl}post-reports/my-reports?page=$page&limit=$limit");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> reportsData = data['data']['data'];

        _reports = reportsData
            .map((e) {
              try {
                return ReportModel.fromJson(e);
              } catch (parseError) {
                debugPrint('Lỗi khi phân tích báo cáo: $parseError');
                return null;
              }
            })
            .whereType<ReportModel>()
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
      debugPrint('Error fetching my reports: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy báo cáo theo bài viết (admin only)
  Future<bool> fetchReportsByPostId(int postId) async {
    await checkAdminPermission();
    if (!_isAdmin) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}post-reports/post/$postId");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> reportsData = data['data'];

        _reports = reportsData
            .map((e) {
              try {
                return ReportModel.fromJson(e);
              } catch (parseError) {
                debugPrint('Lỗi khi phân tích báo cáo: $parseError');
                return null;
              }
            })
            .whereType<ReportModel>()
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
      debugPrint('Error fetching reports by post ID: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy chi tiết báo cáo (admin only)
  Future<bool> getReportDetail(int reportId) async {
    await checkAdminPermission();
    if (!_isAdmin) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${baseUrl}post-reports/$reportId");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _reportDetail = ReportModel.fromJson(data['data']);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching report detail: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Báo cáo bài viết
  Future<bool> createReport({
    required int postId,
    required String reason,
    String? description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    try {
      final response = await _dio.post(
        '${baseUrl}post-reports',
        data: {
          'postId': postId,
          'reason': reason,
          'description': description,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Thêm báo cáo mới vào danh sách nếu cần
        final newReportData = response.data['data'];
        if (newReportData != null) {
          final newReport = ReportModel.fromJson(newReportData);
          _reports.add(newReport);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating report: $e');
      return false;
    }
  }

  // Cập nhật trạng thái báo cáo (admin only)
  Future<bool> updateReportStatus(int reportId, bool isResolved) async {
    await checkAdminPermission();
    if (!_isAdmin) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    try {
      final response = await _dio.patch(
        '${baseUrl}post-reports/$reportId',
        data: {
          'isResolved': isResolved,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Cập nhật báo cáo trong danh sách
        final index = _reports.indexWhere((r) => r.id == reportId.toString());
        if (index != -1) {
          _reports[index].isResolved = isResolved;
        }

        // Cập nhật chi tiết báo cáo nếu đang xem
        if (_reportDetail?.id == reportId.toString()) {
          _reportDetail!.isResolved = isResolved;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating report status: $e');
      return false;
    }
  }

  // Xóa báo cáo (admin only)
  Future<bool> deleteReport(int reportId) async {
    await checkAdminPermission();
    if (!_isAdmin) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }

    try {
      final response = await _dio.delete(
        '${baseUrl}post-reports/$reportId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Xóa báo cáo khỏi danh sách
        _reports.removeWhere((r) => r.id == reportId.toString());
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting report: $e');
      return false;
    }
  }
}

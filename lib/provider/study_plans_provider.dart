import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/utils/baseurl.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/auth_provider.dart';

class StudyPlan {
  final int id;
  final String level;
  final int completionTimeMonths;
  final String studyTimeSlot;

  StudyPlan({
    required this.id,
    required this.level,
    required this.completionTimeMonths,
    required this.studyTimeSlot,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      id: json['id'],
      level: json['level'],
      completionTimeMonths: json['completionTimeMonths'],
      studyTimeSlot: json['studyTimeSlot'],
    );
  }
}

class StudyPlansProvider with ChangeNotifier {
  StudyPlan? _studyPlan;
  bool _isLoading = false;
  String? _errorMessage;

  StudyPlan? get studyPlan => _studyPlan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Base URL for the API
  static final String _baseUrl = '${UrlUtils.getBaseUrl()}study-plans';

  // Create a new study plan
  Future<void> createStudyPlan({
    required String level,
    required int completionTimeMonths,
    required String studyTimeSlot,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        _errorMessage = 'Vui lòng đăng nhập để tạo kế hoạch học tập';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'level': level,
          'completionTimeMonths': completionTimeMonths,
          'studyTimeSlot': studyTimeSlot,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body)['data'];
        _studyPlan = StudyPlan.fromJson(data);
      } else {
        throw Exception('Không thể tạo kế hoạch học tập: ${response.body}');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch the current user's study plan
  Future<void> fetchStudyPlan(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        _errorMessage = 'Vui lòng đăng nhập để xem kế hoạch học tập';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data != null) {
          _studyPlan = StudyPlan.fromJson(data);
        } else {
          _studyPlan = null;
        }
      } else {
        throw Exception('Không thể lấy kế hoạch học tập: ${response.body}');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing study plan
  Future<void> updateStudyPlan({
    required int id,
    String? level,
    int? completionTimeMonths,
    String? studyTimeSlot,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        _errorMessage = 'Vui lòng đăng nhập để cập nhật kế hoạch học tập';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final body = {};
      if (level != null) body['level'] = level;
      if (completionTimeMonths != null) body['completionTimeMonths'] = completionTimeMonths;
      if (studyTimeSlot != null) body['studyTimeSlot'] = studyTimeSlot;

      final response = await http.patch(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        _studyPlan = StudyPlan.fromJson(data);
      } else {
        throw Exception('Không thể cập nhật kế hoạch học tập: ${response.body}');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a study plan
  Future<void> deleteStudyPlan(int id, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null) {
        _errorMessage = 'Vui lòng đăng nhập để xóa kế hoạch học tập';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _studyPlan = null;
      } else {
        throw Exception('Không thể xóa kế hoạch học tập: ${response.body}');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
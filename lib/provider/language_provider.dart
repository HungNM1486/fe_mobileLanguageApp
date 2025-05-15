import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:language_app/models/language_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String baseUrl = "${UrlUtils.getBaseUrl()}languages/";

  List<LanguageModel> _languages = [];
  LanguageModel? _selectedLanguage;
  LanguageModel? get selectedLanguage => _selectedLanguage;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<LanguageModel> get languages => _languages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Lấy danh sách ngôn ngữ
  Future<void> fetchLanguages() async {
    _isLoading = true;
    _languages = [];
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _languages = (data['data']['data'] as List)
            .map((item) => LanguageModel.fromJson(item))
            .toList();
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load languages: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

// Lấy ngôn ngữ người dùng chọn
  Future<void> fetchLanguageSelected(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}code/$code'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _selectedLanguage = LanguageModel.fromJson(data['data']);
        print("Selected Language: $_selectedLanguage");
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load language: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo ngôn ngữ mới với ảnh
  Future<bool> createLanguage({
    required String name,
    required String flagUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'flagUrl': flagUrl,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        _languages.add(LanguageModel.fromJson(data['data']));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error creating language: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cập nhật ngôn ngữ
  Future<bool> updateLanguage({
    required int id,
    String? name,
    String? flagUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (flagUrl != null) body['flagUrl'] = flagUrl;
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final updatedLanguage = LanguageModel.fromJson(data['data']);
        final index = _languages.indexWhere((lang) => lang.id == id.toString());
        if (index != -1) {
          _languages[index] = updatedLanguage;
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
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Xóa ngôn ngữ
  Future<bool> deleteLanguage(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Xóa ngôn ngữ khỏi danh sách cục bộ
        _languages.removeWhere((language) => language.id == id.toString());
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error deleting language: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

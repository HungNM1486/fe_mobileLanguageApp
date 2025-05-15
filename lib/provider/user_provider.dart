import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:language_app/models/user_model.dart';

class UserProvider with ChangeNotifier {
  String baseUrl = "${UrlUtils.getBaseUrl()}users/";
  UserModel? _user;
  bool _loading = false;

  UserModel? get user => _user;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<int> getUserInfo(BuildContext context) async {
    setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        setLoading(false);
        return -1;
      }

      final url = Uri.parse("${baseUrl}profile/"); // Đảm bảo endpoint đúng
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data'];
        _user = UserModel.fromJson(userData);

        notifyListeners();
        if (_user?.role == "admin") {
          return 2;
        }
        if (_user?.progress.length == 0) {
          return 0; // Chưa chọn ngôn ngữ
        } else {
          return 1; // Đã chọn ngôn ngữ
        }
      } else {
        print("❌ Lỗi tải thông tin người dùng: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    } finally {
      setLoading(false);
    }
    return -1;
  }

  Future<bool> updateUserProfile(
      {String? firstName,
      String? lastName,
      File? profileImage,
      String? language_selected}) async {
    setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        setLoading(false);
        return false;
      }

      // Xử lý dữ liệu form
      final formData = FormData();

      // Chỉ thêm các trường không null
      if (firstName != null) {
        formData.fields.add(MapEntry("first_name", firstName));
      }

      if (lastName != null) {
        formData.fields.add(MapEntry("last_name", lastName));
      }

      if (language_selected != null) {
        formData.fields.add(MapEntry("language_selected", language_selected));
      }

      // Xử lý upload file
      if (profileImage != null) {
        final fileName = profileImage.path.split('/').last;
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            profileImage.path,
            filename: fileName,
          ),
        ));
      }

      final dio = Dio();
      final response = await dio.patch(
        "${baseUrl}profile",
        data: formData,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        // Cập nhật đối tượng user trong provider
        final data = response.data;
        _user = UserModel.fromJson(data['data']);
        notifyListeners();
        return true;
      } else {
        print("❌ Lỗi cập nhật thông tin người dùng: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return false;
    } finally {
      setLoading(false);
    }
  }

  void fetchAchievements() {}
}
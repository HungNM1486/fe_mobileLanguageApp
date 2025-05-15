import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/provider/user_session_provider.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String baseUrl = "${UrlUtils.getBaseUrl()}auth/";
  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  String? get token => _token;

  Future<bool> login(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      _isLoading = false;

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _token = responseBody['data']['token'];

        // Save token to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        // Tạo phiên học tập mới
        await Provider.of<UserSessionProvider>(context, listen: false)
            .createSession();

        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}register/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
        }),
      );

      _isLoading = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cập nhật logout trong AuthProvider
  Future<void> logout(BuildContext context) async {
    // Đóng phiên học tập hiện tại
    await Provider.of<UserSessionProvider>(context, listen: false)
        .closeSessionOnLogout();

    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  // Check if user is logged in
  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
    return _token != null;
  }
}

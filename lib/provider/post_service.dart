import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/models/post_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  final String baseUrl = UrlUtils.getBaseUrl();

  // Lấy token từ SharedPreferences
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

  // Lấy tất cả các hashtag có trong hệ thống
  Future<List<String>> getAllTags() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${baseUrl}posts/hashtags');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] is List) {
          // Trả về danh sách tags theo bảng chữ cái từ backend
          return List<String>.from(data['data']);
        }
        return [];
      } else {
        debugPrint('Không thể lấy danh sách hashtag: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách hashtag: $e');
      return [];
    }
  }

  // Lấy bài viết theo hashtag với phân trang
  Future<Map<String, dynamic>> getPostsByTag(String tag,
      {int page = 1, int limit = 10}) async {
    try {
      final headers = await _getHeaders();
      final uri =
          Uri.parse('${baseUrl}posts/hashtags/$tag?page=$page&limit=$limit');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];

        // Phân tích dữ liệu posts và metadata
        List<PostModel> posts = [];
        Map<String, dynamic> meta = {};

        if (data['data'] is List) {
          posts = (data['data'] as List)
              .map((post) => PostModel.fromJson(post))
              .toList();
        }

        if (data['meta'] != null) {
          meta = data['meta'] as Map<String, dynamic>;
        }

        return {
          'posts': posts,
          'meta': meta,
        };
      } else {
        debugPrint(
            'Không thể lấy bài viết theo hashtag: ${response.statusCode}');
        return {
          'posts': <PostModel>[],
          'meta': {},
        };
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bài viết theo hashtag: $e');
      return {
        'posts': <PostModel>[],
        'meta': {},
      };
    }
  }

}

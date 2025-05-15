import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/models/post_model.dart';
import 'package:language_app/models/like_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  final String baseUrl = UrlUtils.getBaseUrl();

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

  // Lấy tất cả các hashtag
  Future<List<String>> getAllTags() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${baseUrl}posts/hashtags');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] is List) {
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

  // Tìm kiếm bài viết theo tiêu đề, nội dung hoặc tags
  Future<Map<String, dynamic>> searchPosts({
    String? title,
    String? content,
    String? tags,
    int? languageId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _getHeaders();

      // Xây dựng query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (title != null && title.isNotEmpty) {
        queryParams['title'] = title;
      }

      if (content != null && content.isNotEmpty) {
        queryParams['content'] = content;
      }

      if (tags != null && tags.isNotEmpty) {
        queryParams['tags'] = tags;
      }

      if (languageId != null) {
        queryParams['languageId'] = languageId.toString();
      }

      final uri =
          Uri.parse('${baseUrl}posts').replace(queryParameters: queryParams);

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
        debugPrint('Không thể tìm kiếm bài viết: ${response.statusCode}');
        return {
          'posts': <PostModel>[],
          'meta': {},
        };
      }
    } catch (e) {
      debugPrint('Lỗi khi tìm kiếm bài viết: $e');
      return {
        'posts': <PostModel>[],
        'meta': {},
      };
    }
  }

  // Lấy danh sách người đã thích bài viết
  Future<Map<String, dynamic>> getPostLikes(String postId,
      {int page = 1, int limit = 20}) async {
    try {
      final headers = await _getHeaders();

      final uri = Uri.parse(
          '${baseUrl}post-likes/post/${postId}/users?page=${page}&limit=${limit}');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        List<dynamic> users = [];
        Map<String, dynamic> meta = {};

        // Trường hợp API trả về trực tiếp danh sách người dùng
        if (responseData is List) {
          users = responseData.map((user) {
            return Map<String, dynamic>.from(user);
          }).toList();

          meta = {
            'totalItems': users.length,
            'currentPage': page,
            'totalPages': 1
          };
        }
        // Trường hợp API trả về cấu trúc có data và meta
        else if (responseData is Map) {
          if (responseData.containsKey('data')) {
            final data = responseData['data'];

            if (data is List) {
              users =
                  data.map((user) => Map<String, dynamic>.from(user)).toList();
            }

            if (responseData.containsKey('meta') &&
                responseData['meta'] is Map) {
              meta = Map<String, dynamic>.from(responseData['meta']);
            } else {
              meta = {
                'totalItems': users.length,
                'currentPage': page,
                'totalPages': 1
              };
            }
          }
        }

        return {
          'users': users,
          'meta': meta,
        };
      } else if (response.statusCode == 404) {
        return {
          'users': <dynamic>[],
          'meta': <String, dynamic>{},
        };
      } else {
        return {
          'users': <dynamic>[],
          'meta': <String, dynamic>{},
        };
      }
    } catch (e) {
      return {
        'users': <dynamic>[],
        'meta': <String, dynamic>{},
      };
    }
  }
}

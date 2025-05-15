import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:language_app/models/topic_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopicProvider with ChangeNotifier {
  String baseUrl = "${UrlUtils.getBaseUrl()}vocab-topics/";
  int _completed = 0;
  int _total = 0;
  int get completed => _completed;
  int get total => _total;

  List<TopicModel> _topics = [];
  bool _isLoading = false;

  // Getters
  List<TopicModel> get topics => _topics;
  bool get isLoading => _isLoading;

  // Lấy danh sách chủ đề
  Future<void> fetchTopics({String? languageId, int? level}) async {
    _isLoading = true;
    _topics = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      // Xây dựng query parameters
      Map<String, String> queryParams = {};
      if (languageId != null) queryParams['languageId'] = languageId.toString();
      if (level != null) queryParams['level'] = level.toString();

      // Xây dựng URL với query parameters
      final uri = Uri.parse("${baseUrl}for-user").replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> data2 = data['data']['data'];
        int doneCount =
            data2.where((topic) => topic['hasProgress'] == true).length;
        int total = data['data']['meta']['total'];
        _completed = doneCount;
        _total = total;
        _topics = (data['data']['data'] as List)
            .map((item) => TopicModel.fromJson(item))
            .toList();
        // print('Fetched topics: ${_topics[0]}');
        // print('Fetched topics count: ${_topics.length}');
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load topics: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo chủ đề mới với ảnh
  Future<bool> createTopic({
    required String topic,
    required int languageId,
    required int level,
    required String imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Gửi request với Dio và in thêm thông tin
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'topic': topic,
          'languageId': languageId,
          'level': level,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        _topics.add(TopicModel.fromJson(data['data']));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error creating topic: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cập nhật chủ đề
  Future<bool> updateTopic({
    required String id,
    String? topic,
    int? languageId,
    int? level,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;
    Map<String, dynamic> body = {};
    if (topic != null) body['topic'] = topic;
    if (languageId != null) body['languageId'] = languageId;
    if (level != null) body['level'] = level;
    if (imageUrl != null) body['imageUrl'] = imageUrl;
    _isLoading = true;
    notifyListeners();

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
        final updated = TopicModel.fromJson(data['data']);
        final index = _topics.indexWhere((lang) => lang.id == id.toString());
        if (index != -1) {
          _topics[index] = updated;
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

  // Xóa chủ đề
  Future<bool> deleteTopic(String id) async {
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
        // Xóa chủ đề khỏi danh sách cục bộ
        _topics.removeWhere((topic) => topic.id == id);
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
}

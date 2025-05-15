import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:language_app/models/vocabulary_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VocabularyProvider with ChangeNotifier {
  String baseUrl = UrlUtils.getBaseUrl();
  List<VocabularyModel> _vocabularies = [];
  bool _isLoading = false;
  // Getters
  List<VocabularyModel> get vocabularies => _vocabularies;
  bool get isLoading => _isLoading;

  // Lấy tất cả từ vựng
  Future<void> fetchVocabularies({String? topicId, String? difficulty}) async {
    _isLoading = true;
    _vocabularies = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      Map<String, String> queryParams = {};
      if (topicId != null) queryParams['topicId'] = topicId;
      if (difficulty != null) queryParams['difficulty'] = difficulty;

      final uri = Uri.parse("${baseUrl}vocabs").replace(
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
        _vocabularies = (data['data']['data'] as List)
            .map((item) => VocabularyModel.fromJson(item))
            .toList();
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load vocabularies: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> initVocabByTopic(int topicId) async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final uri = Uri.parse("${baseUrl}vocab-repetitions/initialize/$topicId");
      final response = await http.post(
        Uri.parse('$uri'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        return true;
      } else {
        _isLoading = false;
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy từ vựng theo chủ đề
  Future<void> fetchVocabulariesByTopic(int topicId, bool isDone) async {
    _isLoading = true;
    _vocabularies = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (!isDone) {
      await initVocabByTopic(topicId);
    }

    try {
      final uri = Uri.parse("${baseUrl}vocab-repetitions/review/$topicId");
      final response = await http.get(
        Uri.parse('$uri'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        List<VocabularyModel> vocabularies = (data['data'] as List)
            .map((item) => VocabularyModel.fromJson(item))
            .toList();
        _vocabularies = vocabularies;
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchVocabRandom() async {
    _isLoading = true;
    _vocabularies = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final uri = Uri.parse("${baseUrl}vocabs/random");
      final response = await http.get(
        Uri.parse('$uri'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        List<VocabularyModel> vocabularies = (data['data'] as List)
            .map((item) => VocabularyModel.fromJson(item))
            .toList();
        _vocabularies = vocabularies;
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

  Future<bool> searchVocab(String key) async {
    _isLoading = true;
    _vocabularies = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final uri = Uri.parse("${baseUrl}vocabs/search")
          .replace(queryParameters: {'keyword': key});

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        List<VocabularyModel> vocabularies = (data['data'] as List)
            .map((item) => VocabularyModel.fromJson(item))
            .toList();

        _vocabularies = vocabularies;
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

  // Thêm từ vựng mới
  Future<bool> createVocabulary({
    required String word,
    required String definition,
    required String example,
    required String exampleTranslation,
    required String topicId,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}vocabs"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'word': word,
          'definition': definition,
          'example': example,
          'exampleTranslation': exampleTranslation,
          'topicId': int.parse(topicId),
          'imageUrl': imageUrl ?? '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final newVocabulary = VocabularyModel.fromJson(data['data']);
        _vocabularies.add(newVocabulary);
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

  // Cập nhật từ vựng
  Future<bool> updateVocabulary({
    required String id,
    String? word,
    String? definition,
    String? example,
    String? exampleTranslation,
    String? topicId,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> updateData = {};
      if (word != null) updateData['word'] = word;
      if (definition != null) updateData['definition'] = definition;
      if (example != null) updateData['example'] = example;
      if (exampleTranslation != null)
        updateData['exampleTranslation'] = exampleTranslation;
      if (topicId != null) updateData['topicId'] = topicId;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;

      final response = await http.put(
        Uri.parse('$baseUrl$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final updatedVocabulary = VocabularyModel.fromJson(data['data']);

        // Cập nhật item trong danh sách
        final index = _vocabularies.indexWhere((v) => v.id.toString() == id);
        if (index != -1) {
          _vocabularies[index] = updatedVocabulary;
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

  // Xóa từ vựng
  Future<bool> deleteVocabulary(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('${baseUrl}vocabs/$id');
      print(uri);
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Xóa từ vựng khỏi danh sách cục bộ
        _vocabularies
            .removeWhere((vocabulary) => vocabulary.id.toString() == id);
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

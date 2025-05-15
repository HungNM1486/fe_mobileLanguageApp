import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class ApiService {
  final String baseUrl = UrlUtils.getBaseUrl();

  // Get the authorization token from shared preferences
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        debugPrint('No token found in shared preferences');
      }
      return token;
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  // Get headers with authorization token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Handle API response with improved error reporting
  dynamic _handleResponse(http.Response response) {
    debugPrint(
        'API Response Status: ${response.statusCode}, Body length: ${response.body.length}');

    if (response.body.isEmpty) {
      debugPrint('Empty response body');
      throw Exception('Empty response from server');
    }

    try {
      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final errorMessage = responseData['message'] ?? 'Unknown error';
        debugPrint('API Error: $errorMessage');
        throw Exception('API Error: $errorMessage');
      }
    } catch (e) {
      debugPrint('Error parsing response: $e');
      throw Exception('Failed to parse response: $e');
    }
  }

  // Get all notifications with pagination
  Future<Map<String, dynamic>?> getNotifications(
      {int page = 1, int limit = 20}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${baseUrl}notifications?page=$page&limit=$limit');

      debugPrint('Fetching notifications from: $uri');
      final response = await http.get(uri, headers: headers);

      debugPrint('Notifications response code: ${response.statusCode}');
      if (response.statusCode == 204) {
        debugPrint('No notifications content (204)');
        return {
          'data': [],
          'meta': {'totalPages': 1, 'total': 0}
        };
      }

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      // Return a safe default value instead of throwing
      return {
        'data': [],
        'meta': {'totalPages': 1, 'total': 0}
      };
    }
  }

  // Get count of unread notifications
  Future<int> getUnreadNotificationCount() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${baseUrl}notifications/unread-count');

      debugPrint('Fetching unread count from: $uri');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 204) {
        debugPrint('No content for unread count (204)');
        return 0;
      }

      final data = _handleResponse(response);
      final count = data['data']['count'] ?? 0;
      debugPrint('Unread count: $count');
      return count;
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
      return 0; // Return 0 in case of error
    }
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${baseUrl}notifications/$notificationId/read');

      debugPrint('Marking notification $notificationId as read at: $uri');
      final response = await http.patch(uri, headers: headers);

      _handleResponse(response);
      debugPrint('Successfully marked notification $notificationId as read');
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${baseUrl}notifications/read-all');

      debugPrint('Marking all notifications as read at: $uri');
      final response = await http.patch(uri, headers: headers);

      _handleResponse(response);
      debugPrint('Successfully marked all notifications as read');
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Get new notifications since a specified date
  Future<List<NotificationModel>> getNewNotifications(DateTime since) async {
    try {
      final headers = await _getHeaders();

      // Format date for the API (ISO 8601 format)
      final formattedDate = since.toIso8601String();
      final uri = Uri.parse('${baseUrl}notifications?since=$formattedDate');

      debugPrint('Fetching new notifications since $formattedDate from: $uri');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 204) {
        debugPrint('No new notifications found (204)');
        return [];
      }

      final data = _handleResponse(response);

      // Parse notifications from the response
      List<NotificationModel> notifications = [];
      if (data['data'] != null && data['data'] is List) {
        notifications = (data['data'] as List)
            .map((notificationData) =>
                NotificationModel.fromJson(notificationData))
            .toList();
        debugPrint('Found ${notifications.length} new notifications');
      }

      return notifications;
    } catch (e) {
      debugPrint('Error fetching new notifications: $e');
      return []; // Return empty list in case of error
    }
  }
}

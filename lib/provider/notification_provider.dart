import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:language_app/models/notification_model.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  String baseUrl = UrlUtils.getBaseUrl();
  bool _isLoading = false;
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;
  NotificationModel? _notificationModel;
  List<NotificationModel> _notificationList = [];
  List<NotificationModel> get getNotificationList => _notificationList;
  bool get loading => _isLoading;
  NotificationModel? get Notification => _notificationModel;

  Future<bool> getListNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    _notificationList = [];
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _notificationList = (data['data']['data'] as List)
            .map((item) => NotificationModel.fromJson(item))
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
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching notifications: $e');
      return false;
    }
  }

  Future<bool> markNotificationAsRead(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${baseUrl}notifications/$id/read');
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        _notificationList = _notificationList.map((notification) {
          if (notification.id == id) {
            return NotificationModel(
              id: notification.id,
              title: notification.title,
              content: notification.content,
              createdAt: notification.createdAt,
              isRead: true,
              type: notification.type,
              data: notification.data,
            );
          }
          return notification;
        }).toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAll() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${baseUrl}notifications/read-all');
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        _notificationList = _notificationList.map((notification) {
          return NotificationModel(
            id: notification.id,
            title: notification.title,
            content: notification.content,
            createdAt: notification.createdAt,
            isRead: true,
            type: notification.type,
            data: notification.data,
          );
        }).toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getNumberNewNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}notifications/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _unreadCount = data['data']['count'] ?? 0;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching unread notification count: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) {
      return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}notifications/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        _notificationList.removeWhere((notification) => notification.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

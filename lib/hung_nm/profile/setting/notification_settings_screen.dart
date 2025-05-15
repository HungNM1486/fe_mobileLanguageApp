import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _courseNotifications = true;
  bool _reminderNotifications = true;
  bool _updateNotifications = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Tải cài đặt từ SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _courseNotifications = prefs.getBool('course_notifications') ?? true;
      _reminderNotifications = prefs.getBool('reminder_notifications') ?? true;
      _updateNotifications = prefs.getBool('update_notifications') ?? false;
    });
  }

  // Lưu cài đặt và gửi thông báo kiểm tra
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('course_notifications', _courseNotifications);
    await prefs.setBool('reminder_notifications', _reminderNotifications);
    await prefs.setBool('update_notifications', _updateNotifications);

    // Gửi thông báo kiểm tra nếu bật
    if (_courseNotifications) {
      _scheduleNotification('Khóa học mới', 'Có một khóa học mới đang chờ bạn!');
    }
    if (_reminderNotifications) {
      _scheduleNotification('Nhắc nhở học tập', 'Đã đến giờ học, đừng bỏ lỡ!');
    }
    if (_updateNotifications) {
      _scheduleNotification('Cập nhật ứng dụng', 'Phiên bản mới đã sẵn sàng!');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cài đặt thông báo đã được lưu')),
    );
  }

  // Lên lịch thông báo
  Future<void> _scheduleNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id', // ID kênh
      'Language App Notifications', // Tên kênh
      channelDescription: 'Notifications for Language App', // Mô tả kênh
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // ID thông báo (có thể thay đổi để hiển thị nhiều thông báo)
      title,
      body,
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pix = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      appBar: AppBar(
        title: Text("Cài đặt thông báo"),
        backgroundColor: const Color(0xff5B7BFE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16 * pix),
        child: ListView(
          children: [
            Text(
              'Cài đặt thông báo',
              style: TextStyle(
                fontSize: 18 * pix,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.bold,
                color: const Color(0xff5B7BFE),
              ),
            ),
            SizedBox(height: 16 * pix),

            _buildNotificationSwitch(
              title: 'Thông báo khóa học',
              subtitle: 'Nhận thông báo về tiến độ và cập nhật khóa học.',
              value: _courseNotifications,
              onChanged: (value) {
                setState(() {
                  _courseNotifications = value;
                });
              },
              pix: pix,
            ),

            _buildNotificationSwitch(
              title: 'Nhắc nhở học tập',
              subtitle: 'Nhận nhắc nhở để duy trì thói quen học tập.',
              value: _reminderNotifications,
              onChanged: (value) {
                setState(() {
                  _reminderNotifications = value;
                });
              },
              pix: pix,
            ),

            _buildNotificationSwitch(
              title: 'Cập nhật ứng dụng',
              subtitle: 'Nhận thông báo khi có phiên bản mới.',
              value: _updateNotifications,
              onChanged: (value) {
                setState(() {
                  _updateNotifications = value;
                });
              },
              pix: pix,
            ),

            SizedBox(height: 24 * pix),

            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5B7BFE),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8 * pix)),
                padding: EdgeInsets.symmetric(vertical: 12 * pix),
              ),
              child: Text(
                'Lưu thay đổi',
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double pix,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16 * pix,
          fontFamily: 'BeVietnamPro',
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12 * pix,
          fontFamily: 'BeVietnamPro',
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xff5B7BFE),
      ),
    );
  }
}

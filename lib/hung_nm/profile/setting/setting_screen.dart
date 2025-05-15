import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/phu_nv/LoginSignup/login_screen.dart';
import 'language_settings_screen.dart';
import 'profile_settings_screen.dart';
import 'goal/goal_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'sound_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'support_screen.dart';
import 'about_screen.dart';
import 'widgets/logout_dialog.dart';
import 'package:language_app/widget/top_bar.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                child: Column(
                  children: [
                    SizedBox(height: 130 * pix),
                    _buildProfileSection(context, pix),
                    const SizedBox(height: 16),
                    _buildCoursesSection(context, pix),
                    const SizedBox(height: 16),
                    _buildAppearanceSection(context, pix),
                    const SizedBox(height: 16),
                    _buildSupportSection(context, pix),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(
              title: "Cài đặt",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double pix) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * pix, bottom: 8 * pix),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16 * pix,
          fontWeight: FontWeight.bold,
          color: const Color(0xff5B7BFE),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, double pix) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * pix)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16 * pix),
            child: Row(
              children: [
                Container(
                  width: 50 * pix,
                  height: 50 * pix,
                  decoration: BoxDecoration(
                    color: const Color(0xff5B7BFE).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 24 * pix,
                    color: const Color(0xff5B7BFE),
                  ),
                ),
                SizedBox(width: 12 * pix),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thông tin cá nhân",
                        style: TextStyle(
                          fontSize: 16 * pix,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4 * pix),
                      Text(
                        "Quản lý thông tin cá nhân",
                        style: TextStyle(
                          fontSize: 12 * pix,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.only(left: 4 * pix),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ProfileSettingsScreen()));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context,
            icon: Icons.logout,
            title: "Đăng xuất",
            color: Colors.red,
            onTap: () async {
              final confirm = await showLogoutDialog(context);
              if (confirm) {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Loginscreen()),
                  (route) => false,
                );
              }
            },
            pix: pix,
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(BuildContext context, double pix) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * pix)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12 * pix),
            child: _buildSectionTitle("Khóa học", pix),
          ),
          _buildSettingItem(
            context,
            icon: Icons.language,
            title: "Ngôn ngữ",
            subtitle: "Change application language",
            iconColor: Colors.green,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LanguageSettingsScreen()));
            },
            pix: pix,
          ),
          _buildSettingItem(
            context,
            icon: Icons.flag,
            title: "Mục tiêu học tập",
            subtitle: "Set and track your goals",
            iconColor: Colors.blue,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GoalSettingsScreen()));
            },
            pix: pix,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, double pix) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * pix)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12 * pix),
            child: _buildSectionTitle("Giao diện", pix),
          ),
          _buildSettingItem(
            context,
            icon: Icons.brightness_6,
            title: "Giao diện",
            subtitle: "Choose light or dark mode",
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ThemeSettingsScreen()));
            },
            pix: pix,
          ),
          _buildSettingItem(
            context,
            icon: Icons.volume_up,
            title: "Âm thanh",
            subtitle: "Adjust sound preferences",
            iconColor: Colors.red,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SoundSettingsScreen()));
            },
            pix: pix,
          ),
          _buildSettingItem(
            context,
            icon: Icons.notifications,
            title: "Thông báo",
            subtitle: "Quản lý thông báo",
            iconColor: Colors.amber,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const NotificationSettingsScreen()));
            },
            pix: pix,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context, double pix) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * pix)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12 * pix),
            child: _buildSectionTitle("Hỗ trợ", pix),
          ),
          _buildSettingItem(
            context,
            icon: Icons.help,
            title: "Hỗ trợ",
            subtitle: "Get help and support",
            iconColor: Colors.teal,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SupportScreen()));
            },
            pix: pix,
          ),
          _buildSettingItem(
            context,
            icon: Icons.info,
            title: "Giới thiệu",
            subtitle: "App information and version",
            iconColor: Colors.indigo,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
            pix: pix,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required void Function() onTap,
    required double pix,
    Color? color,
    Color? iconColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: showDivider
              ? null
              : BorderRadius.only(
                  bottomLeft: Radius.circular(16 * pix),
                  bottomRight: Radius.circular(16 * pix),
                ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * pix,
              vertical: 12 * pix,
            ),
            child: Row(
              children: [
                Container(
                  width: 40 * pix,
                  height: 40 * pix,
                  decoration: BoxDecoration(
                    color:
                        (iconColor ?? const Color(0xff5B7BFE)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10 * pix),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? color ?? const Color(0xff5B7BFE),
                    size: 20 * pix,
                  ),
                ),
                SizedBox(width: 16 * pix),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16 * pix,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2 * pix),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12 * pix,
                            color: Colors.grey[600],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16 * pix,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, indent: 72 * pix),
      ],
    );
  }
}

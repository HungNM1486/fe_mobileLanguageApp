import 'package:flutter/material.dart';
import 'package:language_app/phu_nv/Admin/language_screen.dart';
import 'package:language_app/phu_nv/Admin/topic_manager.dart';
import 'package:language_app/phu_nv/Admin/vocabulary_management_screen.dart';
import 'package:language_app/phu_nv/Admin/report_management_screen.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:language_app/utils/toast_helper.dart';
import 'package:language_app/phu_nv/home_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminPermission();
  }

  Future<void> _checkAdminPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.getUserInfo(context);

      if (userProvider.user == null || userProvider.user!.role != 'admin') {
        ToastHelper.showError(context, 'Bạn không có quyền truy cập trang này');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homescreen()),
        );
        return;
      }

      setState(() {
        _isAdmin = true;
        _isLoading = false;
      });
    } catch (e) {
      ToastHelper.showError(context, 'Đã xảy ra lỗi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Bạn không có quyền truy cập',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Homescreen()),
                  );
                },
                child: Text('Quay về trang chủ'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100 * pix,
                width: size.width,
                padding: EdgeInsets.only(top: 10 * pix),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xff43AAFF), Color(0xff5053FF)],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: size.width - 100 * pix,
                    height: 80 * pix,
                    padding: EdgeInsets.only(top: 30 * pix),
                    child: Text(
                      'Quản trị viên',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24 * pix,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'BeVietnamPro'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 48 * pix,
              right: 10 * pix,
              child: Container(
                width: 30 * pix,
                height: 30 * pix,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25 * pix),
                ),
                child: IconButton(
                  padding: EdgeInsets.only(
                    left: 5,
                  ),
                  icon: Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false)
                        .logout(context);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quản lý hệ thống",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý ngôn ngữ",
                      icon: Icons.language,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LanguageScreen(),
                          ),
                        );
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý chủ đề",
                      icon: Icons.topic,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopicScreen(),
                          ),
                        );
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý từ vựng",
                      icon: Icons.topic,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VocabularyManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý người dùng",
                      icon: Icons.people,
                      color: Colors.orange,
                      onTap: () {
                        // Navigator.push đến trang quản lý người dùng
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Thống kê hệ thống",
                      icon: Icons.bar_chart,
                      color: Colors.purple,
                      onTap: () {
                        // Navigator.push đến trang thống kê
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý thông báo",
                      icon: Icons.notifications,
                      color: Colors.red,
                      onTap: () {
                        // Navigator.push đến trang quản lý thông báo
                      },
                    ),
                    _buildAdminMenuItem(
                      context,
                      title: "Quản lý báo cáo",
                      icon: Icons.report_problem,
                      color: Colors.amber,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportManagementScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Nhấn để quản lý ${title.toLowerCase()}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

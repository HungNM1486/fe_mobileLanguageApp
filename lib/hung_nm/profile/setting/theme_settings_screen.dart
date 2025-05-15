import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen>
    with SingleTickerProviderStateMixin {
  late ThemeMode _selectedTheme;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadTheme();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'light';
    setState(() {
      _selectedTheme = _themeModeFromString(themeString);
    });
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeModeToString(mode));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu cài đặt giao diện'),
        backgroundColor: const Color(0xff5B7BFE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);

    return Scaffold(
      appBar: AppBar(
        title: Text("Giao diện"),
        backgroundColor: const Color(0xff5B7BFE),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: const AssetImage('assets/images/theme_background.png'),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: FadeTransition(
          opacity: _animation,
          child: Padding(
            padding: EdgeInsets.all(16 * pix),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn giao diện ứng dụng',
                  style: TextStyle(
                    fontSize: 20 * pix,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5B7BFE),
                  ),
                ),
                SizedBox(height: 8 * pix),
                Text(
                  'Lựa chọn chế độ hiển thị phù hợp với bạn',
                  style: TextStyle(
                    fontSize: 14 * pix,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30 * pix),
                _buildThemeCard(
                  'light',
                  'Sáng',
                  'Giao diện sáng, dễ nhìn vào ban ngày',
                  Icons.light_mode,
                  Colors.orange,
                  [
                    Colors.white,
                    Colors.grey[100]!,
                    Colors.grey[50]!,
                  ],
                  ThemeMode.light,
                  pix,
                ),
                SizedBox(height: 16 * pix),
                _buildThemeCard(
                  'dark',
                  'Tối',
                  'Giao diện tối, giảm mỏi mắt vào ban đêm',
                  Icons.dark_mode,
                  Colors.indigo,
                  [
                    const Color(0xFF1F1F1F),
                    const Color(0xFF292929),
                    const Color(0xFF383838),
                  ],
                  ThemeMode.dark,
                  pix,
                ),
                SizedBox(height: 16 * pix),
                _buildThemeCard(
                  'system',
                  'Theo hệ thống',
                  'Tự động thay đổi theo chế độ của thiết bị',
                  Icons.brightness_auto,
                  Colors.teal,
                  [
                    Colors.white,
                    const Color(0xFF292929),
                  ],
                  ThemeMode.system,
                  pix,
                ),
                const Spacer(),
                _buildCurrentThemeInfo(pix),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    String id,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    List<Color> previewColors,
    ThemeMode themeMode,
    double pix,
  ) {
    final isSelected = _selectedTheme == themeMode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = themeMode;
        });
        _saveTheme(themeMode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xff5B7BFE).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16 * pix),
          border: Border.all(
            color: isSelected ? const Color(0xff5B7BFE) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xff5B7BFE).withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16 * pix),
          child: Row(
            children: [
              Container(
                width: 56 * pix,
                height: 56 * pix,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28 * pix,
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
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xff5B7BFE)
                            : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4 * pix),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14 * pix,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 12 * pix),
                    Row(
                      children: id == 'system'
                          ? [
                              _buildColorPreview(previewColors[0], pix,
                                  size: 24),
                              Text(' / ',
                                  style: TextStyle(color: Colors.grey[400])),
                              _buildColorPreview(previewColors[1], pix,
                                  size: 24),
                            ]
                          : previewColors
                              .map((color) => _buildColorPreview(color, pix))
                              .toList(),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24 * pix,
                height: 24 * pix,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected ? const Color(0xff5B7BFE) : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xff5B7BFE)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16 * pix,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPreview(Color color, double pix, {double size = 18}) {
    return Container(
      width: size * pix,
      height: size * pix,
      margin: EdgeInsets.only(right: 8 * pix),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4 * pix),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildCurrentThemeInfo(double pix) {
    String themeName;
    switch (_selectedTheme) {
      case ThemeMode.light:
        themeName = 'Sáng';
        break;
      case ThemeMode.dark:
        themeName = 'Tối';
        break;
      case ThemeMode.system:
        themeName = 'Theo hệ thống';
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * pix),
            decoration: BoxDecoration(
              color: const Color(0xff5B7BFE).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: const Color(0xff5B7BFE),
              size: 20 * pix,
            ),
          ),
          SizedBox(width: 12 * pix),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giao diện hiện tại',
                style: TextStyle(
                  fontSize: 14 * pix,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4 * pix),
              Text(
                themeName,
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

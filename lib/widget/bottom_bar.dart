import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/test_screen.dart';
import 'package:language_app/hung_nm/profile/profile_sceen.dart';
import 'package:language_app/phu_nv/Vocab/vocabulary_select_screen.dart';
import 'package:language_app/phu_nv/home_screen.dart';
import 'package:language_app/hong_nm/exercise_screen.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/res/theme/app_colors.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key, required this.type});
  final int type;

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Container(
      height: 60 * pix, // Tăng chiều cao để chứa thêm nhãn
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền trắng
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Homescreen()),
              );
            },
            image: AppImages.iconhome,
            label: 'Home', // Thêm nhãn
            enabled: widget.type == 1,
          ),
          _buildActionButton(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const VocabularySelectScreen()),
              );
            },
            image: AppImages.iconvocabulary,
            label: 'Vocabulary', // Thêm nhãn
            enabled: widget.type == 2,
          ),
          _buildActionButton(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Exercisescreen()),
              );
            },
            image: AppImages.iconstudy,
            label: 'Study', // Thêm nhãn
            enabled: widget.type == 3,
          ),
          _buildActionButton(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TestScreen()),
              );
            },
            image: AppImages.icontest,
            label: 'Test', // Thêm nhãn
            enabled: widget.type == 4,
          ),
          _buildActionButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            image: AppImages.iconprofile,
            label: 'Profile', // Thêm nhãn
            enabled: widget.type == 5,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required String image,
    required String label,
    required bool enabled,
  }) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40 * pix,
            width: 40 * pix,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Image.asset(
                image,
                width: 24 * pix,
                height: 24 * pix,
                color: enabled
                    ? AppColors.primary
                    : Colors.grey, // Thay đổi màu icon khi active
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * pix,
              color: enabled
                  ? AppColors.primary
                  : Colors.grey, // Thay đổi màu nhãn khi active
              fontWeight: enabled ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

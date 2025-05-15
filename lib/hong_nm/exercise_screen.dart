import 'package:flutter/material.dart';
import 'package:language_app/hong_nm/level_screen.dart';
import 'package:language_app/provider/exercise_provider.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/bottom_bar.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class Exercisescreen extends StatefulWidget {
  const Exercisescreen({super.key});

  @override
  State<Exercisescreen> createState() => _ExercisescreenState();
}

class _ExercisescreenState extends State<Exercisescreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final exProvider = Provider.of<ExerciseProvider>(context, listen: false);
      exProvider.fetchProgress();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchProgress() async {
    setState(() {
      isLoading = true;
    });
    bool result = await Provider.of<ExerciseProvider>(context, listen: false)
        .fetchProgress();
    if (result) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi khi tải dữ liệu bài tập'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Consumer<ExerciseProvider>(builder: (context, exProvider, child) {
      if (exProvider.isLoading || isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      final List<Map<String, dynamic>> exerciseTypes = [
        {
          'title': 'Ngữ pháp',
          'subtitle': 'Luyện tập cấu trúc và quy tắc ngôn ngữ',
          'img': AppImages.searchdetail,
          'color': Color(0xFF4A6572),
          'cardColor': Color(0xFFF3F8FF),
          'icon': Icons.menu_book,
          'type': 'grammar',
          'completedLessons': exProvider.grammarExercises['completed'] ?? 0,
          'totalLessons': exProvider.grammarExercises['total'] ?? 0,
        },
        {
          'title': 'Nghe',
          'subtitle': 'Rèn luyện kỹ năng nghe và hiểu',
          'img': AppImages.listen,
          'color': Color(0xFF689F38),
          'cardColor': Color(0xFFF1F8E9),
          'icon': Icons.headset,
          'type': 'listening',
          'completedLessons': exProvider.listeningExercises['completed'] ?? 0,
          'totalLessons': exProvider.listeningExercises['total'] ?? 0,
        },
        {
          'title': 'Phát âm',
          'subtitle': 'Thực hành phát âm chuẩn xác',
          'img': AppImages.speak,
          'color': Color(0xFFEF6C00),
          'cardColor': Color(0xFFFFF3E0),
          'icon': Icons.mic,
          'type': 'speaking',
          'completedLessons': exProvider.speakingExercises['completed'] ?? 0,
          'totalLessons': exProvider.speakingExercises['total'] ?? 0,
        },
      ];

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade100, Colors.white],
              stops: const [0.0, 0.5],
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  TopBar(title: 'Bài tập', isBack: false),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 16 * pix,
                        right: 16 * pix,
                        top: 16 * pix,
                        bottom: 70 * pix, // Space for bottom bar
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome message
                          Container(
                            padding: EdgeInsets.all(16 * pix),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15 * pix),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50 * pix,
                                  height: 50 * pix,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    size: 28 * pix,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                SizedBox(width: 16 * pix),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Luyện tập hôm nay',
                                        style: TextStyle(
                                          fontSize: 18 * pix,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'BeVietnamPro',
                                        ),
                                      ),
                                      SizedBox(height: 4 * pix),
                                      Text(
                                        'Chọn lĩnh vực bạn muốn luyện tập',
                                        style: TextStyle(
                                          fontSize: 14 * pix,
                                          color: Colors.grey.shade700,
                                          fontFamily: 'BeVietnamPro',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24 * pix),

                          // Section title
                          Padding(
                            padding: EdgeInsets.only(
                              left: 4 * pix,
                            ),
                            child: Text(
                              'Chọn một lĩnh vực',
                              style: TextStyle(
                                fontSize: 16 * pix,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'BeVietnamPro',
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),

                          // Exercise types
                          Expanded(
                            child: ListView.builder(
                              itemCount: exerciseTypes.length,
                              itemBuilder: (context, index) {
                                final exercise = exerciseTypes[index];
                                return _buildExerciseCard(
                                  title: exercise['title'],
                                  subtitle: exercise['subtitle'],
                                  img: exercise['img'],
                                  icon: exercise['icon'],
                                  color: exercise['color'],
                                  cardColor: exercise['cardColor'],
                                  completedLessons:
                                      exercise['completedLessons'],
                                  totalLessons: exercise['totalLessons'],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Levelscreen(
                                          type: exercise['type'],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * pix),
                ],
              ),
              Positioned(
                bottom: 0 * pix,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: Bottombar(type: 3),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildExerciseCard({
    required String title,
    required String subtitle,
    required String img,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required int completedLessons,
    required int totalLessons,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    // Tính phần trăm tiến độ, đảm bảo không chia cho 0
    final double progressPercentage =
        totalLessons > 0 ? (completedLessons / totalLessons) : 0.0;

    // Tính chiều rộng thanh tiến độ
    final double progressWidth =
        totalLessons > 0 ? progressPercentage * (size.width - 32 * pix) : 0.0;

    // Tính phần trăm hiển thị
    final int displayPercentage =
        totalLessons > 0 ? (progressPercentage * 100).toInt() : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16 * pix),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * pix),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Upper part with image and text
            Container(
              padding: EdgeInsets.all(16 * pix),
              child: Row(
                children: [
                  // Image container
                  Container(
                    width: 100 * pix,
                    height: 100 * pix,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12 * pix),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            img,
                            height: 80 * pix,
                            width: 80 * pix,
                          ),
                        ),
                        Positioned(
                          top: 8 * pix,
                          right: 8 * pix,
                          child: Container(
                            padding: EdgeInsets.all(4 * pix),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 16 * pix,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 16 * pix),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18 * pix,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BeVietnamPro',
                            color: Colors.grey.shade900,
                          ),
                        ),
                        SizedBox(height: 4 * pix),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 12 * pix),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16 * pix,
                              color: color,
                            ),
                            SizedBox(width: 4 * pix),
                            Text(
                              '$completedLessons/$totalLessons bài học',
                              style: TextStyle(
                                fontSize: 13 * pix,
                                fontFamily: 'BeVietnamPro',
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * pix),
              margin: EdgeInsets.only(bottom: 16 * pix),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // Background
                      Container(
                        height: 6 * pix,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10 * pix),
                        ),
                      ),
                      // Progress
                      Container(
                        height: 6 * pix,
                        width: progressWidth,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10 * pix),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * pix),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiến độ: $displayPercentage%',
                        style: TextStyle(
                          fontSize: 12 * pix,
                          color: Colors.grey.shade600,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * pix,
                          vertical: 4 * pix,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12 * pix),
                        ),
                        child: Text(
                          totalLessons > 0 ? 'Tiếp tục' : 'Bắt đầu',
                          style: TextStyle(
                            fontSize: 12 * pix,
                            fontWeight: FontWeight.w600,
                            color: color,
                            fontFamily: 'BeVietnamPro',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

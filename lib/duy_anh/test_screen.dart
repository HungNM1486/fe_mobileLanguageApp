import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/exam/exam_screen.dart';
import 'package:language_app/duy_anh/question_game/questions_screen.dart';
import 'package:language_app/duy_anh/vocab_game/vocabulary_game_screen.dart';
import 'package:language_app/provider/exam_provider.dart';
import 'package:language_app/widget/bottom_bar.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
      Provider.of<ExamProvider>(context, listen: false).fetchExamOverview();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pix = (MediaQuery.of(context).size.width / 375).clamp(0.8, 1.2);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final examProvider = Provider.of<ExamProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
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
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopBar(
                  title: 'Kiểm tra',
                  isBack: false,
                )),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (examProvider.isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(20 * pix),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (examProvider.errorMessage != null)
                    Padding(
                      padding: EdgeInsets.all(20 * pix),
                      child: Text(
                        'Lỗi: ${examProvider.errorMessage}',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14 * pix,
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24 * pix, vertical: 24 * pix),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hành Trình Học Tập',
                                style: TextStyle(
                                  fontSize: 18 * pix,
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF1C2526),
                                ),
                              ),
                              SizedBox(width: 8 * pix),
                              Container(
                                height: 2 * pix,
                                width: 40 * pix,
                                color: isDarkMode
                                    ? Colors.grey[700]
                                    : const Color(0xFFE5E7EB),
                              ),
                            ],
                          ),
                          SizedBox(height: 8 * pix),
                          Text(
                            'Chọn một nhiệm vụ để nâng cao kỹ năng tiếng Anh',
                            style: TextStyle(
                              fontSize: 14 * pix,
                              fontFamily: 'BeVietnamPro',
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 24 * pix),
                          _buildTaskCard(
                            context: context,
                            icon: Icons.quiz,
                            title: 'Câu Đố Thích Ứng',
                            subtitle:
                                'Câu hỏi cá nhân hóa để kiểm tra kiến thức',
                            progress: examProvider
                                .getCompletionPercentage('weeklyExams'),
                            color: const Color(0xFF3B82F6), // Xanh dương
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const QuestionsScreen()),
                            ),
                            pix: pix,
                          ),
                          SizedBox(height: 16 * pix),
                          _buildTaskCard(
                            context: context,
                            icon: Icons.extension,
                            title: 'Luyện Từ Vựng',
                            subtitle: 'Trò chơi tương tác để nắm vững từ mới',
                            progress: examProvider
                                .getCompletionPercentage('vocabGames'),
                            color: const Color(0xFF10B981), // Xanh lá
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const VocabularyGameScreen()),
                            ),
                            pix: pix,
                          ),
                          SizedBox(height: 16 * pix),
                          _buildTaskCard(
                            context: context,
                            icon: Icons.analytics,
                            title: 'Đánh Giá Kỹ Năng',
                            subtitle:
                                'Bài kiểm tra toàn diện để đánh giá trình độ',
                            progress: examProvider
                                .getCompletionPercentage('comprehensiveExams'),
                            color: const Color(0xFFD97706), // Cam
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ExamScreen()),
                            ),
                            pix: pix,
                          ),
                          SizedBox(height: 32 * pix),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                  child: Bottombar(type: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required Color color,
    required double pix,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(20 * pix),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E2F) : Colors.white,
          borderRadius: BorderRadius.circular(16 * pix),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12 * pix),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24 * pix,
                    color: color,
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
                          fontSize: 18 * pix,
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1C2526),
                        ),
                      ),
                      SizedBox(height: 4 * pix),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14 * pix,
                          fontFamily: 'BeVietnamPro',
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18 * pix,
                  color: color,
                ),
              ],
            ),
            SizedBox(height: 16 * pix),
            LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  isDarkMode ? Colors.grey[700] : const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4 * pix,
            ),
          ],
        ),
      ),
    );
  }
}

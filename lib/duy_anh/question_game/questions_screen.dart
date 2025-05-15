import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/question_game/quiz_screen.dart';
import 'package:language_app/widget/top_bar.dart';

// Dữ liệu mẫu
final List<Map<String, dynamic>> weeks = [
  {'week': 'Tuần 1', 'description': 'Cơ bản về từ vựng', 'score': '8/10'},
  {'week': 'Tuần 2', 'description': 'Ngữ pháp cơ bản', 'score': null},
  {'week': 'Tuần 3', 'description': 'Đọc hiểu', 'score': '5/10'},
];

class QuestionsScreen extends StatelessWidget {
  const QuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pix = (MediaQuery.of(context).size.width / 375).clamp(0.8, 1.2);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              child: TopBar(
                title: 'Câu hỏi trắc nghiệm',
              ),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nội dung chính
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24 * pix, vertical: 16 * pix),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Danh Sách Tuần',
                            style: TextStyle(
                              fontSize: 18 * pix,
                              fontFamily: 'BeVietnamPro',
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1C2526),
                            ),
                          ),
                          SizedBox(height: 8 * pix),
                          Text(
                            'Chọn tuần để kiểm tra kiến thức của bạn',
                            style: TextStyle(
                              fontSize: 14 * pix,
                              fontFamily: 'BeVietnamPro',
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 24 * pix),
                          ...weeks.map((week) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8 * pix),
                              child: _buildWeekOption(
                                context,
                                week: week['week'],
                                description: week['description'],
                                score: week['score'],
                                pix: pix,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekOption(
    BuildContext context, {
    required String week,
    required String description,
    required String? score,
    required double pix,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E2F) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1C2526);
    final accentColor =
        score != null ? const Color(0xFF10B981) : const Color(0xFFD97706);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(week: week),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(16 * pix),
        margin: EdgeInsets.symmetric(vertical: 8 * pix),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12 * pix),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * pix),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                score != null ? Icons.check_circle : Icons.pending,
                size: 24 * pix,
                color: accentColor,
              ),
            ),
            SizedBox(width: 16 * pix),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    week,
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontFamily: 'BeVietnamPro',
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4 * pix),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14 * pix,
                      fontFamily: 'BeVietnamPro',
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12 * pix, vertical: 6 * pix),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16 * pix),
              ),
              child: Text(
                score ?? 'Chưa làm',
                style: TextStyle(
                  fontSize: 14 * pix,
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

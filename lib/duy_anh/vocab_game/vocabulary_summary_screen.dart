import 'package:flutter/material.dart';
import 'package:language_app/widget/top_bar.dart';

class VocabularySummaryScreen extends StatelessWidget {
  final int score;
  final int time;
  const VocabularySummaryScreen(
      {super.key, required this.score, required this.time});

  @override
  Widget build(BuildContext context) {
    final pix = MediaQuery.of(context).size.width / 375;
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
              child: TopBar(title: 'Kết Quả'),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        24 * pix, 32 * pix, 24 * pix, 16 * pix),
                    child: Text(
                      'Tổng Kết Trò Chơi',
                      style: TextStyle(
                        fontSize: 28 * pix,
                        fontFamily: 'BeVietnamPro',
                        fontWeight: FontWeight.w700,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF1C2526),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24 * pix),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.celebration,
                              size: 80 * pix,
                              color: const Color(0xFFFFD700),
                            ),
                            SizedBox(height: 16 * pix),
                            Text(
                              'Chúc mừng bạn đã hoàn thành!',
                              style: TextStyle(
                                fontSize: 20 * pix,
                                fontFamily: 'BeVietnamPro',
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1C2526),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24 * pix),
                            // Thẻ tổng kết
                            Card(
                              color: isDarkMode
                                  ? const Color(0xFF1E1E2F)
                                  : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16 * pix),
                                side: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[800]!
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20 * pix),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 24 * pix,
                                          color: const Color(0xFF10B981),
                                        ),
                                        SizedBox(width: 12 * pix),
                                        Expanded(
                                          child: Text(
                                            'Tổng điểm: $score',
                                            style: TextStyle(
                                              fontSize: 18 * pix,
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16 * pix),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 24 * pix,
                                          color: const Color(0xFFD97706),
                                        ),
                                        SizedBox(width: 12 * pix),
                                        Expanded(
                                          child: Text(
                                            'Thời gian: ${time ~/ 60}:${(time % 60).toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              fontSize: 18 * pix,
                                              fontFamily: 'BeVietnamPro',
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFFD97706),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 32 * pix),
                            // Nút điều hướng
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => Navigator.popUntil(
                                      context, (route) => route.isFirst),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24 * pix,
                                        vertical: 12 * pix),
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: const Color(0xFF3B82F6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12 * pix),
                                      side: const BorderSide(
                                          color: Color(0xFF3B82F6)),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Quay Về',
                                    style: TextStyle(
                                      fontSize: 16 * pix,
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // Quay lại để chơi lại
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24 * pix,
                                        vertical: 12 * pix),
                                    backgroundColor: const Color(0xFF10B981),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12 * pix)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Chơi Lại',
                                    style: TextStyle(
                                      fontSize: 16 * pix,
                                      fontFamily: 'BeVietnamPro',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
}

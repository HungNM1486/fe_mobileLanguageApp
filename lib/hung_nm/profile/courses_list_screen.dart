import 'package:flutter/material.dart';

class CoursesListScreen extends StatelessWidget {
  const CoursesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Khóa học của tôi",
          style: TextStyle(
            fontSize: 18 * pix,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding:
              EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 20 * pix),
          children: [
            _buildCourseCard(
              context: context,
              title: 'Tiếng Việt Cơ Bản',
              level: 'Sơ cấp',
              duration: '8 tuần',
              students: '1,250 học viên',
              colorGradient: [
                Colors.orange.shade300,
                Colors.deepOrange.shade400
              ],
              iconData: Icons.auto_stories,
              pix: pix,
            ),
            SizedBox(height: 16 * pix),
            _buildCourseCard(
              context: context,
              title: 'Tiếng Anh Giao Tiếp',
              level: 'Trung cấp',
              duration: '12 tuần',
              students: '3,450 học viên',
              colorGradient: [Colors.blue.shade300, Colors.indigo.shade500],
              iconData: Icons.record_voice_over,
              pix: pix,
            ),
            SizedBox(height: 16 * pix),
            _buildCourseCard(
              context: context,
              title: 'Tiếng Nhật N5',
              level: 'Cơ bản',
              duration: '16 tuần',
              students: '890 học viên',
              colorGradient: [Colors.pink.shade300, Colors.purple.shade500],
              iconData: Icons.translate,
              pix: pix,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required BuildContext context,
    required String title,
    required String level,
    required String duration,
    required String students,
    required List<Color> colorGradient,
    required IconData iconData,
    required double pix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * pix),
        boxShadow: [
          BoxShadow(
            color: colorGradient[0].withOpacity(0.2),
            blurRadius: 10 * pix,
            offset: Offset(0, 4 * pix),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            height: 100 * pix,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colorGradient,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16 * pix),
                topRight: Radius.circular(16 * pix),
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  right: -20 * pix,
                  top: -20 * pix,
                  child: Container(
                    width: 100 * pix,
                    height: 100 * pix,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  right: 30 * pix,
                  bottom: -15 * pix,
                  child: Container(
                    width: 50 * pix,
                    height: 50 * pix,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                // Level badge
                Positioned(
                  top: 12 * pix,
                  left: 12 * pix,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * pix,
                      vertical: 5 * pix,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12 * pix),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 14 * pix,
                          color: colorGradient[1],
                        ),
                        SizedBox(width: 4 * pix),
                        Text(
                          level,
                          style: TextStyle(
                            fontSize: 12 * pix,
                            fontWeight: FontWeight.w600,
                            color: colorGradient[1],
                            fontFamily: 'BeVietnamPro',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Course title
                Positioned(
                  bottom: 12 * pix,
                  left: 12 * pix,
                  right: 70 * pix,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18 * pix,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'BeVietnamPro',
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                // Course icon
                Positioned(
                  right: 16 * pix,
                  bottom: 16 * pix,
                  child: Container(
                    width: 50 * pix,
                    height: 50 * pix,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      iconData,
                      size: 28 * pix,
                      color: colorGradient[1],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Course details
          Padding(
            padding: EdgeInsets.all(16 * pix),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course stats
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.access_time,
                      label: duration,
                      color: Colors.grey.shade700,
                      pix: pix,
                    ),
                    SizedBox(width: 16 * pix),
                    _buildStatItem(
                      icon: Icons.people,
                      label: students,
                      color: Colors.grey.shade700,
                      pix: pix,
                    ),
                  ],
                ),
                SizedBox(height: 16 * pix),
                // Action button
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Chức năng học khóa học đang phát triển'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: colorGradient[1],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10 * pix),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorGradient[1],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12 * pix),
                    minimumSize: Size(double.infinity, 0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * pix),
                    ),
                  ),
                  child: Text(
                    'Vào học',
                    style: TextStyle(
                      fontSize: 15 * pix,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required Color color,
    required double pix,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16 * pix,
          color: color,
        ),
        SizedBox(width: 6 * pix),
        Text(
          label,
          style: TextStyle(
            fontSize: 13 * pix,
            color: color,
            fontFamily: 'BeVietnamPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

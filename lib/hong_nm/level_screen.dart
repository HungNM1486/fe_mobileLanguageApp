import 'package:flutter/material.dart';
import 'package:language_app/hong_nm/do_listen_screen.dart';
import 'package:language_app/models/exercise_model.dart';
import 'package:language_app/provider/exercise_provider.dart';
import 'package:provider/provider.dart';
import 'package:language_app/hong_nm/do_speak_screen.dart';
import 'package:language_app/hong_nm/lesson_screen.dart';
import 'package:language_app/widget/top_bar.dart';

class Levelscreen extends StatefulWidget {
  const Levelscreen({super.key, required this.type});
  final String type;

  @override
  State<Levelscreen> createState() => _LevelscreenState();
}

class _LevelscreenState extends State<Levelscreen> {
  // Danh sách các cấp độ theo thứ tự
  final List<String> _levels = [
    'beginner',
    'basic',
    'intermediate',
    'advanced',
  ];
  final List<String> _levelNames = [
    'Người mới bắt đầu',
    'Cơ bản',
    'Trung cấp',
    'Nâng cao',
  ];
  String _transType() {
    switch (widget.type) {
      case "grammar":
        return "Ngữ pháp";
      case "listening":
        return "Nghe";
      case "speaking":
        return "Phát âm";
      default:
        return "Loại bài tập không xác định";
    }
  }

  // Danh sách mô tả chi tiết cho từng cấp độ
  final Map<String, String> _levelSubtitles = {
    'beginner': 'Khởi đầu học tập',
    'basic': 'Nền tảng vững chắc',
    'intermediate': 'Nâng cao kỹ năng',
    'advanced': 'Thành thạo ngôn ngữ',
  };

  // Danh sách icon cho từng cấp độ
  final Map<String, IconData> _levelIcons = {
    'beginner': Icons.school,
    'basic': Icons.auto_stories,
    'intermediate': Icons.psychology,
    'advanced': Icons.emoji_events,
  };

  @override
  void initState() {
    super.initState();
    // Gọi API để lấy bài tập khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExerciseProvider>(context, listen: false)
          .fetchExerciseList(widget.type);
    });
  }

  // Lấy danh sách bài tập theo cấp độ
  Map<String, List<ExerciseModel>> _getExercisesByLevel(
      List<ExerciseModel> exercises) {
    final Map<String, List<ExerciseModel>> result = {};

    for (var level in _levels) {
      result[level] = exercises.where((ex) => ex.level == level).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

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
        child: Column(
          children: [
            TopBar(title: "Luyện ${_transType()}", isBack: true),
            SizedBox(height: 12 * pix),

            // Header với thông tin loại bài tập
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * pix),
              child: Container(
                padding: EdgeInsets.all(15 * pix),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _getTypeIcon(),
                      size: 32 * pix,
                      color: _getTypeColor(),
                    ),
                    SizedBox(width: 12 * pix),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Học ${_transType()}",
                            style: TextStyle(
                              fontSize: 18 * pix,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BeVietnamPro',
                            ),
                          ),
                          Text(
                            _getTypeDescription(),
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
            ),
            SizedBox(height: 12 * pix),

            // Danh sách bài tập từ Provider
            Expanded(
              child: Consumer<ExerciseProvider>(
                builder: (context, exerciseProvider, child) {
                  // Kiểm tra trạng thái tải
                  if (exerciseProvider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: _getTypeColor(),
                      ),
                    );
                  }
                  if (exerciseProvider.exercises.isEmpty) {
                    return Center(
                      child: Text(
                        "Không có bài tập nào",
                        style: TextStyle(
                          fontSize: 16 * pix,
                          color: Colors.grey.shade600,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                    );
                  }

                  // Phân chia bài tập theo cấp độ
                  final exercisesByLevel =
                      _getExercisesByLevel(exerciseProvider.exercises);

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16 * pix, vertical: 8 * pix),
                    itemCount: _levels.length,
                    itemBuilder: (context, index) {
                      final levelName = _levels[index];
                      final levelExercises = exercisesByLevel[levelName] ?? [];

                      return _buildLevelCard(
                        title: _levelNames[index],
                        subtitle: _levelSubtitles[levelName] ?? '',
                        icon: _levelIcons[levelName] ?? Icons.folder,
                        color: _getLevelColor(levelName),
                        exercises: levelExercises,
                        pix: pix,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tạo widget cho từng cấp độ bài tập
  Widget _buildLevelCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<ExerciseModel> exercises,
    required double pix,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10 * pix, horizontal: 4 * pix),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8 * pix),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24 * pix,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey.shade600,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          childrenPadding:
              EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 8 * pix),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: exercises.isEmpty
              ? [
                  Container(
                    padding: EdgeInsets.all(16 * pix),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_clock,
                          size: 48 * pix,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 8 * pix),
                        Text(
                          "Chưa có bài tập nào, hãy quay lại sau",
                          style: TextStyle(
                            fontSize: 16 * pix,
                            color: Colors.grey.shade600,
                            fontFamily: 'BeVietnamPro',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                ]
              : exercises
                  .asMap()
                  .entries
                  .map(
                    (entry) => _buildExerciseItem(
                      index: entry.key,
                      totalItems: exercises.length,
                      exercise: entry.value,
                      color: color,
                      pix: pix,
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  // Widget cho từng bài tập
  Widget _buildExerciseItem({
    required int index,
    required int totalItems,
    required ExerciseModel exercise,
    required Color color,
    required double pix,
  }) {
    return InkWell(
      onTap: () {
        // Chuyển đến màn hình bài tập tương ứng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              switch (widget.type) {
                case "Ngữ pháp" || "grammar":
                  return Lessonscreen(
                    ex: exercise,
                  );
                case "Nghe" || "listening":
                  return DoListenscreen(
                    ex: exercise,
                  );
                case "Phát âm" || "speaking":
                  return DoSpeakscreen(
                    exercise: exercise,
                  );
                default:
                  return Container(); // Fallback
              }
            },
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: index < totalItems - 1 ? 12 * pix : 0),
        padding: EdgeInsets.symmetric(vertical: 14 * pix, horizontal: 16 * pix),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 32 * pix,
              height: 32 * pix,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
              ),
            ),
            SizedBox(width: 16 * pix),
            Expanded(
              child: Text(
                exercise.name,
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
            ),
            SizedBox(width: 8 * pix),
            exercise.result != -1
                ? Column(
                    children: [
                      Text('Max score',
                          style: TextStyle(
                            fontSize: 12 * pix,
                            color: color,
                            fontFamily: 'BeVietnamPro',
                          )),
                      SizedBox(height: 4 * pix),
                      Text(
                        exercise.result.toString(),
                        style: TextStyle(
                          fontSize: 14 * pix,
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case "Ngữ pháp" || "grammar":
        return Icons.menu_book;
      case "Nghe" || "listening":
        return Icons.headphones;
      case "Phát âm" || "speaking":
        return Icons.mic;
      default:
        return Icons.school;
    }
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case "Ngữ pháp" || "grammar":
        return Colors.blue;
      case "Nghe" || "listening":
        return Colors.green;
      case "Phát âm" || "speaking":
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Người mới bắt đầu' || 'beginner':
        return Colors.green;
      case 'Cơ bản' || 'basic':
        return Colors.blue;
      case 'Trung cấp' || 'intermediate':
        return Colors.orange;
      case 'Nâng cao' || 'advanced':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTypeDescription() {
    switch (widget.type) {
      case "Ngữ pháp":
        return "Học cấu trúc ngôn ngữ thành thạo";
      case "Nghe":
        return "Luyện nghe hiểu các tình huống thực tế";
      case "Phát âm":
        return "Thực hành phát âm và giao tiếp";
      default:
        return "Nâng cao kỹ năng ngôn ngữ";
    }
  }
}

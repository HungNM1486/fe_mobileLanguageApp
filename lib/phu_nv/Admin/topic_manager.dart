import 'package:flutter/material.dart';
import 'package:language_app/phu_nv/Admin/add_topic_screen.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/topic_provider.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:language_app/models/topic_model.dart';
import 'package:language_app/models/language_model.dart';
import 'package:language_app/widget/top_bar.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({Key? key}) : super(key: key);

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  int _selectedLevel = 0;

  final List<int> _levels = [1, 2, 3];
  final Map<int, String> _levelNames = {
    1: 'Cơ bản',
    2: 'Trung cấp',
    3: 'Nâng cao',
  };

  @override
  void initState() {
    super.initState();

    // Khởi tạo và lấy danh sách chủ đề và ngôn ngữ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final topicProvider = Provider.of<TopicProvider>(context, listen: false);

      // Lấy tất cả chủ đề (không lọc)
      topicProvider.fetchTopics();
    });
  }

  // Hàm lọc chủ đề theo ngôn ngữ và cấp độ
  void _filterTopics() {
    if (_selectedLevel == 0) {
      // Nếu chọn "Tất cả cấp độ" thì lấy toàn bộ chủ đề
      Provider.of<TopicProvider>(context, listen: false).fetchTopics();
      return;
    }
    final topicProvider = Provider.of<TopicProvider>(context, listen: false);
    topicProvider.fetchTopics(
      level: _selectedLevel,
    );
  }

  // Reset filter
  void _resetFilter() {
    setState(() {
      _selectedLevel = 0;
    });

    Provider.of<TopicProvider>(context, listen: false).fetchTopics();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTopicScreen(),
            ),
          ).then((_) {
            // Refresh the topic list when returning from AddTopicScreen
            Provider.of<TopicProvider>(context, listen: false).fetchTopics(
              level: _selectedLevel,
            );
          });
        },
        child: Icon(Icons.add),
        tooltip: 'Thêm chủ đề mới',
      ),
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
                title: "Quản lý chủ đề",
              ),
            ),

            // Thanh lọc
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.white.withOpacity(0.9),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Cấp độ',
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                            // Thay đổi giá trị này
                            value: _selectedLevel == 0
                                ? null
                                : _selectedLevel.toString(),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text('Tất cả cấp độ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12 * pix,
                                    )),
                              ),
                              ..._levels.map((level) {
                                return DropdownMenuItem<String>(
                                  value: level.toString(),
                                  child: Text(
                                      _levelNames[level] ?? level.toString()),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                // Chuyển đổi giá trị sang int
                                _selectedLevel =
                                    value != null ? int.parse(value) : 0;
                                _filterTopics();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Danh sách chủ đề
            Positioned(
              top: 190 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Consumer<TopicProvider>(
                builder: (context, topicProvider, child) {
                  if (topicProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (topicProvider.topics.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Không có chủ đề nào',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _selectedLevel != 0
                                ? 'Không tìm thấy kết quả phù hợp với bộ lọc'
                                : 'Hãy thêm chủ đề mới!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 16),
                          if (_selectedLevel != 0)
                            ElevatedButton(
                              onPressed: _resetFilter,
                              child: Text('Đặt lại bộ lọc'),
                            ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: topicProvider.topics.length,
                    itemBuilder: (context, index) {
                      final topic = topicProvider.topics[index];
                      return _buildTopicCard(topic, context);
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

  Widget _buildTopicCard(TopicModel topic, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showTopicOptions(topic, context);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh chủ đề
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: NetworkImage(topic.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getLevelColor(int.tryParse(topic.level) ?? 0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          topic.translevel(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Thông tin chủ đề
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.topic,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${topic.numbervocabulary} từ vựng',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopicOptions(TopicModel topic, BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit, color: Colors.blue),
                  title: Text('Chỉnh sửa chủ đề'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTopicScreen(
                          topic: topic,
                          isEditing: true,
                        ),
                      ),
                    ).then((_) {
                      Provider.of<TopicProvider>(context, listen: false)
                          .fetchTopics(
                        level: _selectedLevel,
                      );
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Xóa chủ đề'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteTopic(topic);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteTopic(TopicModel topic) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa chủ đề "${topic.topic}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                final topicProvider =
                    Provider.of<TopicProvider>(context, listen: false);
                final success = await topicProvider.deleteTopic(topic.id);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xóa chủ đề thành công')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

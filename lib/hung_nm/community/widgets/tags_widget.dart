import 'package:flutter/material.dart';
import 'package:language_app/service/post_service.dart';
import '../topic_page.dart';

class TagsWidget extends StatefulWidget {
  final int maxTags;
  final bool showTitle;

  const TagsWidget({
    Key? key,
    this.maxTags = 20,
    this.showTitle = true,
  }) : super(key: key);

  @override
  State<TagsWidget> createState() => _TagsWidgetState();
}

class _TagsWidgetState extends State<TagsWidget> {
  final PostService _postService = PostService();
  List<String> _tags = [];
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, int> _tagCounts = {}; // Số bài mỗi tag

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Lấy DS tags
      final tags = await _postService.getAllTags();

      // 10 tags
      final List<String> topTags = tags.take(10).toList();

      // Số bài mỗi tag
      for (final tag in topTags) {
        try {
          final result =
              await _postService.getPostsByTag(tag, page: 1, limit: 1);
          final totalItems = result['meta']['totalItems'] ?? 0;
          _tagCounts[tag] = totalItems;
        } catch (e) {
          _tagCounts[tag] = 0;
        }
      }

      // Sắp xếp tags
      topTags
          .sort((a, b) => (_tagCounts[b] ?? 0).compareTo(_tagCounts[a] ?? 0));

      setState(() {
        _tags = topTags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle)
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 4),
            child: Text(
              'Hashtag phổ biến',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? Colors.white70
                    : const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        if (_isLoading)
          const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_hasError)
          SizedBox(
            height: 40,
            child: Center(
              child: TextButton.icon(
                onPressed: _loadTags,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Thử lại'),
              ),
            ),
          )
        else if (_tags.isEmpty)
          const SizedBox(
            height: 40,
            child: Center(
              child: Text(
                'Không có hashtag nào',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _tags.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: _buildTagChip(_tags[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final postCount = _tagCounts[tag] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TopicPage(topic: tag)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.blueAccent.withOpacity(0.15)
              : Colors.blue[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDarkMode
                ? Colors.blueAccent.withOpacity(0.3)
                : Colors.blue[200]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tag,
              size: 12,
              color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
            ),
            const SizedBox(width: 3),
            Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
              ),
            ),
            SizedBox(width: 3),
            // Hiển thị số lượng bài viết
            Text(
              '($postCount)',
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.blue[200] : Colors.blue[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

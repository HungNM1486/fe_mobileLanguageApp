import 'package:flutter/material.dart';
import 'package:language_app/models/topic_model.dart';
import 'package:language_app/phu_nv/widget/topic_widget.dart';
import 'package:language_app/provider/topic_provider.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class VocabularyTopicscreen extends StatefulWidget {
  const VocabularyTopicscreen({super.key});

  @override
  State<VocabularyTopicscreen> createState() => _VocabularyTopicscreenState();
}

class _VocabularyTopicscreenState extends State<VocabularyTopicscreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // Hàm lấy dữ liệu từ backend
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final topicProvider = Provider.of<TopicProvider>(context, listen: false);

    try {
      await topicProvider.fetchTopics();
    } catch (e) {
      // Xử lý lỗi nếu cần
      print('Error loading topics: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Lọc danh sách chủ đề dựa trên từ khóa tìm kiếm
  List<TopicModel> _getFilteredList(List<TopicModel> topics) {
    if (_searchQuery.isEmpty) {
      return topics;
    }
    return topics
        .where((topic) =>
            topic.topic.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Ngăn bàn phím đẩy nội dung lên
      body: Consumer<TopicProvider>(
        builder: (context, topicProvider, child) {
          // Hiển thị loading khi đang tải dữ liệu
          if (_isLoading || topicProvider.isLoading) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade200, Colors.indigo.shade50],
                  stops: const [0.0, 0.7],
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Lấy danh sách chủ đề đã lọc
          final filteredTopics = _getFilteredList(topicProvider.topics);

          return Container(
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
                  right: 0,
                  left: 0,
                  child: TopBar(
                    title: 'Từ vựng theo chủ đề',
                  ),
                ),
                Positioned(
                  top: 100 * pix,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    children: [
                      _buildSearchBar(pix),
                      _buildStats(size, pix, topicProvider.completed,
                          topicProvider.total),
                      Expanded(
                        child: _buildTopicGrid(size, pix, filteredTopics),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(double pix) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isSearching ? 60 * pix : 0,
      child: _isSearching
          ? Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 8 * pix),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Tìm kiếm chủ đề...",
                  prefixIcon: Icon(Icons.search, color: Color(0xff165598)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Color(0xff165598)),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = "";
                        _isSearching = false;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                cursorColor: Color(0xff165598),
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildStats(Size size, double pix, int learned, int total) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16 * pix),
      child: Column(
        children: [
          Container(
            width: size.width * 0.85,
            padding: EdgeInsets.symmetric(vertical: 16 * pix),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Đã học', learned.toString(), pix),
                Container(
                  height: 35 * pix,
                  width: 1 * pix,
                  color: Color(0xff165598).withOpacity(0.3),
                ),
                _buildStatItem('Tổng', total.toString(), pix),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, double pix) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24 * pix,
            fontWeight: FontWeight.bold,
            color: Color(0xff165598),
          ),
        ),
        SizedBox(height: 5 * pix),
        Text(
          title,
          style: TextStyle(
            fontSize: 14 * pix,
            color: Color(0xff165598).withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicGrid(Size size, double pix, List<TopicModel> topics) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * pix),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return Text(
                    'Tất cả chủ đề',
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BeVietnamPro',
                      color: Color(0xff165598),
                    ),
                  );
                },
              ),
              Row(
                children: [
                  // Nút refresh để tải lại dữ liệu
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Color(0xff165598),
                    ),
                    onPressed: _loadData,
                  ),
                  // Nút tìm kiếm
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.search_off : Icons.search,
                      color: Color(0xff165598),
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          _searchQuery = "";
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: topics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.topic_outlined,
                        size: 60 * pix,
                        color: Color(0xff165598).withOpacity(0.5),
                      ),
                      SizedBox(height: 16 * pix),
                      Text(
                        _searchQuery.isNotEmpty
                            ? "Không tìm thấy chủ đề phù hợp"
                            : "Không có chủ đề nào",
                        style: TextStyle(
                          fontSize: 16 * pix,
                          color: Color(0xff165598).withOpacity(0.5),
                        ),
                      ),
                      if (_searchQuery.isEmpty && topics.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 10 * pix),
                          child: ElevatedButton(
                            onPressed: _loadData,
                            child: Text('Tải lại'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff165598),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: GridView.builder(
                    padding: EdgeInsets.all(16 * pix),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 8 * pix,
                    ),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      return Topicwidget(topic: topics[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

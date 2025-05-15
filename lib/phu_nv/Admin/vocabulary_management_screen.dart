import 'package:flutter/material.dart';
import 'package:language_app/models/vocabulary_model.dart';
import 'package:language_app/phu_nv/Admin/add_vocabulary_screen.dart';
import 'package:language_app/phu_nv/widget/network_img.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/vocabulary_provider.dart';
import 'package:language_app/provider/topic_provider.dart';
import 'package:language_app/widget/top_bar.dart';

class VocabularyManagementScreen extends StatefulWidget {
  final String? topicId;

  const VocabularyManagementScreen({Key? key, this.topicId}) : super(key: key);

  @override
  State<VocabularyManagementScreen> createState() =>
      _VocabularyManagementScreenState();
}

class _VocabularyManagementScreenState
    extends State<VocabularyManagementScreen> {
  String? _selectedTopicId;
  String? _selectedDifficulty;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<String> difficulties = ['easy', 'medium', 'hard'];
  Map<String, String> difficultyLabels = {
    'easy': 'Dễ',
    'medium': 'Trung bình',
    'hard': 'Khó'
  };

  @override
  void initState() {
    super.initState();
    _selectedTopicId = widget.topicId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<TopicProvider>(context, listen: false).fetchTopics();

      // Then load vocabularies based on selected filters
      await Provider.of<VocabularyProvider>(context, listen: false)
          .fetchVocabularies(
        topicId: _selectedTopicId,
        difficulty: _selectedDifficulty,
      );
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    Provider.of<VocabularyProvider>(context, listen: false).fetchVocabularies(
      topicId: _selectedTopicId,
      difficulty: _selectedDifficulty,
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedTopicId = null;
      _selectedDifficulty = null;
      _searchQuery = '';
      _searchController.clear();
    });

    Provider.of<VocabularyProvider>(context, listen: false).fetchVocabularies();
  }

  List<VocabularyModel> _getFilteredVocabularies(
      List<VocabularyModel> vocabularies) {
    if (_searchQuery.isEmpty) return vocabularies;

    return vocabularies
        .where((vocab) =>
            vocab.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            vocab.definition.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String capitalizeFirst(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVocabularyScreen(
                selectedTopicId: _selectedTopicId,
              ),
            ),
          ).then((_) => _loadData());
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        tooltip: 'Thêm từ vựng mới',
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
        child: Column(
          children: [
            TopBar(
              title: "Quản lý từ vựng",
            ),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    _buildFilterSection(),
                    _buildSearchBar(),
                    Expanded(
                      child: _buildVocabularyList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 8 * pix),
      color: Colors.white.withOpacity(0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lọc từ vựng',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16 * pix,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Consumer<TopicProvider>(
                  builder: (context, topicProvider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Chủ đề',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: _selectedTopicId,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Tất cả chủ đề',
                              style: TextStyle(
                                  fontFamily: 'BeVietnamPro',
                                  fontSize: 12 * pix)),
                        ),
                        ...topicProvider.topics.map((topic) {
                          return DropdownMenuItem<String>(
                            value: topic.id,
                            child: Text(topic.topic,
                                style: TextStyle(
                                    fontFamily: 'BeVietnamPro',
                                    fontSize: 12 * pix)),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTopicId = value;
                        });
                        _applyFilters();
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Độ khó',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: _selectedDifficulty,
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Tất cả',
                          style: TextStyle(
                              fontFamily: 'BeVietnamPro', fontSize: 12 * pix)),
                    ),
                    ...difficulties.map((difficulty) {
                      return DropdownMenuItem<String>(
                        value: difficulty,
                        child: Text(difficultyLabels[difficulty] ?? difficulty,
                            style: TextStyle(
                                fontFamily: 'BeVietnamPro',
                                fontSize: 12 * pix)),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: _resetFilters,
              icon: Icon(Icons.refresh),
              label: Text('Đặt lại bộ lọc'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm từ vựng...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildVocabularyList() {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Consumer<VocabularyProvider>(
      builder: (context, vocabularyProvider, child) {
        if (vocabularyProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final filteredVocabularies =
            _getFilteredVocabularies(vocabularyProvider.vocabularies);

        if (filteredVocabularies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isNotEmpty ? Icons.search_off : Icons.book,
                  size: 60 * pix,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Không tìm thấy từ vựng phù hợp'
                      : 'Không có từ vựng nào',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 10 * pix),
                if (_searchQuery.isEmpty)
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text('Tải lại'),
                  ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: EdgeInsets.all(16 * pix),
            itemCount: filteredVocabularies.length,
            itemBuilder: (context, index) {
              final vocabulary = filteredVocabularies[index];
              return _buildVocabularyCard(vocabulary);
            },
          ),
        );
      },
    );
  }

  Widget _buildVocabularyCard(VocabularyModel vocabulary) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16 * pix),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * pix),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    capitalizeFirst(vocabulary.word),
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              vocabulary.definition,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            if (vocabulary.imageUrl.isNotEmpty) ...[
              Center(
                child: NetworkImageWidget(
                  url: vocabulary.imageUrl,
                  width: 150,
                  height: 150,
                ),
              ),
            ],
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Sửa'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddVocabularyScreen(
                          isEditing: true,
                          vocabulary: vocabulary,
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  icon: Icon(Icons.delete, size: 18, color: Colors.red),
                  label: Text('Xóa', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    _showDeleteConfirmation(vocabulary);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(VocabularyModel vocabulary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content:
              Text('Bạn có chắc chắn muốn xóa từ vựng "${vocabulary.word}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await Provider.of<VocabularyProvider>(context,
                        listen: false)
                    .deleteVocabulary(vocabulary.id.toString());

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xóa từ vựng thành công')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi xóa từ vựng'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}

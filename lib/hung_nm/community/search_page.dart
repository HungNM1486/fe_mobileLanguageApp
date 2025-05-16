import 'package:flutter/material.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/service/post_service.dart';
import 'package:language_app/service/language_service.dart';
import 'package:language_app/utils/toast_helper.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'widgets/forum_post_card.dart';
import 'likes_list_page.dart';
import 'gallery_viewer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final PostService _postService = PostService();
  final LanguageService _languageService = LanguageService();
  final ScrollController _scrollController = ScrollController();

  List<PostModel> _searchResults = [];
  Map<String, dynamic> _meta = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;

  // Bộ lọc tìm kiếm
  String? _selectedSearchType = 'title'; // 'title', 'content', 'tags'
  int? _selectedLanguageId;
  List<DropdownMenuItem<int>> _languageItems = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo locale tiếng Việt cho timeago
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    // Thêm listener để tải thêm khi cuộn đến cuối
    _scrollController.addListener(_scrollListener);

    // Tải danh sách ngôn ngữ
    _loadLanguages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Tải danh sách ngôn ngữ
  Future<void> _loadLanguages() async {
    try {
      final languages = await _languageService.getAllLanguages();
      setState(() {
        _languageItems = languages.map((language) {
          return DropdownMenuItem<int>(
            value: int.parse(language.id),
            child: Text(language.name),
          );
        }).toList();

        // Thêm tùy chọn "Tất cả ngôn ngữ"
        _languageItems.insert(
            0,
            const DropdownMenuItem<int>(
              value: null,
              child: Text('Tất cả ngôn ngữ'),
            ));
      });
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách ngôn ngữ: $e');
    }
  }

  // Theo dõi cuộn để tải thêm dữ liệu
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreResults();
    }
  }

  // Thực hiện tìm kiếm
  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _meta = {};
        _hasMore = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentPage = 1;
    });

    try {
      // Xác định tham số tìm kiếm dựa trên loại tìm kiếm
      String? title;
      String? content;
      String? tags;

      switch (_selectedSearchType) {
        case 'title':
          title = query;
          break;
        case 'content':
          content = query;
          break;
        case 'tags':
          tags = query;
          break;
        default:
          title = query;
      }

      final result = await _postService.searchPosts(
        title: title,
        content: content,
        tags: tags,
        languageId: _selectedLanguageId,
        page: 1,
        limit: _limit,
      );

      setState(() {
        _searchResults = result['posts'];
        _meta = result['meta'];
        _isLoading = false;

        // Kiểm tra nếu có thêm dữ liệu
        final totalItems = _meta['totalItems'] ?? 0;
        _hasMore = _searchResults.length < totalItems;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      debugPrint('Lỗi khi tìm kiếm: $e');
    }
  }

  // Tải thêm kết quả tìm kiếm
  Future<void> _loadMoreResults() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Xác định tham số tìm kiếm dựa trên loại tìm kiếm
      final query = _searchController.text.trim();
      String? title;
      String? content;
      String? tags;

      switch (_selectedSearchType) {
        case 'title':
          title = query;
          break;
        case 'content':
          content = query;
          break;
        case 'tags':
          tags = query;
          break;
        default:
          title = query;
      }

      final result = await _postService.searchPosts(
        title: title,
        content: content,
        tags: tags,
        languageId: _selectedLanguageId,
        page: _currentPage + 1,
        limit: _limit,
      );

      final newPosts = result['posts'] as List<PostModel>;

      setState(() {
        _searchResults.addAll(newPosts);
        _meta = result['meta'];
        _currentPage++;
        _isLoadingMore = false;

        // Kiểm tra nếu còn dữ liệu
        final totalItems = _meta['totalItems'] ?? 0;
        _hasMore = _searchResults.length < totalItems;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      debugPrint('Lỗi khi tải thêm kết quả: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _search,
            ),
          ),
          onSubmitted: (_) => _search(),
        ),
      ),
      body: Column(
        children: [
          // Bộ lọc tìm kiếm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Loại tìm kiếm
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSearchType,
                    decoration: const InputDecoration(
                      labelText: 'Tìm theo',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'title', child: Text('Tiêu đề')),
                      DropdownMenuItem(
                          value: 'content', child: Text('Nội dung')),
                      DropdownMenuItem(value: 'tags', child: Text('Hashtag')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSearchType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Lọc theo ngôn ngữ
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedLanguageId,
                    decoration: const InputDecoration(
                      labelText: 'Ngôn ngữ',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _languageItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguageId = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Kết quả tìm kiếm
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading && _searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Đã xảy ra lỗi khi tìm kiếm'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _search,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      if (_searchController.text.isEmpty) {
        return const Center(
          child: Text('Nhập từ khóa để tìm kiếm bài viết'),
        );
      } else {
        return const Center(
          child: Text('Không tìm thấy kết quả nào'),
        );
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _search();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _searchResults.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _searchResults.length) {
            return _buildLoadMoreIndicator();
          }
          return _buildPostCard(_searchResults[index]);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return ForumPostCard(
      post: post,
      expandable: true,
      onPostDeleted: () {
        _search(); // Tải lại kết quả tìm kiếm
      },
      onImageTap: (imageUrls, initialIndex) {
        _openGallery(imageUrls, initialIndex);
      },
      onLikesViewTap: (post) {
        if ((post.likes?.length ?? 0) > 0) {
          ToastHelper.showInfo(
              context, 'Xem ${post.likes?.length} người đã thích bài viết');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LikesListPage(post: post),
            ),
          );
        }
      },
    );
  }

  // Mở gallery xem ảnh
  void _openGallery(List<String> imageUrls, int initialIndex) {
    // Hiển thị thông báo hướng dẫn
    ToastHelper.showInfo(
        context, 'Vuốt để xem ảnh khác, chạm để đóng/mở điều khiển');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModernGallery(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

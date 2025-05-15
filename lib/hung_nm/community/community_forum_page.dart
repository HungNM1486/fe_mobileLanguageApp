import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/phu_nv/Notification/notification_screen.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'forum_detail_page.dart';
import 'create_post_page.dart';
import 'search_page.dart';
import 'widgets/forum_post_card.dart';
import 'widgets/tags_widget.dart';

class CommunityForumPage extends StatefulWidget {
  const CommunityForumPage({Key? key}) : super(key: key);

  @override
  State<CommunityForumPage> createState() => _CommunityForumPageState();
}

class _CommunityForumPageState extends State<CommunityForumPage>
    with SingleTickerProviderStateMixin {
  // Controller và biến trạng thái
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Danh sách các bộ lọc và biến kiểm soát
  String _selectedFilter = 'Tất cả';
  bool _isLoading = false;
  bool _isLiking = false;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Danh sách các bộ lọc chủ đề
  final List<String> _filters = [
    'Tất cả',
    'Ngữ pháp',
    'Từ vựng',
    'Phát âm',
    'Nói',
    'Viết',
    'Khác'
  ];

  // Các icon cho bộ lọc
  final List<IconData> _filterIcons = [
    Icons.apps,
    Icons.format_quote,
    Icons.book,
    Icons.record_voice_over,
    Icons.mic,
    Icons.edit,
    Icons.more_horiz
  ];

  // Các màu gradient cho từng bộ lọc
  final List<List<Color>> _filterGradients = [
    [Colors.blue, Colors.lightBlue],
    [Colors.purple, Colors.purpleAccent],
    [Colors.green, Colors.lightGreen],
    [Colors.orange, Colors.amber],
    [Colors.red, Colors.redAccent],
    [Colors.indigo, Colors.indigoAccent],
    [Colors.grey, Colors.blueGrey],
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo TabController
    _tabController = TabController(length: 3, vsync: this);

    // Lắng nghe sự thay đổi tab mà không gây ra mất dữ liệu
    _tabController.addListener(() {
      // Chỉ làm mới giao diện khi tab thay đổi, không thay đổi dữ liệu
      setState(() {});

      // Tải dữ liệu tương ứng với tab
      _loadTabData(_tabController.index);
    });

    // Tải dữ liệu ban đầu sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

    // Thiết lập màu thanh trạng thái
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Lắng nghe sự kiện cuộn để tải thêm dữ liệu khi cần
    _scrollController.addListener(_onScroll);
  }

  // Hàm tải dữ liệu tương ứng với tab được chọn
  void _loadTabData(int tabIndex) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    // Tránh tải lại nếu đang trong quá trình tải
    if (_isLoading) return;

    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });

    switch (tabIndex) {
      case 0: // Tab "Mới nhất"
        _loadData();
        break;
      case 1: // Tab "Phổ biến"
        postProvider.fetchPopularPosts();
        break;
      case 2: // Tab "Đang theo dõi"
        // Thay đổi thành lấy bài viết xu hướng
        postProvider.fetchTrendingPosts(days: 7, limit: 10);
        break;
    }
  }

  // Tải dữ liệu bài viết
  Future<void> _loadData() async {
    if (_isLoading) return; // Ngăn không cho tải nhiều lần cùng lúc

    setState(() {
      _isLoading = true;
    });

    final postProvider = Provider.of<PostProvider>(context, listen: false);

    try {
      final success = await postProvider.fetchPosts();

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (success) {
            _currentPage = 1;
            _hasMoreData = postProvider.posts.length % 10 == 0 &&
                postProvider.posts.isNotEmpty;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading posts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Xử lý sự kiện cuộn để tải thêm dữ liệu
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMoreData) {
      _loadMoreData();
    }
  }

  // Tải thêm dữ liệu
  Future<void> _loadMoreData() async {
    setState(() {
      _isLoading = true;
    });

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    bool success = false;

    // Tải dữ liệu tương ứng với tab đang hiển thị
    switch (_tabController.index) {
      case 0: // Tab "Mới nhất"
        success = await postProvider.fetchPosts(
          page: _currentPage + 1,
          limit: 10,
        );
        break;
      case 1: // Tab "Phổ biến"
        success = await postProvider.fetchPopularPosts(
            limit: (_currentPage + 1) * 10);
        break;
      case 2: // Tab "Xu hướng"
        success = await postProvider.fetchTrendingPosts(
          days: 7,
          limit: (_currentPage + 1) * 10,
        );
        break;
    }

    if (success) {
      setState(() {
        _currentPage++;
        _hasMoreData = postProvider.posts.length % 10 == 0 &&
            postProvider.posts.isNotEmpty;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasMoreData = false;
      });
    }
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Xử lý thích bài viết
  Future<void> _likePost(PostModel post) async {
    // Tạo phản hồi xúc giác
    HapticFeedback.lightImpact();

    // Tránh thích nhiều lần
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      // Kiểm tra xem người dùng đã thích bài viết này chưa
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (post.likes!.any((like) => like.userId == userId)) {
        _showSnackBar('Bạn đã thích bài viết này');
        setState(() {
          _isLiking = false;
        });
        return;
      }

      // Gọi API thích bài viết
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final success = await postProvider.likePost(int.parse(post.id!));

      if (success) {
        setState(() {
          _isLiking = false;
        });
        _showSnackBar('Đã thích bài viết');
      } else {
        _showSnackBar('Không thể thích bài viết');
        setState(() {
          _isLiking = false;
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}');
      setState(() {
        _isLiking = false;
      });
    }
  }

  // Hiển thị SnackBar thông báo
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  // Điều hướng đến trang tạo bài viết
  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostPage()),
    );

    // Nếu tạo bài viết thành công, tải lại danh sách
    if (result == true) {
      _loadData();
    }
  }

  // Điều hướng đến trang chi tiết bài viết
  void _navigateToPostDetail(PostModel post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumDetailPage(post: post),
      ),
    );

    // Tải lại dữ liệu khi quay lại từ trang chi tiết
    _loadData();
  }

  // Điều hướng đến trang thông báo
  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Notificationsscreen()),
    );
  }

  // Điều hướng đến trang tìm kiếm
  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375; // Hệ số tỷ lệ responsive
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        // Gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkMode ? Color(0xFF1A1A2E) : Color(0xFF4B6CB7),
              isDarkMode ? Color(0xFF16213E) : Color(0xFF182848),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(pix, isDarkMode),

              // Main Content Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        )
                      ]),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                    child: Consumer<PostProvider>(
                      builder: (context, postProvider, child) {
                        // Hiển thị skeleton loading nếu đang tải
                        if (_isLoading && postProvider.posts.isEmpty) {
                          return _buildSkeletonLoading(pix);
                        }

                        // Lọc bài viết dựa trên bộ lọc đã chọn
                        List<PostModel> filteredPosts = List.from(postProvider
                            .posts); // Tạo bản sao để tránh thay đổi mảng gốc
                        if (_selectedFilter != 'Tất cả') {
                          filteredPosts = filteredPosts
                              .where((post) =>
                                  post.tags?.contains(_selectedFilter) ?? false)
                              .toList();
                        }

                        // Sắp xếp bài viết dựa trên tab đang chọn
                        if (_tabController.index == 1) {
                          // Tab "Phổ biến" - sắp xếp theo số lượt thích
                          filteredPosts.sort((a, b) => (b.likes?.length ?? 0)
                              .compareTo(a.likes?.length ?? 0));
                        } else if (_tabController.index == 0) {
                          // Tab "Mới nhất" - sắp xếp theo thời gian tạo
                          filteredPosts.sort((a, b) =>
                              (b.createdAt ?? DateTime(1970))
                                  .compareTo(a.createdAt ?? DateTime(1970)));
                        }

                        return Column(
                          children: [
                            // TabBar
                            _buildTabBar(isDarkMode),

                            // Filter Chips
                            _buildFilterChips(pix, isDarkMode),

                            // Tags Widget - Hiển thị hashtag phổ biến
                            Container(
                              width: double.infinity,
                              child: TagsWidget(maxTags: 8),
                            ),

                            // Tab Content
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Tab Mới nhất
                                  _buildPostList(
                                      filteredPosts, pix, isDarkMode),

                                  // Tab Phổ biến
                                  _buildPostList(
                                      filteredPosts, pix, isDarkMode),

                                  // Tab Đang theo dõi
                                  _buildPostList(
                                      filteredPosts, pix, isDarkMode),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Widget TabBar được tối ưu
  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ]),
      child: TabBar(
        controller: _tabController,
        labelColor: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
        unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: 'BeVietnamPro',
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          fontFamily: 'BeVietnamPro',
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.access_time),
            text: 'Mới nhất',
          ),
          Tab(
            icon: Icon(Icons.local_fire_department),
            text: 'Phổ biến',
          ),
          Tab(
            icon: Icon(Icons.trending_up),
            text: 'Xu hướng',
          ),
        ],
      ),
    );
  }

  // App Bar hiện đại
  Widget _buildAppBar(double pix, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            'Cộng đồng học tập',
            style: TextStyle(
              fontSize: 20 * pix,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          Spacer(),
          _buildAppBarButton(icon: Icons.search, onPressed: _navigateToSearch),
          SizedBox(width: 8),
          _buildAppBarButton(
              icon: Icons.notifications, onPressed: _navigateToNotifications),
        ],
      ),
    );
  }

  // Nút trên App Bar
  Widget _buildAppBarButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 26),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Hiệu ứng skeleton loading
  Widget _buildSkeletonLoading(double pix) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Tab skeleton
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                  3,
                  (index) => Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                      )),
            ),
          ),

          // Filter skeleton
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          // Posts skeleton
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Floating Action Button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreatePost,
      icon: Icon(Icons.add, size: 22),
      label: Text(
        'Tạo bài viết',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'BeVietnamPro',
        ),
      ),
      elevation: 4,
      backgroundColor: Color(0xFF4B6CB7),
    );
  }

  // Bộ lọc chủ đề
  Widget _buildFilterChips(double pix, bool isDarkMode) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                // Thêm hiệu ứng haptic feedback
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: _filterGradients[index],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _filterGradients[index][0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      _filterIcons[index],
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : isDarkMode
                              ? Colors.white70
                              : Colors.grey[800],
                    ),
                    SizedBox(width: 6),
                    Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isDarkMode
                                ? Colors.white70
                                : Colors.grey[800],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Danh sách bài viết
  Widget _buildPostList(List<PostModel> posts, double pix, bool isDarkMode) {
    // Chỉ hiển thị trạng thái trống khi không phải đang tải và danh sách thực sự trống
    if (posts.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sử dụng animation Lottie cho trạng thái trống
            Lottie.network(
              'https://assets1.lottiefiles.com/packages/lf20_KU3FGB.json',
              width: 200,
              height: 200,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                // Xử lý trường hợp lỗi khi tải animation
                return Container(
                  width: 200,
                  height: 200,
                  child: Icon(
                    Icons.error_outline,
                    size: 80,
                    color: isDarkMode ? Colors.white60 : Colors.grey[600],
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Chưa có bài viết nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'BeVietnamPro',
                color: isDarkMode ? Colors.white70 : Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy là người đầu tiên chia sẻ kiến thức',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white60 : Colors.grey[600],
                fontFamily: 'BeVietnamPro',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreatePost,
              icon: Icon(Icons.add),
              label: Text('Tạo bài viết đầu tiên'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4B6CB7),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.blue,
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: posts.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          // Hiển thị loading indicator ở cuối danh sách nếu đang tải thêm
          if (index == posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final post = posts[index];

          // Sử dụng Hero widget để tạo animation chuyển màn hình
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Hero(
              tag: 'post_${post.id}',
              child: ForumPostCard(
                post: post,
                onTap: () => _navigateToPostDetail(post),
              ),
            ),
          );
        },
      ),
    );
  }
}

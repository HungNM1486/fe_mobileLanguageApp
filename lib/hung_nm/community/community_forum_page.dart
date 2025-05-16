import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/phu_nv/Notification/notification_screen.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'gallery_viewer.dart';
import 'create_post_page.dart';
import 'search_page.dart';
import 'widgets/forum_post_card.dart';
import 'widgets/tags_widget.dart';
import 'inline_forum_post.dart';
import 'likes_list_page.dart';
import 'package:language_app/utils/toast_helper.dart';

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

  // Các icon hiện đại cho bộ lọc
  final List<IconData> _filterIcons = [
    Icons.dashboard_rounded,
    Icons.format_quote_rounded,
    Icons.menu_book_rounded,
    Icons.record_voice_over_rounded,
    Icons.mic_rounded,
    Icons.edit_rounded,
    Icons.more_horiz_rounded
  ];

  // Các màu gradient hiện đại cho từng bộ lọc
  final List<List<Color>> _filterGradients = [
    [Color(0xFF5B6EF5), Color(0xFF7D8EFF)], // Xanh dương cho "Tất cả"
    [Color(0xFF8E69F1), Color(0xFFAB92FF)], // Tím cho "Ngữ pháp"
    [Color(0xFF46BEA3), Color(0xFF70D9C2)], // Xanh lá cho "Từ vựng"
    [Color(0xFFF86A6A), Color(0xFFFF9798)], // Hồng/đỏ cho "Phát âm"
    [Color(0xFFFF9800), Color(0xFFFFBB66)], // Cam cho "Nói"
    [Color(0xFF40A1F8), Color(0xFF78C4FF)], // Xanh nhạt cho "Viết"
    [Color(0xFF909399), Color(0xFFB6B9BE)], // Xám cho "Khác"
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
      case 2: // Tab "Xu hướng"
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

   // Điều hướng đến trang tạo bài viết
  void _navigateToCreatePost() async {
    // Thêm hiệu ứng haptic
    HapticFeedback.mediumImpact();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostPage()),
    );

    // Nếu tạo bài viết thành công, tải lại danh sách
    if (result == true) {
      _loadData();
    }
  }

  // Điều hướng đến trang thông báo
  void _navigateToNotifications() {
    // Thêm hiệu ứng haptic
    HapticFeedback.lightImpact();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Notificationsscreen()),
    );
  }

  // Điều hướng đến trang tìm kiếm
  void _navigateToSearch() {
    // Thêm hiệu ứng haptic
    HapticFeedback.lightImpact();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  // Phương thức để mở gallery hình ảnh
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375; // Hệ số tỷ lệ responsive
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Màu accent chính của app
    final accentColor = Color(0xFF5B6EF5); // Xanh dương sáng

    return Scaffold(
      body: Container(
        // Gradient background hiện đại hơn
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                  ]
                : [
                    Color(0xFF5B6EF5),
                    Color(0xFF4B6CB7),
                  ],
            stops: [0.1, 0.9],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar đẹp hơn
              _buildModernAppBar(pix, isDarkMode, accentColor),

              // Main Content Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF0F0F23) : Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, -2),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(26)),
                    child: Consumer<PostProvider>(
                      builder: (context, postProvider, child) {
                        // Hiển thị skeleton loading nếu đang tải
                        if (_isLoading && postProvider.posts.isEmpty) {
                          return _buildModernSkeletonLoading(pix, isDarkMode);
                        }

                        // Lọc bài viết dựa trên bộ lọc đã chọn
                        List<PostModel> filteredPosts =
                            List.from(postProvider.posts);
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
                            // TabBar với thiết kế hiện đại
                            _buildModernTabBar(isDarkMode, accentColor),

                            // Filter Chips sinh động hơn
                            _buildModernFilterChips(
                                pix, isDarkMode, accentColor),

                            // Tags Widget - Hiển thị hashtag phổ biến
                            Container(
                              width: double.infinity,
                              child: TagsWidget(maxTags: 8),
                            ),

                            // Tab Content với hiệu ứng mới
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                // Thêm hiệu ứng transition cho TabBarView
                                physics: BouncingScrollPhysics(),
                                children: [
                                  // Tab Mới nhất
                                  _buildModernPostList(filteredPosts, pix,
                                      isDarkMode, accentColor),

                                  // Tab Phổ biến
                                  _buildModernPostList(filteredPosts, pix,
                                      isDarkMode, accentColor),

                                  // Tab Xu hướng
                                  _buildModernPostList(filteredPosts, pix,
                                      isDarkMode, accentColor),
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
      floatingActionButton: _buildModernFloatingActionButton(accentColor),
    );
  }

  // Widget TabBar hiện đại hơn
  Widget _buildModernTabBar(bool isDarkMode, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: accentColor,
        unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        // Indicator mới - có animation đẹp hơn
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: accentColor,
              width: 3,
              style: BorderStyle.solid,
            ),
          ),
        ),
        // Tùy chỉnh padding tab
        padding: EdgeInsets.symmetric(horizontal: 8),
        labelPadding: EdgeInsets.symmetric(horizontal: 8),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          letterSpacing: 0.3,
          fontFamily: 'BeVietnamPro',
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.1,
          fontFamily: 'BeVietnamPro',
        ),
        // Tab hiện đại hơn với icon gắn liền với text
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time_rounded, size: 18),
                SizedBox(width: 6),
                Text('Mới nhất'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department_rounded, size: 18),
                SizedBox(width: 6),
                Text('Phổ biến'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up_rounded, size: 18),
                SizedBox(width: 6),
                Text('Xu hướng'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // App Bar hiện đại và sinh động hơn
  Widget _buildModernAppBar(double pix, bool isDarkMode, Color accentColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 12),
          Text(
            'Cộng đồng học tập',
            style: TextStyle(
              fontSize: 22 * pix,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'BeVietnamPro',
              letterSpacing: 0.5,
              // Thêm shadow cho text
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          Spacer(),
          // Nút tìm kiếm hiện đại
          _buildModernAppBarButton(
            icon: Icons.search_rounded,
            onPressed: _navigateToSearch,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          SizedBox(width: 12),
          // Nút thông báo
          _buildModernAppBarButton(
            icon: Icons.notifications_rounded,
            onPressed: _navigateToNotifications,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            badge: true, // Thêm badge để hiển thị có thông báo mới
          ),
        ],
      ),
    );
  }

  // Nút trên App Bar hiện đại
  Widget _buildModernAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Gradient gradient,
    bool badge = false,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onPressed,
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        // Hiển thị badge nếu có thông báo
        if (badge)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Color(0xFFF86A6A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFF86A6A).withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Hiệu ứng skeleton loading hiện đại
  Widget _buildModernSkeletonLoading(double pix, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[900]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
      period: Duration(milliseconds: 1500),
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
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 90,
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

          // Tags skeleton
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  width: 60 + (index * 10 % 30),
                  height: 24,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16),

          // Posts skeleton
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  height: 240,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      // Header part
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                            ),
                            SizedBox(width: 12),
                            // Name
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Colors.grey[200],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: 80,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey[200],
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            // Menu
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content placeholder
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Container(
                              width: double.infinity,
                              height: 18,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                color: Colors.grey[200],
                              ),
                            ),
                            SizedBox(height: 12),
                            // Content text
                            Container(
                              width: double.infinity,
                              height: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.grey[200],
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: double.infinity * 0.8,
                              height: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.grey[200],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Spacer(),

                      // Footer buttons
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey[200],
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              width: 80,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey[200],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Floating Action Button cải tiến với gradient
  Widget _buildModernFloatingActionButton(Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            accentColor,
            accentColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.4),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToCreatePost,
          borderRadius: BorderRadius.circular(26),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Tạo bài viết',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'BeVietnamPro',
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bộ lọc chủ đề với thiết kế hiện đại hơn
  Widget _buildModernFilterChips(
      double pix, bool isDarkMode, Color accentColor) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1E30) : Colors.grey[50],
        // Shadow nhẹ để tạo độ sâu
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        physics: BouncingScrollPhysics(), // Physics lăn trang mượt mà hơn
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
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
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  // Shadow cho chip được chọn
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _filterGradients[index][0].withOpacity(0.4),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                            spreadRadius: -2,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Icon trong khung tròn
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : isDarkMode
                                ? Colors.grey[700]
                                : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _filterIcons[index],
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : isDarkMode
                                ? Colors.white70
                                : Colors.grey[800],
                      ),
                    ),
                    SizedBox(width: 8),
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
                        fontSize: 14,
                        fontFamily: 'BeVietnamPro',
                        letterSpacing: isSelected ? 0.3 : 0,
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

  // Danh sách bài viết với thiết kế hiện đại
  Widget _buildModernPostList(
    List<PostModel> posts,
    double pix,
    bool isDarkMode,
    Color accentColor,
  ) {
    // Trạng thái trống hiện đại
    if (posts.isEmpty && !_isLoading) {
      return Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie animation hiện đại
              Container(
                height: 200,
                width: 200,
                child: Lottie.network(
                  'https://assets1.lottiefiles.com/packages/lf20_KU3FGB.json',
                  repeat: true,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback khi lỗi animation
                    return Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey[800]!.withOpacity(0.3)
                            : Colors.grey[200]!,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.forum_outlined,
                        size: 80,
                        color: accentColor.withOpacity(0.5),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              // Tiêu đề với giao diện hiện đại
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.8),
                      accentColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Chưa có bài viết nào',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'BeVietnamPro',
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Hãy là người đầu tiên chia sẻ kiến thức',
                style: TextStyle(
                  fontSize: 15,
                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              SizedBox(height: 28),
              // Button tạo bài viết hiện đại
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToCreatePost,
                    splashColor: Colors.white24,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Tạo bài viết đầu tiên',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'BeVietnamPro',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // RefreshIndicator với màu sắc hiện đại
    return RefreshIndicator(
      onRefresh: _loadData,
      color: accentColor,
      backgroundColor: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
      strokeWidth: 2.5,
      displacement: 40,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 12, bottom: 20),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: posts.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          // Hiển thị loading indicator ở cuối danh sách nếu đang tải thêm
          if (index == posts.length) {
            return Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  strokeWidth: 3,
                ),
              ),
            );
          }

          final post = posts[index];

          // Hero animation cho transition mượt mà
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Hero(
              tag: 'post_${post.id}',
              child: Material(
                color: Colors.transparent,
                child: ForumPostCard(
                  post: post,
                  expandable: true,
                  onPostDeleted: () {
                    _loadData(); // Tải lại khi bài viết bị xóa
                  },
                  onImageTap: (imageUrls, initialIndex) {
                    _openGallery(imageUrls, initialIndex);
                  },
                  onLikesViewTap: (post) {
                    if ((post.likes?.length ?? 0) > 0) {
                      ToastHelper.showInfo(context,
                          'Xem ${post.likes?.length} người đã thích bài viết');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LikesListPage(post: post),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

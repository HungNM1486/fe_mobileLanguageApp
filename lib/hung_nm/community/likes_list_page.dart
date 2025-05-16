import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_app/models/post_model.dart';
import 'package:language_app/service/post_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LikesListPage extends StatefulWidget {
  final PostModel post;

  const LikesListPage({Key? key, required this.post}) : super(key: key);

  @override
  State<LikesListPage> createState() => _LikesListPageState();
}

class _LikesListPageState extends State<LikesListPage>
    with SingleTickerProviderStateMixin {
  final PostService _postService = PostService();
  final ScrollController _scrollController = ScrollController();

  // Animation controllers for entry animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Modern color palette
  final Color _accentColor = Color(0xFF5B6EF5); // Primary accent
  final Color _secondaryColor = Color(0xFFF86A6A); // Action/highlight
  final Color _successColor = Color(0xFF46BEA3); // Success state

  List<dynamic> _users = [];
  Map<String, dynamic> _meta = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start loading data
    _loadUsers();
    _scrollController.addListener(_scrollListener);

    // Start entry animation
    _animationController.forward();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  // Clean up resources
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Infinite scroll with pagination
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreUsers();
    }
  }

  // Load initial users
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _postService.getPostLikes(
        widget.post.id!,
        page: 1,
        limit: _limit,
      );

      setState(() {
        _users = result['users'] ?? [];
        _meta = Map<String, dynamic>.from(result['meta'] ?? {});
        _isLoading = false;
        _currentPage = 1;

        // Check if there's more data to load
        final totalItems = _meta['totalItems'] ?? 0;
        _hasMore = _users.length < totalItems;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // Load more users with pagination
  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = await _postService.getPostLikes(
        widget.post.id!,
        page: _currentPage + 1,
        limit: _limit,
      );

      final newUsers = result['users'] as List<dynamic>? ?? [];

      setState(() {
        _users.addAll(newUsers);
        _meta = Map<String, dynamic>.from(result['meta'] ?? {});
        _currentPage++;
        _isLoadingMore = false;

        // Check if there's more data to load
        final totalItems = _meta['totalItems'] ?? 0;
        _hasMore = _users.length < totalItems;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Color(0xFF0F0F23) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildModernAppBar(isDarkMode, textColor),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(isDarkMode),
      ),
    );
  }

  // Modern app bar with better styling
  PreferredSizeWidget _buildModernAppBar(bool isDarkMode, Color textColor) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lượt thích',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
          Text(
            '${_meta['totalItems'] ?? _users.length} người đã thích',
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[800]!.withAlpha(204) // 0.8 opacity
                : Colors.grey[100]!,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: textColor,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Heart icon with count
        Container(
          margin: EdgeInsets.only(right: 16),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _secondaryColor.withAlpha(26), // 0.1 opacity
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: _secondaryColor,
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                '${_meta['totalItems'] ?? _users.length}',
                style: TextStyle(
                  color: _secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Main body with different states
  Widget _buildBody(bool isDarkMode) {
    // Loading state
    if (_isLoading && _users.isEmpty) {
      return _buildLoadingState(isDarkMode);
    }

    // Error state
    if (_hasError) {
      return _buildErrorState(isDarkMode);
    }

    // Empty state
    if (_users.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    // Content state with users list
    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: _accentColor,
      backgroundColor: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
      strokeWidth: 2.5,
      displacement: 40,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 12),
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: _users.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator at the end for pagination
          if (index == _users.length) {
            return _buildLoadMoreIndicator(isDarkMode);
          }

          // User item with staggered animation
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Staggered animation delay based on index
              final delay = index * 0.05;
              final animationValue =
                  (_animationController.value - delay).clamp(0.0, 1.0);

              return Opacity(
                opacity: animationValue,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - animationValue)),
                  child: child,
                ),
              );
            },
            child: _buildUserItem(_users[index], isDarkMode,
                textColor: isDarkMode ? Colors.white : Colors.black87),
          );
        },
      ),
    );
  }

  // Enhanced loading state
  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13), // 0.05 opacity
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Đang tải danh sách...',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced error state
  Widget _buildErrorState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _secondaryColor.withAlpha(26), // 0.1 opacity
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: _secondaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Đã xảy ra lỗi khi tải danh sách',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Vui lòng kiểm tra kết nối mạng và thử lại',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),
            // Retry button with modern design
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentColor, Color(0xFF7D8EFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withAlpha(77), // 0.3 opacity
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _loadUsers,
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Colors.white24,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Thử lại',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  // Enhanced empty state
  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF252A40) : Colors.grey[100]!,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 40,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Chưa có ai thích bài viết này',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Hãy chia sẻ bài viết này với bạn bè của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),
            // Share button with modern design
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF252A40) : Colors.grey[100]!,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    // Share functionality can be implemented here
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Chia sẻ bài viết')));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share_rounded,
                          color: _accentColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Chia sẻ',
                          style: TextStyle(
                            color: _accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  // Enhanced loading indicator for pagination
  Widget _buildLoadMoreIndicator(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13), // 0.05 opacity
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }

  // Enhanced user item with better avatar and layout
  Widget _buildUserItem(dynamic user, bool isDarkMode,
      {required Color textColor}) {
    if (user is! Map<String, dynamic>) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
        elevation: 1,
        child: ListTile(
          contentPadding: EdgeInsets.all(12),
          title: Text(
            'Thông tin người dùng không hợp lệ',
            style: TextStyle(
              color: textColor,
            ),
          ),
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF252A40) : Colors.grey[100]!,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: _secondaryColor,
              size: 20,
            ),
          ),
        ),
      );
    }

    final String firstName = user['firstName'] ?? '';
    final String lastName = user['lastName'] ?? '';
    final String fullName = "$firstName $lastName";
    final String? profileImage = user['profileImageUrl'];
    final String email = user['email'] ?? '';
    final String displayName =
        fullName.trim().isNotEmpty ? fullName : 'Người dùng ẩn danh';

    // Generate avatar color based on name
    final Color avatarColor = _getAvatarColor(displayName);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withAlpha(13), // 0.05 opacity
      child: InkWell(
        onTap: () {
          // Add haptic feedback
          HapticFeedback.selectionClick();

          // This could navigate to user profile in the future
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Enhanced avatar with better placeholder
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13), // 0.05 opacity
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: avatarColor,
                  backgroundImage:
                      profileImage != null && profileImage.isNotEmpty
                          ? CachedNetworkImageProvider(profileImage)
                          : null,
                  child: profileImage == null || profileImage.isEmpty
                      ? Center(
                          child: Text(
                            _getInitials(displayName),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(width: 16),

              // User info with better typography
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Heart icon on the right
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _secondaryColor.withAlpha(26), // 0.1 opacity
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: _secondaryColor,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get avatar initials
  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  // Helper method to generate consistent avatar colors
  Color _getAvatarColor(String name) {
    // List of colors to choose from
    final colors = [
      Color(0xFF5B6EF5), // Blue
      Color(0xFFF86A6A), // Red
      Color(0xFF46BEA3), // Green
      Color(0xFFFF9800), // Orange
      Color(0xFF8E69F1), // Purple
      Color(0xFF40A1F8), // Light blue
      Color(0xFFFF6B92), // Pink
    ];

    // Use string hash to pick a consistent color
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }
}

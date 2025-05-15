import 'package:flutter/material.dart';
import 'package:language_app/models/user_model.dart';
import 'package:language_app/models/achievement_model.dart';
import 'package:language_app/provider/achievement_provider.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/models/post_model.dart';
import 'activity.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/bottom_bar.dart';
import 'add_fr.dart';
import 'setting/setting_screen.dart';
import 'friends_list_screen.dart';
import 'package:provider/provider.dart';
import 'qr_scanner_screen.dart';
import 'share_optiones.dart';
import 'package:language_app/hung_nm/community/forum_detail_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final Color _primaryColor = const Color(0xFF5B7BFE);
  final Color _secondaryColor = const Color(0xFF20C3AF);
  final Color _backgroundColor = const Color(0xFFF8FAFF);
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // Thêm đoạn này để tải thành tựu và bài viết cá nhân
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AchievementProvider>(context, listen: false)
          .getAllAchievements();

      // Tải bài viết cá nhân
      Provider.of<PostProvider>(context, listen: false).fetchMyPosts();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 200 * pix,
            left: 0,
            right: 0,
            bottom: 50 * pix,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 100 * pix),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                    child: Column(
                      children: [
                        SizedBox(height: 20 * pix),
                        _buildLanguageAndFriendsSection(size, pix),
                        SizedBox(height: 20 * pix),
                        _buildAddFriendAndShareSection(size, pix),
                        SizedBox(height: 25 * pix),
                        _buildActivitySection(size, pix),
                        SizedBox(height: 25 * pix),
                        _buildAchievementsSection(size, pix),
                        SizedBox(height: 20 * pix),
                        _buildMyPostsSection(size, pix),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildProfileHeader(size, pix),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_animation),
                child: Bottombar(type: 5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Size size, double pix) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      if (userProvider.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (userProvider.user == null) {
        return const Center(child: Text('Không tìm thấy người dùng'));
      }
      UserModel user = userProvider.user!;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 40 * pix, bottom: 30 * pix),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryColor, _secondaryColor],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(right: 16 * pix),
                child: IconButton(
                  icon:
                      Icon(Icons.settings, size: 28 * pix, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingScreen()),
                    );
                  },
                ),
              ),
            ),
            _buildUserInfo(size, pix, user),
          ],
        ),
      );
    });
  }

  Widget _buildUserInfo(Size size, double pix, UserModel user) {
    return Column(
      children: [
        Container(
          width: 120 * pix,
          height: 120 * pix,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3 * pix),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: user.profile_image_url.isNotEmpty
                ? Image.network(
                    user.profile_image_url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      AppImages.personlearn1,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    AppImages.personlearn1,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        SizedBox(height: 15 * pix),
        Text(
          '${user.firstname} ${user.lastname}',
          style: TextStyle(
            fontSize: 24 * pix,
            fontFamily: 'BeVietnamPro',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5 * pix),
        Text(
          'Tham gia vào tháng ${user.createAt.substring(5, 7)} năm ${user.createAt.substring(0, 4)}',
          style: TextStyle(
            fontSize: 14 * pix,
            fontFamily: 'BeVietnamPro',
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageAndFriendsSection(Size size, double pix) {
    return Container(
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            pix,
            'Bạn bè',
            '120',
            isText: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FriendsListScreen()),
              );
            },
          ),
          Container(
            width: 1 * pix,
            height: 60 * pix,
            color: Colors.grey.withOpacity(0.2),
          ),
          _buildStatItem(
            pix,
            'Điểm số',
            '7,5',
            isText: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(double pix, String title, String content,
      {bool isText = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          if (isText)
            Text(
              content,
              style: TextStyle(
                fontSize: 24 * pix,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.w600,
                color: _primaryColor,
              ),
            )
          else
            Container(
              width: 40 * pix,
              height: 40 * pix,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10 * pix),
                image: DecorationImage(
                  image: AssetImage(content),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          SizedBox(height: 5 * pix),
          Text(
            title,
            style: TextStyle(
              fontSize: 14 * pix,
              fontFamily: 'BeVietnamPro',
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFriendAndShareSection(Size size, double pix) {
    return Column(
      children: [
        _buildActionButton(
          pix,
          'Thêm bạn bè',
          Icons.person_add,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddFrScreen()),
            );
          },
        ),
        SizedBox(height: 12 * pix),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                pix,
                'Chia sẻ',
                Icons.share,
                onPressed: () {
                  ShareOptions.showShareOptions(context);
                },
              ),
            ),
            SizedBox(width: 8 * pix),
            Expanded(
              child: _buildActionButton(
                pix,
                'Quét QR',
                Icons.qr_code_scanner,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QRScannerScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    double pix,
    String title,
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 2,
        padding: EdgeInsets.symmetric(vertical: 12 * pix, horizontal: 8 * pix),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * pix),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18 * pix),
          SizedBox(width: 6 * pix),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15 * pix,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(Size size, double pix) {
    return Container(
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hoạt động học tập',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ActivityScreen()),
                  );
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15 * pix),
          _buildActivityItem(
            pix,
            Icons.school,
            Colors.orange,
            'Thời gian học hôm nay',
            '4h 20p',
          ),
          SizedBox(height: 15 * pix),
          _buildActivityItem(
            pix,
            Icons.assignment_turned_in,
            Colors.green,
            'Số bài tập hoàn thành',
            '12 bài',
          ),
          SizedBox(height: 15 * pix),
          _buildActivityItem(
            pix,
            Icons.star,
            Colors.yellow[700]!,
            'Số bài kiểm tra đã làm',
            '5 bài',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      double pix, IconData icon, Color color, String title, String value) {
    return Container(
      padding: EdgeInsets.all(12 * pix),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(15 * pix),
      ),
      child: Row(
        children: [
          Container(
            width: 40 * pix,
            height: 40 * pix,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20 * pix, color: color),
          ),
          SizedBox(width: 15 * pix),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontFamily: 'BeVietnamPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3 * pix),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(Size size, double pix) {
    return Consumer<AchievementProvider>(
      builder: (context, achievementProvider, child) {
        if (achievementProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Container(
          padding: EdgeInsets.all(16 * pix),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20 * pix),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thành tích của bạn',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 15 * pix),
              if (achievementProvider.achievements.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20 * pix),
                    child: Text(
                      'Bạn chưa có thành tựu nào. Hãy tiếp tục học tập để đạt được thành tựu!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14 * pix,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              else
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 12 * pix,
                  crossAxisSpacing: 12 * pix,
                  children: achievementProvider.achievements.map((achievement) {
                    return _buildAchievementBadge(
                        pix,
                        achievement.title,
                        achievement.description,
                        achievement.badgeImageUrl,
                        achievement.isUnlocked);
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementBadge(double pix, String title, String description,
      String imagePath, bool unlocked) {
    return Column(
      children: [
        Container(
          width: 70 * pix,
          height: 70 * pix,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? _primaryColor.withOpacity(0.1) : Colors.grey[200],
            border: Border.all(
              color: unlocked ? _primaryColor : Colors.grey[300]!,
              width: 2 * pix,
            ),
          ),
          child: unlocked
              ? Center(
                  child: imagePath.isNotEmpty
                      ? Image.network(
                          imagePath,
                          width: 40 * pix,
                          height: 40 * pix,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.emoji_events,
                            size: 30 * pix,
                            color: _primaryColor,
                          ),
                        )
                      : Icon(
                          Icons.emoji_events,
                          size: 30 * pix,
                          color: _primaryColor,
                        ),
                )
              : Center(
                  child: Icon(
                    Icons.lock,
                    size: 30 * pix,
                    color: Colors.grey[400],
                  ),
                ),
        ),
        SizedBox(height: 8 * pix),
        Text(
          title,
          style: TextStyle(
            fontSize: 14 * pix,
            fontFamily: 'BeVietnamPro',
            fontWeight: FontWeight.w500,
            color: unlocked ? Colors.black : Colors.grey[400],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 12 * pix,
            fontFamily: 'BeVietnamPro',
            color: unlocked ? _secondaryColor : Colors.grey[400],
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Phần hiển thị bài viết cá nhân
  Widget _buildMyPostsSection(Size size, double pix) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15 * pix),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bài viết của tôi',
                  style: TextStyle(
                    fontSize: 18 * pix,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Tải lại bài viết cá nhân
                    Provider.of<PostProvider>(context, listen: false)
                        .fetchMyPosts();
                  },
                  child: Text(
                    'Làm mới',
                    style: TextStyle(
                      fontSize: 14 * pix,
                      color: _secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              if (postProvider.isLoading) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20 * pix),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    ),
                  ),
                );
              }

              if (postProvider.posts.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(20 * pix),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 50 * pix,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 10 * pix),
                        Text(
                          'Bạn chưa có bài viết nào',
                          style: TextStyle(
                            fontSize: 16 * pix,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 5 * pix),
                        Text(
                          'Hãy chia sẻ kiến thức với cộng đồng',
                          style: TextStyle(
                            fontSize: 14 * pix,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Tôi đa 10 bài
              final displayedPosts = postProvider.posts.take(10).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedPosts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final post = displayedPosts[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForumDetailPage(post: post),
                        ),
                      ).then((_) {
                        // Tải lại bài viết sau khi quay lại
                        Provider.of<PostProvider>(context, listen: false)
                            .fetchMyPosts();
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(15 * pix),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title ?? 'Không có tiêu đề',
                            style: TextStyle(
                              fontSize: 16 * pix,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5 * pix),
                          Text(
                            post.content ?? '',
                            style: TextStyle(
                              fontSize: 14 * pix,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10 * pix),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.red[400],
                                size: 16 * pix,
                              ),
                              SizedBox(width: 5 * pix),
                              Text(
                                '${post.likes?.length ?? 0}',
                                style: TextStyle(
                                  fontSize: 12 * pix,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 15 * pix),
                              Icon(
                                Icons.comment,
                                color: Colors.blue[400],
                                size: 16 * pix,
                              ),
                              SizedBox(width: 5 * pix),
                              Text(
                                '${post.comments?.length ?? 0}',
                                style: TextStyle(
                                  fontSize: 12 * pix,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Spacer(),
                              Text(
                                '${_formatDate(post.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12 * pix,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (Provider.of<PostProvider>(context).posts.length > 3)
            Padding(
              padding: EdgeInsets.all(15 * pix),
              child: Center(
                child: Text(
                  'Đang hiển thị ${Provider.of<PostProvider>(context).posts.length > 10 ? 10 : Provider.of<PostProvider>(context).posts.length} bài viết mới nhất',
                  style: TextStyle(
                    fontSize: 14 * pix,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Hàm định dạng thời gian
  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}

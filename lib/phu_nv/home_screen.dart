import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_app/hung_nm/community/community_forum_page.dart';
import 'package:language_app/phu_nv/LoginSignup/login_screen.dart';
import 'package:language_app/phu_nv/Notification/notification_screen.dart';
import 'package:language_app/phu_nv/widget/network_img.dart';
import 'package:language_app/phu_nv/widget/exercise_section.dart';
import 'package:language_app/phu_nv/widget/topic_widget.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/provider/notification_provider.dart';
import 'package:language_app/provider/progress_provider.dart';
import 'package:language_app/provider/topic_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/widget/bottom_bar.dart';
import 'package:provider/provider.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> _courseTypes = [
    'Ngữ pháp',
    'Nghe',
    'Phát âm',
  ];

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

    // Initialize data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progressProvider =
          Provider.of<ProgressProvider>(context, listen: false);
      progressProvider.getTopicProgress();
      progressProvider.getExerciseProgress();
      progressProvider.getExamProgress();

      final topicProvider = Provider.of<TopicProvider>(context, listen: false);
      topicProvider.fetchTopics(level: 1);

      // lấy noti về
      final notiProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      notiProvider.getNumberNewNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white,
              Colors.blue.shade100,
              Colors.white
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildScrollableContent(size, pix),
            _buildHeader(size, pix),
            Positioned(
              top: 40 * pix,
              right: 20 * pix,
              child: Container(
                  alignment: Alignment.centerRight,
                  child: Consumer<NotificationProvider>(
                    builder: (context, notiProvider, child) {
                      if (notiProvider.loading) {
                        Center(child: CircularProgressIndicator());
                      }
                      final unreadCount =
                          Provider.of<NotificationProvider>(context)
                              .unreadCount;

                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications,
                                color: Colors.white, size: 30 * pix),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Notificationsscreen()),
                              );
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unreadCount > 99
                                      ? '99+'
                                      : unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  )),
            ),
            Positioned(
              bottom: 0 * pix,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: Bottombar(type: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, double pix) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Consumer<UserProvider>(builder: (context, userProvider, child) {
        if (userProvider.user == null || userProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = userProvider.user!;
        return Container(
          height: 220 * pix,
          width: size.width,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff3B82F6), Color(0xff4F46E5)],
              stops: [0.2, 0.8],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30 * pix),
              bottomRight: Radius.circular(30 * pix),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 10),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Abstract background patterns
              Positioned(
                top: -20 * pix,
                right: -20 * pix,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    height: 150 * pix,
                    width: 150 * pix,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -60 * pix,
                left: -30 * pix,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    height: 180 * pix,
                    width: 180 * pix,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * pix),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10 * pix),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              alignment: Alignment.centerRight,
                              child: _buildCircleIconButton(
                                icon: Icons.more_vert,
                                pix: pix,
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Tuỳ chọn'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildHelpButton(
                                                context,
                                                'Trợ giúp',
                                                Colors.blue,
                                                () {
                                                  Navigator.pop(context);
                                                  // Navigate to help screen
                                                },
                                              ),
                                              SizedBox(height: 10 * pix),
                                              _buildHelpButton(
                                                context,
                                                'Chính sách & điều khoản',
                                                Colors.green,
                                                () {
                                                  Navigator.pop(context);
                                                  // Navigate to settings screen
                                                },
                                              ),
                                              SizedBox(height: 10 * pix),
                                              _buildHelpButton(
                                                context,
                                                'Đăng xuất',
                                                Colors.red,
                                                () {
                                                  final authProvider =
                                                      Provider.of<AuthProvider>(
                                                          context,
                                                          listen: false);
                                                  authProvider.logout(context);
                                                  Navigator.pop(context);
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const Loginscreen(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Đóng'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                              )),
                          Container(
                            height: 10 * pix,
                            width: 10 * pix,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: 80 * pix,
                            width: 80 * pix,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3 * pix,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(0, 5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: user.profile_image_url != ""
                                  ? NetworkImageWidget(
                                      url: user.profile_image_url,
                                      width: 80 * pix,
                                      height: 80 * pix,
                                    )
                                  : Image.asset(
                                      AppImages.personlearn1,
                                      width: 80 * pix,
                                      height: 80 * pix,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          SizedBox(width: 20 * pix),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Xin chào,',
                                  style: TextStyle(
                                    fontSize: 16 * pix,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'BeVietnamPro',
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                SizedBox(height: 4 * pix),
                                Text(
                                  '${user.firstname} ${user.lastname}',
                                  style: TextStyle(
                                    fontSize: 22 * pix,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'BeVietnamPro',
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8 * pix),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12 * pix,
                                    vertical: 6 * pix,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius:
                                        BorderRadius.circular(20 * pix),
                                  ),
                                  child: Text(
                                    'Chúc bạn học tốt!',
                                    style: TextStyle(
                                      fontSize: 14 * pix,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'BeVietnamPro',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCircleIconButton(
      {required IconData icon,
      required double pix,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40 * pix,
        width: 40 * pix,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22 * pix,
        ),
      ),
    );
  }

  Widget _buildScrollableContent(Size size, double pix) {
    return Positioned(
      top: 180 * pix,
      left: 0,
      right: 0,
      bottom: 0,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 50 * pix),
            _buildProgressIndicator(pix),
            _buildTopicSection(pix, 'Chủ đề cơ bản', AppImages.fire),
            _buildEXSection(pix, 'Làm bài tập', AppImages.start, _courseTypes),
            _buildCommunitySection(pix),
            SizedBox(height: 100 * pix), // Bottom padding for scrolling
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, int completed, int total) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final double progressPercentage = total > 0 ? (completed / total) : 0.0;

    return Container(
      height: pix * 60,
      width: size.width - 80 * pix,
      child: Column(
        children: [
          Container(
            width: double.maxFinite,
            child: Text(
              "$completed/$total $title",
              maxLines: 2,
              style: TextStyle(
                fontSize: 14 * pix,
                fontWeight: FontWeight.w500,
                fontFamily: 'BeVietnamPro',
                color: const Color(0xff165598).withOpacity(0.8),
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 8 * pix),
          Container(
            height: 16 * pix,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8 * pix),
            ),
            child: Row(
              children: [
                Container(
                  height: 16 * pix,
                  width: progressPercentage * (size.width - 80 * pix),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff7DD339), Color(0xff9AE259)],
                    ),
                    borderRadius: BorderRadius.circular(8 * pix),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff7DD339).withOpacity(0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(double pix) {
    return Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
      if (progressProvider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 20 * pix,
        ),
        padding: EdgeInsets.all(16 * pix),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * pix),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 35, 0, 189).withOpacity(0.2),
              offset: const Offset(0, 5),
              blurRadius: 10,
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
                  'Tiến độ học tập',
                  style: TextStyle(
                    fontSize: 18 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                    color: const Color(0xff165598),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * pix,
                    vertical: 8 * pix,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff7DD339).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12 * pix),
                  ),
                  child: Text(
                    "${progressProvider.completed}%",
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BeVietnamPro',
                      color: const Color(0xff7DD339),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * pix),
            _buildProgressItem(
              'Chủ đề từ vựng',
              progressProvider.topicCompleted,
              progressProvider.totalTopic,
            ),
            _buildProgressItem(
              'Bài tập hoàn thành',
              progressProvider.exerciseCompleted,
              progressProvider.totalExercise,
            ),
            _buildProgressItem(
              'Bài thi hoàn thành',
              progressProvider.examCompleted,
              progressProvider.totalExam,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(double pix, String title, String iconPath) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20 * pix,
        right: 20 * pix,
        top: 24 * pix,
        bottom: 12 * pix,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8 * pix),
                child: Container(
                  padding: EdgeInsets.all(8 * pix),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 254, 254, 255)
                        .withOpacity(0.9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    iconPath,
                    width: 26 * pix,
                    height: 26 * pix,
                  ),
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                  color: const Color(0xff165598),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSection(double pix, String title, String iconPath) {
    return Consumer<TopicProvider>(builder: (context, topicProvider, child) {
      if (topicProvider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(pix, title, iconPath),
          SizedBox(height: 8 * pix),
          Container(
            height: 230 * pix,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 12 * pix),
              itemCount: topicProvider.topics.length,
              itemBuilder: (context, index) {
                return Topicwidget(topic: topicProvider.topics[index]);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEXSection(
      double pix, String title, String iconPath, List<String> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(pix, title, iconPath),
        SizedBox(height: 8 * pix),
        Container(
          height: 230 * pix,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12 * pix),
            itemCount: types.length,
            itemBuilder: (context, index) {
              return EXSection(
                type: types[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommunitySection(double pix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(pix, 'Cộng đồng học tập', AppImages.communication),
        SizedBox(height: 8 * pix),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20 * pix),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24 * pix),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 10),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24 * pix),
            child: InkWell(
              onTap: () {},
              child: Stack(
                children: [
                  Image.asset(
                    AppImages.communication1,
                    height: 200 * pix,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 200 * pix,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(20 * pix),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tham gia ngay',
                            style: TextStyle(
                              fontSize: 14 * pix,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 8 * pix),
                          Text(
                            'Cộng đồng học tập sôi động',
                            style: TextStyle(
                              fontSize: 22 * pix,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16 * pix),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CommunityForumPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * pix,
                                vertical: 10 * pix,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30 * pix),
                              ),
                              child: Text(
                                'Tham gia ngay',
                                style: TextStyle(
                                  fontSize: 14 * pix,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff4F46E5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 50),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_app/models/notification_model.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/notification_provider.dart';
import 'package:language_app/phu_nv/Notification/notification_detail_screen.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:lottie/lottie.dart';

class Notificationsscreen extends StatefulWidget {
  const Notificationsscreen({super.key});

  @override
  State<Notificationsscreen> createState() => _NotificationsscreenState();
}

class _NotificationsscreenState extends State<Notificationsscreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  // Primary accent color to match forum design
  final Color _accentColor = Color(0xFF5B6EF5);
  final Color _secondaryColor = Color(0xFFF86A6A);
  final Color _successColor = Color(0xFF46BEA3);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Animation controller for item animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set system UI style for immersive experience
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Get notifications data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotifications();
      _animationController.forward();
    });
  }

  Future<void> _refreshNotifications() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    bool res = await notificationProvider.getListNotification();
    if (!res) {
      if (mounted) {
        // Modern error snackbar with icon
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Không thể tải thông báo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: _secondaryColor,
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            elevation: 4,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: _refreshNotifications,
            ),
          ),
        );
      }
    }
  }

  Future<void> _seeDetail(NotificationModel noti) async {
    // Add haptic feedback for better interaction
    HapticFeedback.mediumImpact();

    if (!noti.isRead) {
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      if (noti.id != null) {
        // Show subtle loading indicator
        showDialog(
          context: context,
          barrierColor: Colors.black12,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
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
            );
          },
        );

        bool res = await notificationProvider.markNotificationAsRead(noti.id!);

        // Close loading dialog
        Navigator.of(context).pop();

        if (!res) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Không thể đánh dấu đã đọc',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: _secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              duration: Duration(seconds: 2),
              margin: EdgeInsets.all(16),
            ),
          );
          return;
        }
      }
    }

    // Navigate with hero animation for smooth transition
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailscreen(notification: noti),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thông báo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.unreadCount > 0) {
                return IconButton(
                  onPressed: () async {
                    final success = await notificationProvider.markAll();
                    if (success) {
                      await _refreshNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Tất cả thông báo đã được đánh dấu đã đọc'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: _successColor,
                        duration: Duration(seconds: 2),
                      ));
                    }
                  },
                  icon: Icon(Icons.done_all),
                  tooltip: 'Đánh dấu tất cả đã đọc',
                );
              }
              return SizedBox.shrink();
            },
          ),
          IconButton(
            onPressed: _refreshNotifications,
            icon: Icon(Icons.refresh),
            tooltip: 'Làm mới thông báo',
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? Color(0xFF0F0F23) : Colors.grey[50],
        child: _buildNotificationList(pix, isDarkMode),
      ),
    );
  }

  Widget _buildEmptyState(double pix, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon for empty state
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 60 * pix,
              color: _accentColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Không có thông báo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Thông báo mới sẽ xuất hiện ở đây',
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
          ),
          SizedBox(height: 24),
          // Refresh button
          TextButton.icon(
            onPressed: _refreshNotifications,
            icon: Icon(Icons.refresh_rounded, color: Colors.white),
            label: Text(
              'Làm mới',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: _accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(double pix, bool isDarkMode) {
    return Consumer<NotificationProvider>(
      builder: (context, notiProvider, child) {
        if (notiProvider.loading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            ),
          );
        } else if (notiProvider.getNotificationList.isEmpty) {
          return _buildEmptyState(pix, isDarkMode);
        }

        return RefreshIndicator(
          onRefresh: () => _refreshNotifications(),
          color: _accentColor,
          backgroundColor: isDarkMode ? Color(0xFF1A1E30) : Colors.white,
          strokeWidth: 2.5,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16 * pix),
            itemCount: notiProvider.getNotificationList.length,
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemBuilder: (context, index) {
              NotificationModel notification =
                  notiProvider.getNotificationList[index];
              return _buildNotificationItem(notification, pix, isDarkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
      NotificationModel notification, double pix, bool isDarkMode) {
    return Dismissible(
      key: ValueKey(notification.id ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        margin: EdgeInsets.only(bottom: 12 * pix),
        decoration: BoxDecoration(
          color: _secondaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 24 * pix,
        ),
      ),
      confirmDismiss: (direction) async {
        // Add haptic feedback
        HapticFeedback.mediumImpact();

        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Xác nhận xóa",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Text(
                "Bạn có chắc chắn muốn xóa thông báo này?",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Hủy",
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final notificationProvider =
                        Provider.of<NotificationProvider>(context,
                            listen: false);

                    Navigator.of(context).pop(true);

                    bool res = await notificationProvider
                        .deleteNotification(notification.id!);

                    if (!res) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Không thể xóa thông báo'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _secondaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          duration: Duration(seconds: 2),
                          margin: EdgeInsets.all(16),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xóa thông báo'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _successColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          duration: Duration(seconds: 2),
                          margin: EdgeInsets.all(16),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _secondaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Xóa",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            );
          },
        );
      },
      child: Card(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        margin: EdgeInsets.only(bottom: 12 * pix),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _seeDetail(notification);
          },
          splashColor: notification.color.withOpacity(0.1),
          highlightColor: notification.color.withOpacity(0.05),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: !notification.isRead
                  ? (isDarkMode
                      ? Color(0xFF252A40)
                      : Colors.blue.withOpacity(0.05))
                  : null,
            ),
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with simpler container
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    notification.icon,
                    color: Colors.white,
                    size: 20 * pix,
                  ),
                ),
                SizedBox(width: 12 * pix),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with better typography
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 15 * pix,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8 * pix,
                              height: 8 * pix,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: notification.color,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4 * pix),
                      // Content preview
                      notification.content.isNotEmpty
                          ? Text(
                              notification.content.length > 80
                                  ? '${notification.content.substring(0, 80)}...'
                                  : notification.content,
                              style: TextStyle(
                                fontSize: 13 * pix,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                height: 1.3,
                              ),
                            )
                          : SizedBox.shrink(),
                      SizedBox(height: 6 * pix),
                      // Timestamp row
                      Text(
                        notification.time,
                        style: TextStyle(
                          fontSize: 12 * pix,
                          color:
                              isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

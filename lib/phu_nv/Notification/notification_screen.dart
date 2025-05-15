import 'package:flutter/material.dart';
import 'package:language_app/models/notification_model.dart';
import 'package:provider/provider.dart';
import 'package:language_app/provider/notification_provider.dart';
import 'package:language_app/phu_nv/Notification/notification_detail_screen.dart';
import 'package:language_app/widget/top_bar.dart';

class Notificationsscreen extends StatefulWidget {
  const Notificationsscreen({super.key});

  @override
  State<Notificationsscreen> createState() => _NotificationsscreenState();
}

class _NotificationsscreenState extends State<Notificationsscreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // lấy noti về
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotifications();
    });
  }

  Future<void> _refreshNotifications() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    bool res = await notificationProvider.getListNotification();
    if (!res) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load notifications'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // xem chi tiết
  Future<void> _seeDetail(NotificationModel noti) async {
    if (!noti.isRead) {
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      if (noti.id != null) {
        bool res = await notificationProvider.markNotificationAsRead(noti.id!);
        if (!res) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
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
                  left: 0,
                  right: 0,
                  child: TopBar(
                    title: "Thông báo",
                  ),
                ),
                Positioned(
                  top: 100 * pix,
                  right: 10 * pix,
                  left: 10 * pix,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: () async {
                          await _refreshNotifications();
                        },
                        tooltip: "Làm mới thông báo",
                      ),
                      if (notificationProvider.unreadCount > 0)
                        TextButton.icon(
                          icon: Icon(Icons.check_circle_outline,
                              color: Colors.white),
                          label: Text(
                            "Đánh dấu tất cả đã đọc",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            final notificationProvider =
                                Provider.of<NotificationProvider>(context,
                                    listen: false);
                            bool res = await notificationProvider.markAll();
                            if (!res) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Có lỗi xảy ra'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              await _refreshNotifications();
                            }
                          },
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 135 * pix,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildNotificationList(pix),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(double pix) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 70 * pix,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16 * pix),
          Text(
            "Không có thông báo",
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8 * pix),
          Text(
            "Thông báo mới sẽ xuất hiện ở đây",
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(double pix) {
    return Consumer<NotificationProvider>(
        builder: (context, notiProvider, child) {
      if (notiProvider.loading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (notiProvider.getNotificationList.isEmpty) {
        return _buildEmptyState(pix);
      }

      return RefreshIndicator(
        onRefresh: () => _refreshNotifications(),
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16 * pix),
          itemCount: notiProvider.getNotificationList.length,
          itemBuilder: (context, index) {
            NotificationModel notification =
                notiProvider.getNotificationList[index];
            return _buildNotificationItem(notification, pix);
          },
        ),
      );
    });
  }

  Widget _buildNotificationItem(NotificationModel notification, double pix) {
    return Dismissible(
      key: ValueKey(notification.id ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        margin: EdgeInsets.only(bottom: 16 * pix),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30 * pix,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Xác nhận"),
              content: Text("Bạn có chắc chắn muốn xóa thông báo này?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Hủy"),
                ),
                TextButton(
                  onPressed: () async {
                    final notificationProvider =
                        Provider.of<NotificationProvider>(context,
                            listen: false);
                    bool res = await notificationProvider
                        .deleteNotification(notification.id!);
                    if (!res) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Có lỗi xảy ra'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xóa thông báo'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Xóa",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.only(bottom: 16 * pix),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            _seeDetail(notification);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.color,
                    size: 30 * pix,
                  ),
                ),
                SizedBox(width: 16 * pix),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16 * pix,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8 * pix),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 12 * pix,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Icon(
                    Icons.circle,
                    color: Colors.red,
                    size: 10 * pix,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

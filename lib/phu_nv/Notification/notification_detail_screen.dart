import 'package:flutter/material.dart';
import 'package:language_app/models/notification_model.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/hung_nm/community/forum_detail_page.dart';
import 'package:provider/provider.dart';

class NotificationDetailscreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailscreen({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Container(
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
                title: "Chi tiết thông báo",
              ),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: _buildNotificationContent(context, pix),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationContent(BuildContext context, double pix) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(24 * pix),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(14 * pix),
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16 * pix),
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
                        notification.title.isNotEmpty
                            ? notification.title
                            : 'Không có tiêu đề',
                        style: TextStyle(
                          fontSize: 24 * pix,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8 * pix),
                      Text(
                        notification.time,
                        style: TextStyle(
                          fontSize: 14 * pix,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32 * pix),
            Container(
              padding: EdgeInsets.all(20 * pix),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16 * pix),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nội dung thông báo",
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16 * pix),
                  Text(
                    notification.content.isNotEmpty
                        ? notification.content
                        : 'Không có nội dung',
                    style: TextStyle(
                      fontSize: 16 * pix,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24 * pix),
            _buildAdditionalInfo(context, pix),
            SizedBox(height: 16 * pix),
            _buildNavigationButton(context, pix),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context, double pix) {
    // Kiểm tra nếu thông báo là comment và có postId
    if (notification.type == 'comment' &&
        notification.data != null &&
        notification.data!.containsKey('postId')) {
      final postId = notification.data!['postId'];

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            // Hiển thị loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            );

            // Lấy chi tiết bài viết
            final postProvider =
                Provider.of<PostProvider>(context, listen: false);
            final success = await postProvider.getPostDetail(postId);

            // Ẩn loading
            Navigator.pop(context);

            if (success && postProvider.postDetail != null) {
              // Điều hướng đến trang chi tiết bài viết
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ForumDetailPage(post: postProvider.postDetail!),
                ),
              );
            } else {
              // Hiển thị thông báo lỗi
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Không thể tải bài viết'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: Icon(Icons.arrow_forward_ios),
          label: Text(
            'Xem bài viết',
            style: TextStyle(fontSize: 16 * pix),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16 * pix),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * pix),
            ),
          ),
        ),
      );
    }

    // Không hiển thị nút nếu không phải comment notification
    return SizedBox.shrink();
  }

  Widget _buildAdditionalInfo(BuildContext context, double pix) {
    if (notification.data == null || notification.data!.isEmpty) {
      return SizedBox();
    }

    // Nếu là comment notification với postId, chỉ hiển thị các thông tin khác (không hiển thị postId)
    if (notification.type == 'comment' &&
        notification.data!.containsKey('postId')) {
      Map<String, dynamic> filteredData = Map.from(notification.data!);
      filteredData.remove('postId'); // Loại bỏ postId khỏi hiển thị

      if (filteredData.isEmpty) {
        return SizedBox(); // Không có thông tin bổ sung để hiển thị
      }

      return _buildAdditionalInfoContent(filteredData, pix);
    }

    // Với các loại notification khác, hiển thị tất cả data
    return _buildAdditionalInfoContent(notification.data!, pix);
  }

  Widget _buildAdditionalInfoContent(Map<String, dynamic> data, double pix) {
    List<Widget> infoWidgets = [];

    try {
      data.forEach((key, value) {
        // Chuyển đổi giá trị thành chuỗi hiển thị
        String displayValue;
        if (value is String) {
          displayValue = value;
        } else if (value is num) {
          displayValue = value.toString();
        } else if (value is List) {
          displayValue = value.join(', ');
        } else if (value is Map) {
          displayValue = value.toString();
        } else {
          displayValue = value.toString();
        }

        infoWidgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 8 * pix),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$key: ',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Expanded(
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 16 * pix,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Error processing notification.data: $e');
      return Text(
        'Không thể hiển thị thông tin bổ sung',
        style: TextStyle(
          fontSize: 16 * pix,
          color: Colors.red,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20 * pix),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16 * pix),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thông tin thêm",
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16 * pix),
          ...infoWidgets,
        ],
      ),
    );
  }
}

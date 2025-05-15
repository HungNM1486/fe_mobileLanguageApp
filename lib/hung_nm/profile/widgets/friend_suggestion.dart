import 'package:flutter/material.dart';

class FriendSuggestionList extends StatelessWidget {
  final Size size;
  final double pix;
  final int itemCount;

  const FriendSuggestionList({
    super.key,
    required this.size,
    required this.pix,
    this.itemCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height - 180 * pix,
      child: ListView.builder(
        itemCount: itemCount,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20 * pix),
        itemBuilder: (context, index) => FriendItem(index: index, pix: pix),
        shrinkWrap: true,
      ),
    );
  }
}

class FriendItem extends StatelessWidget {
  final int index;
  final double pix;

  const FriendItem({super.key, required this.index, required this.pix});

  @override
  Widget build(BuildContext context) {
    // Xác định ngẫu nhiên trình độ và thông tin khác nhau cho mỗi người dùng
    final List<String> levels = ['Sơ cấp', 'Trung cấp', 'Nâng cao'];
    final List<String> interests = [
      'Ngữ pháp',
      'Từ vựng',
      'Giao tiếp',
      'Phát âm'
    ];

    final userLevel = levels[index % levels.length];
    final userInterest = interests[index % interests.length];

    // Xác định phần trăm phù hợp (50-95%)
    final matchPercent = 50 + (index % 46);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0 * pix, horizontal: 4.0 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0 * pix),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeadingSection(matchPercent),
            SizedBox(width: 12 * pix),
            Expanded(
              child: _buildInfoSection(userLevel, userInterest),
            ),
            SizedBox(width: 6 * pix),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingSection(int matchPercent) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blue.shade100,
              width: 3 * pix,
            ),
          ),
          child: CircleAvatar(
            radius: 28 * pix,
            backgroundImage:
                const AssetImage('lib/res/imagesLA/personlearn1.png'),
          ),
        ),
        Container(
          padding: EdgeInsets.all(4 * pix),
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2 * pix,
            ),
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 10 * pix,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String level, String interest) {
    // Tạo tên người dùng có ý nghĩa hơn
    List<String> names = [
      'Nguyễn Văn A',
      'Trần Thị B',
      'Lê Minh C',
      'Phạm Hồng D',
      'Hoàng Thu E',
      'Đỗ Thanh F',
      'Vũ Minh G',
      'Bùi Lan H',
      'Ngô Văn I',
      'Đinh Thị K'
    ];

    String username = index < names.length ? names[index] : 'Người dùng $index';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                username,
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6 * pix),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6 * pix,
                vertical: 2 * pix,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4 * pix),
              ),
              child: Text(
                level,
                style: TextStyle(
                  fontSize: 10 * pix,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * pix),
        Text(
          'Quan tâm đến $interest',
          style: TextStyle(
            fontSize: 13 * pix,
            fontFamily: 'BeVietnamPro',
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 6 * pix),
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 14 * pix,
              color: Colors.grey.shade500,
            ),
            SizedBox(width: 4 * pix),
            Text(
              'Hoạt động gần đây',
              style: TextStyle(
                fontSize: 12 * pix,
                fontFamily: 'BeVietnamPro',
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 90 * pix,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã gửi lời mời kết bạn'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * pix),
                  ),
                  backgroundColor: Colors.green.shade600,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5B7BFE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * pix),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8 * pix,
                vertical: 8 * pix,
              ),
              elevation: 0,
              minimumSize: Size(0, 30 * pix),
            ),
            child: Text(
              'Kết bạn',
              style: TextStyle(
                fontSize: 12 * pix,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * pix),
        SizedBox(
          width: 90 * pix,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * pix),
              ),
              side: BorderSide(color: Colors.grey.shade300),
              padding: EdgeInsets.symmetric(
                horizontal: 8 * pix,
                vertical: 8 * pix,
              ),
              minimumSize: Size(0, 30 * pix),
            ),
            child: Text(
              'Bỏ qua',
              style: TextStyle(
                fontSize: 12 * pix,
                color: Colors.grey.shade700,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

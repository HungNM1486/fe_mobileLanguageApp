import 'package:flutter/material.dart';
import 'package:language_app/widget/top_bar.dart';
import 'find_fr.dart';

// Danh sách bạn bè mẫu
final List<Map<String, dynamic>> friendsList = [
  {
    'name': 'Nguyen Van A',
    'level': 'Nâng cao',
    'avatar': 'lib/res/imagesLA/personlearn1.png',
  },
  {
    'name': 'Tran Thi B',
    'level': 'Trung cấp',
    'avatar': 'lib/res/imagesLA/personlearn2.png',
  },
  {
    'name': 'Le Van C',
    'level': 'Sơ cấp',
    'avatar': 'lib/res/imagesLA/personlearn3.png',
  },
  {
    'name': 'Pham Thi D',
    'level': 'Chuyên sâu',
    'avatar': 'lib/res/imagesLA/personlearn4.png',
  },
  {
    'name': 'Hoang Van E',
    'level': 'Trung cấp',
    'avatar': 'lib/res/imagesLA/personlearn5.png',
  },
];

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);
    const primaryColor = Color(0xFF5B7BFE);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  // Danh sách bạn bè
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(16 * pix),
                      itemCount: friendsList.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      itemBuilder: (context, index) {
                        final friend = friendsList[index];
                        return _buildFriendItem(pix, friend, primaryColor);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopBar(
                title: 'Danh sách bạn bè',
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindFrSreen()),
            );
          },
          backgroundColor: primaryColor,
          child: const Icon(Icons.person_add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFriendItem(
      double pix, Map<String, dynamic> friend, Color primaryColor) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8 * pix, horizontal: 0),
      leading: CircleAvatar(
        radius: 28 * pix,
        backgroundImage: AssetImage(friend['avatar']),
      ),
      title: Text(
        friend['name'],
        style: TextStyle(
          fontSize: 16 * pix,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4 * pix),
        child: Text(
          'Cấp độ: ${friend['level']}',
          style: TextStyle(
            fontSize: 14 * pix,
            color: Colors.grey[600],
          ),
        ),
      ),
      trailing: TextButton(
        onPressed: () {
          // Tương tác với bạn bè
        },
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          // ignore: deprecated_member_use
          backgroundColor: primaryColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20 * pix),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16 * pix,
            vertical: 6 * pix,
          ),
        ),
        child: Text(
          'Xem hồ sơ',
          style: TextStyle(
            fontSize: 14 * pix,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onTap: () {
        // Xem chi tiết hồ sơ bạn bè
      },
    );
  }
}

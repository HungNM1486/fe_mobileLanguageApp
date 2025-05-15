import 'package:flutter/material.dart';
import 'find_fr.dart';
import 'package:language_app/widget/top_bar.dart';
import 'share_optiones.dart';
import 'qr_scanner_screen.dart';

class AddFrScreen extends StatelessWidget {
  const AddFrScreen({super.key});

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
            colors: [
              Colors.blue.shade50.withOpacity(0.5),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16 * pix),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 100 * pix),
                      _buildHeader(pix),
                      SizedBox(height: 30 * pix),
                      _buildOptionsList(context, pix),
                      SizedBox(height: 40 * pix),
                      _buildConnectPrompt(pix),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopBar(
                title: 'Thêm bạn bè',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double pix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kết nối bạn bè',
          style: TextStyle(
            fontSize: 28 * pix,
            fontFamily: 'BeVietnamPro',
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 10 * pix),
        Text(
          'Học cùng bạn bè giúp bạn tiến bộ nhanh hơn',
          style: TextStyle(
            fontSize: 16 * pix,
            fontFamily: 'BeVietnamPro',
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsList(BuildContext context, double pix) {
    return Column(
      children: [
        // Lựa chọn "Tìm theo tên"
        _buildOptionTile(
          context: context,
          icon: Icons.person_search,
          title: 'Tìm theo tên',
          subtitle: 'Tìm kiếm người học khác theo tên người dùng',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindFrSreen()),
            );
          },
          pix: pix,
          iconBgColor: Colors.blue.shade100,
          iconColor: Colors.blue.shade700,
        ),
        SizedBox(height: 16 * pix),
        // Lựa chọn "Chia sẻ đường dẫn"
        _buildOptionTile(
          context: context,
          icon: Icons.share,
          title: 'Chia sẻ đường dẫn',
          subtitle: 'Mời bạn bè tham gia học cùng bạn',
          onTap: () {
            ShareOptions.showShareOptions(context);
          },
          pix: pix,
          iconBgColor: Colors.green.shade100,
          iconColor: Colors.green.shade700,
        ),
        SizedBox(height: 16 * pix),
        // Lựa chọn "Quét mã QR"
        _buildOptionTile(
          context: context,
          icon: Icons.qr_code_scanner,
          title: 'Quét mã QR',
          subtitle: 'Quét mã QR của bạn bè để kết nối ngay lập tức',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScannerScreen()),
            );
          },
          pix: pix,
          iconBgColor: Colors.purple.shade100,
          iconColor: Colors.purple.shade700,
        ),
      ],
    );
  }

  Widget _buildConnectPrompt(double pix) {
    return Container(
      padding: EdgeInsets.all(20 * pix),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16 * pix),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * pix),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: Colors.amber.shade600,
              size: 24 * pix,
            ),
          ),
          SizedBox(width: 15 * pix),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mẹo học tập',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontFamily: 'BeVietnamPro',
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 5 * pix),
                Text(
                  'Học cùng bạn bè giúp tăng 70% khả năng giữ thói quen học tập đều đặn!',
                  style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho mỗi lựa chọn (Tìm theo tên, Chia sẻ đường dẫn)
  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double pix,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18 * pix, vertical: 16 * pix),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * pix),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4 * pix),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * pix),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22 * pix, color: iconColor),
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
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4 * pix),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13 * pix,
                      fontFamily: 'BeVietnamPro',
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18 * pix,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

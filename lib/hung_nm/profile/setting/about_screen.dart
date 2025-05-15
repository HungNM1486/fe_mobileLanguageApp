import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch email to $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text("Giới thiệu"),
            backgroundColor: Color(0xff5B7BFE),
            foregroundColor: Colors.white,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16 * pix),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppVersionCard(pix),
                  SizedBox(height: 20 * pix),
                  _buildDescriptionCard(pix),
                  SizedBox(height: 20 * pix),
                  _buildFeatureCard(pix),
                  SizedBox(height: 20 * pix),
                  _buildContactCard(pix),
                  SizedBox(height: 20 * pix),
                  _buildLicenseCard(pix),
                  SizedBox(height: 16 * pix),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppVersionCard(double pix) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Phiên bản 1.0.0',
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5B7BFE),
            ),
          ),
          SizedBox(height: 8 * pix),
          Text(
            'Cập nhật ngày 15/04/2025',
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12 * pix),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * pix,
                  vertical: 6 * pix,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20 * pix),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16 * pix,
                      color: Colors.green,
                    ),
                    SizedBox(width: 4 * pix),
                    Text(
                      'Phiên bản mới nhất',
                      style: TextStyle(
                        fontSize: 12 * pix,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(double pix) {
    return Container(
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: const Color(0xff5B7BFE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: const Color(0xff5B7BFE),
                  size: 20 * pix,
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                'Giới thiệu',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5B7BFE),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          Text(
            'Language App là ứng dụng học ngoại ngữ được thiết kế để hỗ trợ người dùng nâng cao kỹ năng ngôn ngữ một cách dễ dàng và hiệu quả. Ứng dụng cung cấp các khóa học, mục tiêu học tập và nhiều tính năng tiện ích khác.',
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[800],
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 16 * pix),
          Text(
            'Ứng dụng được phát triển nhằm mục đích tạo ra một môi trường học tập thân thiện, giúp người dùng có thể tiếp cận việc học ngoại ngữ mọi lúc, mọi nơi trên thiết bị di động của mình.',
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[800],
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(double pix) {
    return Container(
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: const Color(0xff5B7BFE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
                child: Icon(
                  Icons.star_outline,
                  color: const Color(0xff5B7BFE),
                  size: 20 * pix,
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                'Tính năng chính',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5B7BFE),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          _buildFeatureItem(
            icon: Icons.book_outlined,
            title: 'Đa dạng khóa học',
            description: 'Nhiều khóa học cho nhiều ngoại ngữ khác nhau',
            pix: pix,
          ),
          SizedBox(height: 12 * pix),
          _buildFeatureItem(
            icon: Icons.flag_outlined,
            title: 'Mục tiêu học tập',
            description: 'Thiết lập và theo dõi mục tiêu học tập cá nhân',
            pix: pix,
          ),
          SizedBox(height: 12 * pix),
          _buildFeatureItem(
            icon: Icons.brightness_6_outlined,
            title: 'Giao diện tùy chỉnh',
            description: 'Chế độ sáng/tối và nhiều tùy chỉnh khác',
            pix: pix,
          ),
          SizedBox(height: 12 * pix),
          _buildFeatureItem(
            icon: Icons.notifications_outlined,
            title: 'Nhắc nhở học tập',
            description: 'Thiết lập thông báo để duy trì thói quen học tập',
            pix: pix,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required double pix,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8 * pix),
          decoration: BoxDecoration(
            color: const Color(0xff5B7BFE).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8 * pix),
          ),
          child: Icon(
            icon,
            color: const Color(0xff5B7BFE),
            size: 18 * pix,
          ),
        ),
        SizedBox(width: 12 * pix),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4 * pix),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14 * pix,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(double pix) {
    return Container(
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: const Color(0xff5B7BFE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
                child: Icon(
                  Icons.email_outlined,
                  color: const Color(0xff5B7BFE),
                  size: 20 * pix,
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                'Liên hệ',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5B7BFE),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          InkWell(
            onTap: () => _launchEmail('languageapp.support@gmail.com'),
            borderRadius: BorderRadius.circular(10 * pix),
            child: Container(
              padding: EdgeInsets.all(12 * pix),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10 * pix),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 20 * pix,
                    color: const Color(0xff5B7BFE),
                  ),
                  SizedBox(width: 12 * pix),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email hỗ trợ',
                          style: TextStyle(
                            fontSize: 14 * pix,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4 * pix),
                        Text(
                          'languageapp.support@gmail.com',
                          style: TextStyle(
                            fontSize: 14 * pix,
                            color: const Color(0xff5B7BFE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14 * pix,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12 * pix),
          InkWell(
            onTap: () => _launchURL('https://languageapp.com'),
            borderRadius: BorderRadius.circular(10 * pix),
            child: Container(
              padding: EdgeInsets.all(12 * pix),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10 * pix),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    size: 20 * pix,
                    color: const Color(0xff5B7BFE),
                  ),
                  SizedBox(width: 12 * pix),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Website',
                          style: TextStyle(
                            fontSize: 14 * pix,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4 * pix),
                        Text(
                          'www.languageapp.com',
                          style: TextStyle(
                            fontSize: 14 * pix,
                            color: const Color(0xff5B7BFE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14 * pix,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseCard(double pix) {
    return Container(
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: const Color(0xff5B7BFE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: const Color(0xff5B7BFE),
                  size: 20 * pix,
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                'Thông tin bản quyền',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5B7BFE),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          Text(
            'Ứng dụng Language App © 2025',
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8 * pix),
          Text(
            'Bản quyền thuộc về nhóm phát triển. Mọi hành vi sao chép, phân phối không được phép đều vi phạm bản quyền.',
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 12 * pix),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'Điều khoản dịch vụ',
                  style: TextStyle(
                    fontSize: 14 * pix,
                    color: const Color(0xff5B7BFE),
                  ),
                ),
              ),
              Text(
                '|',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14 * pix,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Chính sách riêng tư',
                  style: TextStyle(
                    fontSize: 14 * pix,
                    color: const Color(0xff5B7BFE),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

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

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch call to $phone');
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
            title: Text("Hỗ trợ"),
            backgroundColor: Color(0xff5B7BFE),
            foregroundColor: Colors.white,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16 * pix),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppDescription(pix),
                  SizedBox(height: 24 * pix),
                  _buildDeveloperTeam(pix),
                  SizedBox(height: 24 * pix),
                  _buildContactInfo(pix, context),
                  SizedBox(height: 24 * pix),
                  _buildFAQSection(pix),
                  SizedBox(height: 24 * pix),
                  _buildSocialLinks(pix),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDescription(double pix) {
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
                  Icons.language,
                  color: const Color(0xff5B7BFE),
                  size: 20 * pix,
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                'Giới thiệu ứng dụng',
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
            'Ứng dụng Language App được phát triển bởi nhóm sinh viên B21DCCN412 nhằm hỗ trợ việc học ngoại ngữ một cách hiệu quả. Ứng dụng cung cấp các tính năng học tập đa dạng, bài học theo cấp độ và công cụ theo dõi tiến trình.',
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperTeam(double pix) {
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
                  Icons.people,
                  color: const Color(0xff5B7BFE),
                  size: 20 * pix,
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                'Nhóm phát triển',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5B7BFE),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          _buildMemberCard(
              'Nguyễn Mạnh Hùng', 'B21DCCN412', 'Trưởng nhóm', pix),
          SizedBox(height: 12 * pix),
          _buildMemberCard('Nguyễn Văn Phú', 'B21DCCN412', 'Thành viên', pix),
          SizedBox(height: 12 * pix),
          _buildMemberCard('Nguyễn Minh Hồng', 'B21DCCN412', 'Thành viên', pix),
          SizedBox(height: 12 * pix),
          _buildMemberCard('Trần Duy Anh', 'B21DCCN412', 'Thành viên', pix),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
      String name, String studentId, String role, double pix) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * pix, vertical: 10 * pix),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10 * pix),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18 * pix,
            backgroundColor: Colors.grey[300],
            child: Text(
              name.substring(0, 1),
              style: TextStyle(
                fontSize: 16 * pix,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 12 * pix),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2 * pix),
                Text(
                  '$studentId - $role',
                  style: TextStyle(
                    fontSize: 12 * pix,
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

  Widget _buildContactInfo(double pix, BuildContext context) {
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
                  Icons.contact_support,
                  color: const Color(0xff5B7BFE),
                  size: 20 * pix,
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                'Liên hệ hỗ trợ',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5B7BFE),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          _buildContactItem(
            icon: Icons.email,
            title: 'Email',
            content: 'hungnm1486@gmail.com',
            onTap: () => _launchEmail('hungnm1486@gmail.com'),
            pix: pix,
          ),
          SizedBox(height: 12 * pix),
          _buildContactItem(
            icon: Icons.phone,
            title: 'Hotline',
            content: '+84 964 175 516 (8:00 - 17:00)',
            onTap: () => _launchPhone('+84964175516'),
            pix: pix,
          ),
          SizedBox(height: 12 * pix),
          _buildContactItem(
            icon: Icons.location_on,
            title: 'Địa chỉ',
            content: 'Km10, Đường Nguyễn Trãi, Hà Đông, Hà Nội',
            onTap: () {},
            pix: pix,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    required Function onTap,
    required double pix,
  }) {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(10 * pix),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * pix, vertical: 10 * pix),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10 * pix),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8 * pix),
              decoration: BoxDecoration(
                color: const Color(0xff5B7BFE).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xff5B7BFE),
                size: 16 * pix,
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
                      fontSize: 14 * pix,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2 * pix),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14 * pix,
                      color: Colors.grey[600],
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
    );
  }

  Widget _buildFAQSection(double pix) {
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
                  Icons.question_answer,
                  color: const Color(0xff5B7BFE),
                  size: 20 * pix,
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                'Câu hỏi thường gặp',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5B7BFE),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          _buildFAQItem(
            'Làm thế nào để đặt lại mật khẩu?',
            'Vào phần Cài đặt > Thông tin cá nhân > Đổi mật khẩu và làm theo hướng dẫn.',
            pix,
          ),
          SizedBox(height: 12 * pix),
          _buildFAQItem(
            'Tôi có thể học ngoại tuyến không?',
            'Có, bạn có thể tải nội dung về để học ngoại tuyến trong phần Bài học.',
            pix,
          ),
          SizedBox(height: 12 * pix),
          _buildFAQItem(
            'Làm thế nào để thay đổi ngôn ngữ học?',
            'Vào phần Cài đặt > Khóa học > Ngôn ngữ để thay đổi ngôn ngữ bạn muốn học.',
            pix,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, double pix) {
    return Container(
      padding: EdgeInsets.all(12 * pix),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10 * pix),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.help_outline,
                size: 18 * pix,
                color: const Color(0xff5B7BFE),
              ),
              SizedBox(width: 8 * pix),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 14 * pix,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * pix),
          Padding(
            padding: EdgeInsets.only(left: 26 * pix),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14 * pix,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(double pix) {
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
                  Icons.share,
                  color: const Color(0xff5B7BFE),
                  size: 20 * pix,
                ),
              ),
              SizedBox(width: 12 * pix),
              Text(
                'Theo dõi chúng tôi',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5B7BFE),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialButton(Icons.facebook, 'Facebook', Colors.blue,
                  () => _launchURL('https://facebook.com'), pix),
              _buildSocialButton(Icons.pending, 'Github', Colors.black87,
                  () => _launchURL('https://github.com'), pix),
              _buildSocialButton(Icons.email, 'Email', Colors.red,
                  () => _launchEmail('hungnm1486@gmail.com'), pix),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color,
      VoidCallback onTap, double pix) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10 * pix),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * pix, vertical: 10 * pix),
        child: Column(
          children: [
            Container(
              width: 40 * pix,
              height: 40 * pix,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 22 * pix,
              ),
            ),
            SizedBox(height: 8 * pix),
            Text(
              label,
              style: TextStyle(
                fontSize: 12 * pix,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

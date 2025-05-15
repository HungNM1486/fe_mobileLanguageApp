import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:language_app/provider/user_provider.dart';

import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  File? _avatarImage;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;
  // Biến này dùng để kiểm soát việc hiển thị ảnh local hay ảnh từ network
  bool _useLocalImage = false;
  // Lưu URL của ảnh từ server để tránh cache
  String _profileImageUrl = '';
  // Thêm timestamp để vô hiệu hóa cache khi tải lại ảnh
  String _cacheKey = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _useLocalImage = false; // Reset về hiển thị ảnh từ server
    });

    try {
      // Tạo một UserProvider mới để tránh cache
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // Gọi API để lấy dữ liệu mới nhất từ server
      await userProvider.getUserInfo(context);

      final user = userProvider.user;
      if (user != null) {
        setState(() {
          _firstNameController.text = user.firstname;
          _lastNameController.text = user.lastname;
          _emailController.text = user.email;

          // Cập nhật URL ảnh đại diện
          if (user.profile_image_url.isNotEmpty) {
            _profileImageUrl = user.profile_image_url;
            // Thêm tham số để tránh cache
            if (!_profileImageUrl.contains('?')) {
              _profileImageUrl += '?v=$_cacheKey';
            } else {
              _profileImageUrl += '&v=$_cacheKey';
            }
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải thông tin người dùng: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      try {
        // Nén ảnh trước khi hiển thị
        final compressedImage = await compressImage(File(pickedFile.path));
        setState(() {
          _avatarImage = compressedImage;
          _useLocalImage = true; // Chuyển sang hiển thị ảnh local
        });
      } catch (e) {
        print('Lỗi khi xử lý ảnh: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xử lý ảnh. Vui lòng thử lại.')),
        );
      }
    }
  }

  // Hàm tiện ích để nén ảnh
  Future<File> compressImage(File file) async {
    try {
      // Đọc ảnh gốc
      final originalImage = img.decodeImage(await file.readAsBytes());
      if (originalImage == null) throw Exception('Không thể đọc ảnh');

      // Xác định kích thước mới cho ảnh
      int maxWidth = 800; // Giới hạn chiều rộng tối đa
      int maxHeight = 800; // Giới hạn chiều cao tối đa

      // Tính toán tỷ lệ để giữ nguyên proporsions
      double ratio =
          min(maxWidth / originalImage.width, maxHeight / originalImage.height);

      if (ratio >= 1.0) return file; // Ảnh đã đủ nhỏ, không cần nén

      // Tạo ảnh mới với kích thước đã giảm
      final resizedImage = img.copyResize(
        originalImage,
        width: (originalImage.width * ratio).round(),
        height: (originalImage.height * ratio).round(),
      );

      // Nén ảnh thành JPEG
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);

      // Lưu ảnh vào file tạm
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('Lỗi khi nén ảnh: $e');
      return file; // Trả về file gốc nếu có lỗi xảy ra
    }
  }

  Future<void> _updateProfile() async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Sử dụng phương thức cập nhật thông tin người dùng
      final success = await userProvider.updateUserProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        profileImage: _useLocalImage
            ? _avatarImage
            : null, // Chỉ gửi ảnh nếu đã chọn ảnh mới
      );

      if (success) {
        // Cập nhật cache key để đảm bảo tải lại ảnh mới
        _cacheKey = DateTime.now().millisecondsSinceEpoch.toString();

        // Tải lại dữ liệu người dùng từ server
        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công')),
        );

        // Sau khi cập nhật thành công, reset lại trạng thái sử dụng ảnh local
        setState(() {
          _useLocalImage = false;
          _avatarImage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Không thể cập nhật thông tin. Vui lòng thử lại sau.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    // Phần code hiện tại của bạn...
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);

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
        backgroundColor: Colors.transparent,
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Positioned(
                    top: 100 * pix,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16 * pix),
                        child: Column(
                          children: [
                            _buildAvatarSection(pix),
                            SizedBox(height: 24 * pix),

                            // Hiển thị thông báo lỗi nếu có
                            if (_errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12 * pix),
                                margin: EdgeInsets.only(bottom: 16 * pix),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12 * pix),
                                  border:
                                      Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 14 * pix,
                                  ),
                                ),
                              ),

                            _buildInfoCard(pix),
                            SizedBox(height: 16 * pix),
                            _buildSaveButton(pix),
                            SizedBox(height: 16 * pix),
                            _buildDeleteAccountButton(pix),
                            SizedBox(height: 32 * pix),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: TopBar(title: "Thông tin cá nhân"),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAvatarSection(double pix) {
    Widget avatarWidget;

    // Ưu tiên hiển thị ảnh local nếu người dùng đã chọn ảnh mới
    if (_useLocalImage && _avatarImage != null) {
      avatarWidget = Image.file(
        _avatarImage!,
        fit: BoxFit.cover,
        width: 120 * pix,
        height: 120 * pix,
      );
    }
    // Nếu không có ảnh local, hiển thị ảnh từ server
    else if (_profileImageUrl.isNotEmpty) {
      avatarWidget = CachedNetworkImage(
        imageUrl: _profileImageUrl,
        fit: BoxFit.cover,
        width: 120 * pix,
        height: 120 * pix,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.person,
          size: 60 * pix,
          color: Colors.grey,
        ),
        // Quan trọng: không lưu cache để luôn tải lại ảnh mới
        cacheManager: null,
      );
    }
    // Nếu không có cả ảnh local và ảnh từ server, hiển thị ảnh mặc định
    else {
      avatarWidget = Image.asset(
        'lib/res/imagesLA/vietnam.jpg',
        fit: BoxFit.cover,
        width: 120 * pix,
        height: 120 * pix,
      );
    }

    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 120 * pix,
              height: 120 * pix,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4 * pix,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(child: avatarWidget),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: const Color(0xff5B7BFE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2 * pix,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20 * pix,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(double pix) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * pix),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * pix),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Thông tin cá nhân", pix),
            SizedBox(height: 16 * pix),
            _buildTextField("Họ", _lastNameController, Icons.person, pix),
            SizedBox(height: 16 * pix),
            _buildTextField(
                "Tên", _firstNameController, Icons.person_outline, pix),
            SizedBox(height: 16 * pix),
            _buildSectionTitle("Thông tin tài khoản", pix),
            SizedBox(height: 16 * pix),
            _buildReadOnlyField("Email", _emailController, Icons.email, pix),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double pix) {
    return Padding(
      padding: EdgeInsets.only(left: 4 * pix, bottom: 4 * pix),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18 * pix,
          fontWeight: FontWeight.bold,
          color: const Color(0xff5B7BFE),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    double pix,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * pix, bottom: 8 * pix),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12 * pix),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.all(8 * pix),
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: const Color(0xff5B7BFE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10 * pix),
                ),
                child: Icon(
                  icon,
                  size: 20 * pix,
                  color: const Color(0xff5B7BFE),
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16 * pix,
                horizontal: 8 * pix,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(
    String label,
    TextEditingController controller,
    IconData icon,
    double pix,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * pix, bottom: 8 * pix),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12 * pix),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: true,
            enabled: false,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.all(8 * pix),
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10 * pix),
                ),
                child: Icon(
                  icon,
                  size: 20 * pix,
                  color: Colors.grey[600],
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16 * pix,
                horizontal: 8 * pix,
              ),
            ),
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(double pix) {
    return Container(
      width: double.infinity,
      height: 56 * pix,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff5B7BFE),
            Color(0xff7381FF),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12 * pix),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff5B7BFE).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * pix),
          ),
        ),
        child: _isUpdating
            ? SizedBox(
                width: 24 * pix,
                height: 24 * pix,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 20 * pix),
                  SizedBox(width: 8 * pix),
                  Text(
                    "Lưu thay đổi",
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(double pix) {
    return Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showDeleteAccountDialog(context),
        icon: Icon(
          Icons.delete_forever,
          color: Colors.red[600],
          size: 20 * pix,
        ),
        label: Text(
          "Xóa tài khoản",
          style: TextStyle(
            fontSize: 16 * pix,
            color: Colors.red[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12 * pix),
        ),
      ),
    );
  }
}

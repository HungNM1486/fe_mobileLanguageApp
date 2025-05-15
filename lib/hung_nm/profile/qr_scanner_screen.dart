import 'package:flutter/material.dart';
import 'dart:async';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _flashOn = false;
  bool _isScanning = true;
  String _scanResult = '';
  bool _showResult = false;

  // Animation controller cho hiệu ứng quét
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // Lặp lại animation
    _animationController.repeat(reverse: true);

    // Giả lập quét mã QR
    Timer(const Duration(seconds: 5), () {
      // Giả lập kết quả quét
      if (mounted) {
        setState(() {
          _isScanning = false;
          _showResult = true;
          _scanResult = 'user_id_123456';
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quét mã QR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * pix,
            fontFamily: 'BeVietnamPro',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24 * pix,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 24 * pix,
            ),
            onPressed: () {
              setState(() {
                _flashOn = !_flashOn;
              });
              // Ở đây sẽ thêm code điều khiển đèn flash thực tế
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(_flashOn ? 'Đã bật đèn flash' : 'Đã tắt đèn flash'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: Colors.grey.shade800,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * pix),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Center(
              child: Text(
                'Camera Preview',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14 * pix,
                ),
              ),
            ),
          ),

          // QR frame overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250 * pix,
                  height: 250 * pix,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2 * pix),
                    borderRadius: BorderRadius.circular(20 * pix),
                  ),
                  child: Stack(
                    children: [
                      // Animated scan line
                      if (_isScanning)
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Positioned(
                              top: 250 * pix * _animation.value - 2 * pix,
                              left: 10 * pix,
                              right: 10 * pix,
                              child: Container(
                                height: 4 * pix,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.blue.shade400,
                                      Colors.blue.shade400,
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.3, 0.7, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(4 * pix),
                                ),
                              ),
                            );
                          },
                        ),

                      // QR corners
                      _buildCorner(top: -1, left: -1, pix: pix), // top-left
                      _buildCorner(top: -1, right: -1, pix: pix), // top-right
                      _buildCorner(
                          bottom: -1, left: -1, pix: pix), // bottom-left
                      _buildCorner(
                          bottom: -1, right: -1, pix: pix), // bottom-right
                    ],
                  ),
                ),
                SizedBox(height: 24 * pix),
                Text(
                  _isScanning
                      ? 'Căn chỉnh mã QR vào khung hình'
                      : 'Đã quét xong',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * pix,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
                SizedBox(height: 8 * pix),
                Text(
                  _isScanning ? 'Giữ điện thoại ổn định' : 'Xử lý kết quả...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20 * pix),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24 * pix),
                  topRight: Radius.circular(24 * pix),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Không tìm thấy mã QR?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * pix,
                      fontFamily: 'BeVietnamPro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16 * pix),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.photo_library,
                        label: 'Chọn từ thư viện',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Tính năng đang được phát triển'),
                              backgroundColor: Colors.grey.shade800,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        pix: pix,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Result overlay
          if (_showResult) _buildResultOverlay(context, pix),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? right,
    double? bottom,
    double? left,
    required double pix,
  }) {
    return Positioned(
      top: top != null ? top * pix : null,
      right: right != null ? right * pix : null,
      bottom: bottom != null ? bottom * pix : null,
      left: left != null ? left * pix : null,
      child: Container(
        width: 30 * pix,
        height: 30 * pix,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? BorderSide(color: Colors.blue.shade400, width: 4 * pix)
                : BorderSide.none,
            right: right != null
                ? BorderSide(color: Colors.blue.shade400, width: 4 * pix)
                : BorderSide.none,
            bottom: bottom != null
                ? BorderSide(color: Colors.blue.shade400, width: 4 * pix)
                : BorderSide.none,
            left: left != null
                ? BorderSide(color: Colors.blue.shade400, width: 4 * pix)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double pix,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10 * pix),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * pix,
          vertical: 12 * pix,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32 * pix,
            ),
            SizedBox(height: 8 * pix),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * pix,
                fontFamily: 'BeVietnamPro',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultOverlay(BuildContext context, double pix) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32 * pix),
          padding: EdgeInsets.all(24 * pix),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24 * pix),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70 * pix,
                height: 70 * pix,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 40 * pix,
                  color: Colors.green.shade600,
                ),
              ),
              SizedBox(height: 20 * pix),
              Text(
                'Quét thành công',
                style: TextStyle(
                  fontSize: 20 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12 * pix),
              Text(
                'Đã tìm thấy người dùng',
                style: TextStyle(
                  fontSize: 14 * pix,
                  color: Colors.grey.shade700,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              SizedBox(height: 24 * pix),
              Container(
                padding: EdgeInsets.all(12 * pix),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12 * pix),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40 * pix,
                      height: 40 * pix,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.blue.shade600,
                        size: 24 * pix,
                      ),
                    ),
                    SizedBox(width: 16 * pix),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nguyễn Văn A',
                            style: TextStyle(
                              fontSize: 16 * pix,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'BeVietnamPro',
                            ),
                          ),
                          SizedBox(height: 4 * pix),
                          Text(
                            'ID: $_scanResult',
                            style: TextStyle(
                              fontSize: 12 * pix,
                              color: Colors.grey.shade600,
                              fontFamily: 'BeVietnamPro',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24 * pix),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isScanning = true;
                          _showResult = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12 * pix),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * pix),
                        ),
                      ),
                      child: Text(
                        'Quét lại',
                        style: TextStyle(
                          fontSize: 14 * pix,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * pix),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(_scanResult);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12 * pix),
                        backgroundColor: Colors.blue.shade600,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * pix),
                        ),
                      ),
                      child: Text(
                        'Kết nối',
                        style: TextStyle(
                          fontSize: 14 * pix,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

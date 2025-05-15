import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

// Modern gallery with gestures and animations
class ModernGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ModernGallery({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ModernGallery> createState() => _ModernGalleryState();
}

class _ModernGalleryState extends State<ModernGallery>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Set system UI for immersive view
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    // Reset system UI when exiting gallery
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: FadeTransition(
          opacity: ReverseAnimation(
              _fadeAnimation), // Use reverse to fade in/out correctly
          child: AppBar(
            backgroundColor: Colors.black.withOpacity(0.5),
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${_currentIndex + 1}/${widget.imageUrls.length}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.share_rounded, color: Colors.white),
                ),
                onPressed: () {
                  // Implement share functionality
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Sharing image...'),
                    duration: Duration(seconds: 1),
                  ));
                },
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Main photo gallery
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              pageController: _pageController,
              itemCount: widget.imageUrls.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.imageUrls[index]),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2.5,
                  heroAttributes: null,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.white70, size: 40),
                          SizedBox(height: 16),
                          Text(
                            'Không thể tải hình ảnh',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: event == null || event.expectedTotalBytes == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
              ),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundDecoration: BoxDecoration(color: Colors.black),
            ),

            // Bottom controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FadeTransition(
                opacity: ReverseAnimation(_fadeAnimation),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      stops: [0.0, 1.0],
                    ),
                  ),
                  child: widget.imageUrls.length > 1
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(widget.imageUrls.length, (index) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: _currentIndex == index ? 20 : 8,
                              height: 8,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? Colors.white
                                    : Colors.white38,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        )
                      : SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

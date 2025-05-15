import 'package:flutter/material.dart';
import 'package:language_app/models/topic_model.dart';
import 'package:language_app/models/vocabulary_model.dart';
import 'dart:math' as math;
import 'package:language_app/phu_nv/widget/difficulty_rating_dia.dart';
import 'package:language_app/phu_nv/widget/flash_card.dart';
import 'package:language_app/provider/vocabulary_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key, this.topic});
  final TopicModel? topic;

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _flipController;
  late AnimationController _transitionController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isAnimating = false;
  List<VocabularyModel> cards = [];

  @override
  void initState() {
    super.initState();

    // Page controller for card transitions that allows swiping
    _pageController = PageController();

    // Flip animation controller
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    // Card transition animation controller
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    // Listen to flip animation to update the flip state
    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isFlipped = !_isFlipped;
          _isAnimating = false;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isFlipped = !_isFlipped;
          _isAnimating = false;
        });
      } else if (status == AnimationStatus.forward ||
          status == AnimationStatus.reverse) {
        setState(() {
          _isAnimating = true;
        });
      }
    });

    // Update the page controller listener to track current page
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentIndex) {
        setState(() {
          _currentIndex = _pageController.page!.round();
          _isFlipped = false;
          // Reset flip controller
          if (_flipController.value != 0) {
            _flipController.reset();
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final vocabProvider =
        Provider.of<VocabularyProvider>(context, listen: false);

    try {
      if (widget.topic != null) {
        await vocabProvider.fetchVocabulariesByTopic(
            int.tryParse(widget.topic!.id) ?? 0, widget.topic!.isDone);
      } else {
        await vocabProvider.fetchVocabRandom();
      }
      setState(() {
        cards = vocabProvider.vocabularies;
      });
    } catch (e) {
      // Xử lý lỗi nếu cần
      print('Error loading topics: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flipController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isAnimating) return;

    // Thay đổi logic flip để giải quyết vấn đề khi nhấp lần thứ 3
    if (_flipController.status == AnimationStatus.completed) {
      _flipController.reverse();
    } else if (_flipController.status == AnimationStatus.dismissed) {
      _flipController.forward();
    } else if (_flipController.status == AnimationStatus.reverse) {
      // Nếu đang trong quá trình đảo ngược, không làm gì cả
      return;
    } else if (_flipController.status == AnimationStatus.forward) {
      // Nếu đang trong quá trình tiến tới, không làm gì cả
      return;
    }
  }

  void _showDifficultyRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DifficultyRatingDialog(
          onRatingSelected: (difficulty) {
            // Move to next card after rating
            if (_currentIndex < cards.length - 1) {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              _showCompletionDialog();
            }
          },
        );
      },
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hoàn thành'),
          content: Text('Bạn đã hoàn thành tất cả các từ vựng!'),
          actions: [
            TextButton(
              child: Text('Làm lại'),
              onPressed: () {
                Navigator.of(context).pop();
                _restartSession();
              },
            ),
            TextButton(
              child: Text('Thoát'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close the vocabulary screen
              },
            ),
          ],
        );
      },
    );
  }

  void _restartSession() {
    setState(() {
      _currentIndex = 0;
      _pageController.jumpToPage(0);
      _isFlipped = false;
      // Reset flip controller
      _flipController.reset();
    });
  }

  void _nextCard() {
    if (_currentIndex < cards.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionDialog();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

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
        child: Consumer<VocabularyProvider>(
            builder: (context, vocabProvider, child) {
          if (vocabProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (cards.isEmpty) {
            return Column(
              children: [
                TopBar(
                  title: "Từ vựng ${widget.topic?.topic ?? "ngẫu nhiên"} ",
                  isBack: true,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Chưa có từ vựng nào cho chủ đề này",
                      style: TextStyle(
                        fontSize: 16 * pix,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              TopBar(
                title: "Từ vựng ${widget.topic?.topic ?? "ngẫu nhiên"} ",
                isBack: true,
              ),
              Expanded(
                child: Container(
                  width: size.width,
                  padding: EdgeInsets.all(12 * pix),
                  child: Column(
                    children: [
                      // Progress bar
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Từ ${_currentIndex + 1}/${cards.length}',
                              style: TextStyle(
                                fontSize: 16 * pix,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'BeVietnamPro',
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline, size: 20 * pix),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Hướng dẫn '),
                                      content: Text(
                                        'Nhấn vào thẻ để lật lại và xem nghĩa. Vuốt trái hoặc phải để chuyển qua từ vựng khác. Nhấn nút đánh giá độ khó để đánh giá từ vựng hiện tại.',
                                        style: TextStyle(
                                          fontSize: 14 * pix,
                                          fontFamily: 'BeVietnamPro',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text('Đóng'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10 * pix),
                      Expanded(
                        child: GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity! > 0) {
                              // Swipe right - go to previous card
                              _previousCard();
                            } else if (details.primaryVelocity! < 0) {
                              // Swipe left - go to next card
                              _nextCard();
                            }
                          },
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              return SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 16 * pix,
                                        right: 16 * pix,
                                      ),
                                      child: GestureDetector(
                                        onTap: _flipCard,
                                        child: AnimatedBuilder(
                                          animation: _flipAnimation,
                                          builder: (context, child) {
                                            return _buildFlipCard(index, pix);
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 20 * pix),
                                      child: ElevatedButton(
                                        onPressed: _showDifficultyRatingDialog,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24 * pix,
                                            vertical: 12 * pix,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12 * pix),
                                          ),
                                        ),
                                        child: Text(
                                          'Đánh giá độ khó',
                                          style: TextStyle(
                                            fontSize: 16 * pix,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8 * pix),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.arrow_back_ios,
                                                color: Colors.blue),
                                            onPressed: _previousCard,
                                          ),
                                          SizedBox(width: 16 * pix),
                                          IconButton(
                                            icon: Icon(Icons.arrow_forward_ios,
                                                color: Colors.blue),
                                            onPressed: _nextCard,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFlipCard(int index, double pix) {
    // Calculate the rotation based on the animation value
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateY(_flipAnimation.value * math.pi);

    // Determine whether to show front or back content based on rotation
    bool showFrontSide = _flipAnimation.value <= 0.5;

    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: showFrontSide
          ? FlashCard(
              title: cards[index].word,
              description: cards[index].example,
              image: "",
              isFlipped: false,
            )
          : Transform(
              transform: Matrix4.identity()..rotateY(math.pi),
              alignment: Alignment.center,
              child: FlashCard(
                title: cards[index].definition,
                description: cards[index].exampleTranslation,
                image: cards[index].imageUrl,
                isFlipped: true,
              ),
            ),
    );
  }
}

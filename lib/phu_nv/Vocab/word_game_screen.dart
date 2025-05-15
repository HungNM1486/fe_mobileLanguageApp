import 'dart:math';
import 'package:flutter/material.dart';
import 'package:language_app/models/vocabulary_model.dart';
import 'package:language_app/phu_nv/widget/network_img.dart';
import 'package:language_app/provider/vocabulary_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class WordScrambleGame extends StatefulWidget {
  const WordScrambleGame({
    Key? key,
  }) : super(key: key);

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame>
    with TickerProviderStateMixin {
  // Initialize with empty list instead of using late
  List<VocabularyModel> _gameVocabularies = [];
  // Use nullable type for _currentWord since it might not be available immediately
  VocabularyModel? _currentWord;
  List<String> _scrambledLetters = [];
  List<String?> _answerLetters = [];
  int _currentIndex = 0;
  int _score = 0;
  int _lives = 3;
  bool _isCorrect = false;
  bool _isWrong = false;
  bool _isGameOver = false;
  bool _isLoading = true; // Add loading state
  final Random _random = Random();

  // Animation khi trả lời sai (rung)
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  // Animation khi chọn chữ cái (nảy)
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  // Animation khi chuyển từ (mờ dần)
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Only load data in initState, don't call _initGame() yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final vocabProvider =
        Provider.of<VocabularyProvider>(context, listen: false);

    try {
      await vocabProvider.fetchVocabRandom();

      setState(() {
        _gameVocabularies = vocabProvider.vocabularies..shuffle();
        _isLoading = false;
      });

      // Only initialize the game after data is loaded
      _initGame();
    } catch (e) {
      // Xử lý lỗi nếu cần
      print('Error loading topics: $e');
      setState(() {
        _isLoading = false;
        _isGameOver = true; // Set game over if we can't load data
      });
    }
  }

//Khởi tạo trò chơi: xáo trộn danh sách từ và tải từ đầu tiên
  void _initGame() {
    if (_gameVocabularies.isNotEmpty) {
      _loadNextWord();
    } else {
      setState(() {
        _isGameOver = true;
      });
    }
  }

  void _loadNextWord() {
    if (_currentIndex < _gameVocabularies.length) {
      // Đặt lại fade controller về 0 trước khi cập nhật state
      _fadeController.value = 0.0;

      setState(() {
        _currentWord = _gameVocabularies[_currentIndex];
        _scrambleWord(_currentWord!.word);
        _answerLetters = List.filled(_currentWord!.word.length, null);
        _isCorrect = false;
        _isWrong = false;
      });

      // Sau khi cập nhật state và UI đã rebuild, bắt đầu hiệu ứng fade in
      _fadeController.forward();
    } else {
      setState(() {
        _isGameOver = true;
      });
    }
  }

//Xáo trộn các chữ cái nhưng đảm bảo không trùng với từ gốc
  void _scrambleWord(String word) {
    List<String> letters = word.toUpperCase().split('');
    do {
      letters.shuffle(_random);
    } while (letters.join() == word.toUpperCase());

    setState(() {
      _scrambledLetters = letters;
    });
  }

//Xử lý khi người chơi chọn một chữ cái
  void _selectLetter(String letter, int index) {
    if (_isCorrect || _isWrong) return;

    int emptySlot = _answerLetters.indexOf(null);
    if (emptySlot != -1) {
      setState(() {
        _answerLetters[emptySlot] = letter;
        _scrambledLetters[index] = '';
      });

      if (!_answerLetters.contains(null)) {
        _checkAnswer();
      }

      _bounceController.forward(from: 0.0);
    }
  }

//Xóa chữ cái khỏi ô trả lời và trả lại bảng chữ cái xáo trộn
  void _removeLetter(int index) {
    if (_isCorrect || _isWrong) return;

    if (_answerLetters[index] != null) {
      String letter = _answerLetters[index]!;

      int emptySlot = _scrambledLetters.indexOf('');

      setState(() {
        _scrambledLetters[emptySlot] = letter;
        _answerLetters[index] = null;
      });
    }
  }

//So sánh đáp án với từ gốc
  void _checkAnswer() {
    String answer = _answerLetters.join();

    if (answer == _currentWord!.word.toUpperCase()) {
      setState(() {
        _isCorrect = true;
        _score += 10;
      });

      _bounceController.forward(from: 0.0);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _loadNextWord();
          });
        }
      });
    } else {
      setState(() {
        _isWrong = true;
        _lives--;
      });

      _shakeController.forward(from: 0.0);

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          if (_lives <= 0) {
            setState(() {
              _isGameOver = true;
            });
          } else {
            setState(() {
              _isWrong = false;
              _answerLetters = List.filled(_currentWord!.word.length, null);
              _scrambleWord(_currentWord!.word);
            });
          }
        }
      });
    }
  }

  void _resetGame() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _lives = 3;
      _isGameOver = false;
    });
    _initGame();
  }

  void _showHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Gợi ý',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Định nghĩa: ${_currentWord!.definition}'),
            const SizedBox(height: 8),
            Text('Ví dụ: ${_currentWord!.example}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
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
            colors: [Colors.purple.shade200, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Column(
          children: [
            TopBar(
              title: "Trò chơi từ vựng",
              isBack: true,
            ),
            Expanded(
              child: _isLoading
                  ? _buildLoadingScreen(pix)
                  : _isGameOver
                      ? _buildGameOverScreen(pix)
                      : _buildGameScreen(pix),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(double pix) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20 * pix),
          Text(
            'Đang tải từ vựng...',
            style: TextStyle(
              fontSize: 16 * pix,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(double pix) {
    if (_currentWord == null) {
      return Center(
        child: Text(
          'Không có từ vựng nào',
          style: TextStyle(
            fontSize: 18 * pix,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(3, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 4 * pix),
                    child: Icon(
                      index < _lives ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 24 * pix,
                    ),
                  );
                }),
              ),
              // Score
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * pix,
                  vertical: 6 * pix,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12 * pix),
                ),
                child: Text(
                  'Điểm: $_score',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Word image - Đảm bảo key duy nhất để buộc rebuild khi từ thay đổi
                if (_currentWord!.imageUrl.isNotEmpty)
                  Container(
                    key: ValueKey(_currentWord!
                        .id), // Thêm key để buộc widget rebuild khi từ vựng thay đổi
                    width: 180 * pix,
                    height: 180 * pix,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10 * pix),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10 * pix),
                      child: NetworkImageWidget(
                        key: ValueKey(
                            'img-${_currentWord!.id}'), // Thêm key cho image widget
                        url: _currentWord!.imageUrl,
                        width: 180,
                        height: 180,
                      ),
                    ),
                  ),

                SizedBox(height: 16 * pix),

                ElevatedButton.icon(
                  onPressed: _showHint,
                  icon: Icon(Icons.lightbulb_outline, size: 20 * pix),
                  label: Text(
                    'Gợi ý',
                    style: TextStyle(fontSize: 14 * pix),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * pix,
                      vertical: 8 * pix,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ShakeTransition(
            animation: _shakeAnimation,
            isWrong: _isWrong,
            child: Container(
              padding: EdgeInsets.all(16 * pix),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16 * pix),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: _isCorrect
                      ? Colors.green
                      : _isWrong
                          ? Colors.red
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_answerLetters.length, (index) {
                  return GestureDetector(
                    onTap: () => _removeLetter(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 4 * pix),
                      width: 30 * pix,
                      height: 40 * pix,
                      decoration: BoxDecoration(
                        color: _answerLetters[index] != null
                            ? Colors.purple.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8 * pix),
                        boxShadow: _answerLetters[index] != null
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: _answerLetters[index] != null
                            ? ScaleTransition(
                                scale: _bounceAnimation,
                                child: Text(
                                  _answerLetters[index]!,
                                  style: TextStyle(
                                    fontSize: 20 * pix,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 12 * pix),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8 * pix,
            runSpacing: 8 * pix,
            children: List.generate(_scrambledLetters.length, (index) {
              if (_scrambledLetters[index].isEmpty) {
                return SizedBox(
                  width: 40 * pix,
                  height: 50 * pix,
                );
              }

              return GestureDetector(
                onTap: () => _selectLetter(_scrambledLetters[index], index),
                child: Container(
                  width: 40 * pix,
                  height: 50 * pix,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade400,
                    borderRadius: BorderRadius.circular(10 * pix),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _scrambledLetters[index],
                      style: TextStyle(
                        fontSize: 20 * pix,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8 * pix),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen(double pix) {
    return Center(
      child: Container(
        width: 300 * pix,
        padding: EdgeInsets.all(24 * pix),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20 * pix),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _lives > 0
                  ? Icons.emoji_events
                  : Icons.sentiment_very_dissatisfied,
              size: 80 * pix,
              color: _lives > 0 ? Colors.amber : Colors.red,
            ),
            SizedBox(height: 16 * pix),
            Text(
              _lives > 0 ? 'Chúc mừng!' : 'Trò chơi kết thúc!',
              style: TextStyle(
                fontSize: 24 * pix,
                fontWeight: FontWeight.bold,
                color: _lives > 0 ? Colors.amber.shade800 : Colors.red,
              ),
            ),
            SizedBox(height: 8 * pix),
            Text(
              _lives > 0
                  ? 'Bạn đã hoàn thành tất cả các từ!'
                  : 'Bạn đã hết mạng sống',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * pix,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16 * pix),
            Text(
              'Điểm của bạn: $_score',
              style: TextStyle(
                fontSize: 20 * pix,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24 * pix),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: Icon(Icons.refresh, size: 20 * pix),
                  label: Text(
                    'Chơi lại',
                    style: TextStyle(fontSize: 14 * pix),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * pix,
                      vertical: 12 * pix,
                    ),
                  ),
                ),
                SizedBox(width: 16 * pix),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.exit_to_app, size: 20 * pix),
                  label: Text(
                    'Thoát',
                    style: TextStyle(fontSize: 14 * pix),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: BorderSide(color: Colors.purple),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * pix,
                      vertical: 12 * pix,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom shake animation widget
class ShakeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final bool isWrong;

  const ShakeTransition({
    Key? key,
    required this.animation,
    required this.child,
    required this.isWrong,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final sineValue = sin(animation.value * 6 * pi);
        return Transform.translate(
          offset: isWrong ? Offset(sineValue * 10, 0) : Offset.zero,
          child: this.child,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:language_app/phu_nv/Vocab/vocabulary_screen.dart';
import 'package:language_app/phu_nv/Vocab/vocabulary_topic_screen.dart';
import 'package:language_app/phu_nv/Vocab/widget/detail_vocab_item.dart';
import 'package:language_app/phu_nv/Vocab/widget/vocab_select_category.dart';
import 'package:language_app/phu_nv/Vocab/word_game_screen.dart';
import 'package:language_app/models/vocabulary_model.dart';
import 'package:language_app/provider/vocabulary_provider.dart';
import 'package:language_app/widget/bottom_bar.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';

class VocabularySelectScreen extends StatefulWidget {
  const VocabularySelectScreen({super.key});

  @override
  State<VocabularySelectScreen> createState() => _VocabularySelectScreenState();
}

class _VocabularySelectScreenState extends State<VocabularySelectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Tìm kiếm từ vựng dựa trên từ khóa
  void _searchVocabulary() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập từ khóa để tìm kiếm'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Hiển thị loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final vocabProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    final success = await vocabProvider.searchVocab(keyword);

    // Đóng loading indicator
    Navigator.pop(context);

    if (success) {
      // Lấy kết quả tìm kiếm từ provider
      final List<VocabularyModel> searchResults = vocabProvider.vocabularies;
      // Hiển thị kết quả
      _showSearchResultsDialog(searchResults);
    } else {
      // Xử lý trường hợp tìm kiếm thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hiển thị dialog kết quả tìm kiếm
  void _showSearchResultsDialog(List<VocabularyModel> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Kết quả tìm kiếm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blue.shade700,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 50,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Không tìm thấy từ vựng phù hợp',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final vocab = results[index];
                    return ListTile(
                      title: Text(
                        vocab.word,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vocab.definition,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ví dụ: ${vocab.example}',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Hiển thị chi tiết từ vựng
                        _showVocabularyDetailDialog(vocab);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hiển thị chi tiết từ vựng
  void _showVocabularyDetailDialog(VocabularyModel vocabulary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with image
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.purple.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Center(
                  child: Text(
                    vocabulary.word,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailVocabItem(
                      content: 'Định nghĩa:',
                      label: vocabulary.definition,
                      icon: Icons.description,
                    ),
                    Divider(),
                    DetailVocabItem(
                      content: 'Ví dụ:',
                      label: vocabulary.example,
                      icon: Icons.format_quote,
                    ),
                    SizedBox(height: 8),
                    DetailVocabItem(
                      content: 'Dịch nghĩa:',
                      label: vocabulary.exampleTranslation,
                      icon: Icons.translate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Consumer<VocabularyProvider>(
        builder: (context, vocabProvider, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false, // Ngăn bàn phím đẩy nội dung lên
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade200, Colors.indigo.shade50],
              stops: const [0.0, 0.7],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopBar(title: 'Học từ vựng', isBack: false),
              ),
              Positioned(
                top: 100 * pix,
                left: 0,
                right: 0,
                bottom: 50 * pix,
                child: Column(
                  children: [
                    // Thanh tìm kiếm
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * pix,
                        vertical: 12 * pix,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30 * pix),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm từ vựng...',
                            prefixIcon: Icon(Icons.search, color: Colors.blue),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 15 * pix,
                              horizontal: 20 * pix,
                            ),
                          ),
                          onSubmitted: (_) => _searchVocabulary(),
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                    ),

                    SizedBox(height: 12 * pix),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20 * pix),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(15 * pix),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.language_rounded,
                                    size: 32 * pix,
                                    color: Colors.blue.shade700,
                                  ),
                                  SizedBox(width: 12 * pix),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Từ vựng",
                                          style: TextStyle(
                                            fontSize: 18 * pix,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'BeVietnamPro',
                                          ),
                                        ),
                                        Text(
                                          "Học từ vựng giúp mở rộng vốn ngôn ngữ, cải thiện kỹ năng giao tiếp và đọc hiểu.",
                                          style: TextStyle(
                                            fontSize: 14 * pix,
                                            color: Colors.grey.shade700,
                                            fontFamily: 'BeVietnamPro',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20 * pix),
                            VocabSelectCategory(
                              title: "Từ vựng theo chủ đề",
                              subtitle:
                                  "Học từ vựng theo các chủ đề khác nhau. Ví dụ: động vật, thực phẩm, du lịch... thông qua thẻ FlashCard.",
                              icon: Icons.category_rounded,
                              color: Colors.green.shade700,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const VocabularyTopicscreen(),
                                  ),
                                );
                              },
                              pix: pix,
                            ),
                            VocabSelectCategory(
                              title: "Từ vựng bất kỳ",
                              subtitle:
                                  "Học từ vựng như bóc túi mù, không theo chủ đề",
                              icon: Icons.star_rounded,
                              color: Colors.orange.shade700,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const VocabularyScreen(),
                                  ),
                                );
                              },
                              pix: pix,
                            ),
                            VocabSelectCategory(
                              title: "Trò chơi từ vựng",
                              subtitle: "Học từ vựng qua các trò chơi thú vị",
                              icon: Icons.games_rounded,
                              color: Colors.purple.shade700,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WordScrambleGame(),
                                  ),
                                );
                              },
                              pix: pix,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * pix),
                  ],
                ),
              ),
              Positioned(
                bottom: 0 * pix,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: Bottombar(type: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildCategory(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap, double pix) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * pix),
        padding: EdgeInsets.all(15 * pix),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32 * pix,
              color: color,
            ),
            SizedBox(width: 12 * pix),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18 * pix,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14 * pix,
                      color: Colors.grey.shade700,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                  Container(
                    height: 30 * pix,
                    width: double.maxFinite,
                    margin: EdgeInsets.only(
                        top: 10 * pix,
                        left: 16 * pix,
                        right: 16 * pix,
                        bottom: 5 * pix),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: color,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Chinh phục ngay",
                        style: TextStyle(
                          fontSize: 14 * pix,
                          color: color,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

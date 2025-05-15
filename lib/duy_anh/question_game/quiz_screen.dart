import 'package:flutter/material.dart';
import 'package:language_app/duy_anh/question_game/summary_screen.dart';
import 'package:language_app/widget/top_bar.dart';

class QuizScreen extends StatefulWidget {
  final String week;
  const QuizScreen({super.key, required this.week});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int timeLeft = 300; // 5 phút
  List<bool?> answers = List.filled(10, null); // Trạng thái trả lời
  final List<Map<String, dynamic>> questions = List.generate(
    10,
    (index) => {
      'question': index % 2 == 0
          ? "What does '${_getRandomWord()}' mean?"
          : "Is this sentence correct? '${_getExampleSentence()}'",
      'options': _generateOptions(index),
      'correct': index % 4, // Chọn đáp án đúng ngẫu nhiên (0-3)
      'explanation': _getExplanation(index),
    },
  );

  static String _getRandomWord() {
    final words = [
      'Diligent',
      'Eloquent',
      'Pragmatic',
      'Resilient',
      'Ephemeral'
    ];
    return words[(DateTime.now().millisecondsSinceEpoch % words.length)];
  }

  static String _getExampleSentence() {
    final sentences = [
      'She go to school every day.',
      'I have been living here since 2010.',
      'He don\'t likes coffee.',
      'They are playing football now.'
    ];
    return sentences[
        (DateTime.now().millisecondsSinceEpoch % sentences.length)];
  }

  static List<String> _generateOptions(int index) {
    if (index % 2 == 0) {
      // Câu hỏi về nghĩa từ
      return [
        'Hardworking and careful',
        'Speaking fluently and persuasively',
        'Practical and realistic',
        'Able to recover quickly from difficulties'
      ];
    } else {
      // Câu hỏi về đúng/sai câu
      return [
        'Correct',
        'Incorrect - verb agreement error',
        'Incorrect - tense error',
        'Incorrect - preposition error'
      ];
    }
  }

  static String _getExplanation(int index) {
    if (index % 2 == 0) {
      return 'This word comes from Latin origin and is often used in academic contexts.';
    } else {
      return 'Pay attention to subject-verb agreement and verb tenses in English sentences.';
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (timeLeft > 0) {
          setState(() => timeLeft--);
          _startTimer();
        } else {
          _submitQuiz();
        }
      }
    });
  }

  void _showQuestionList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Question Navigator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => currentQuestion = index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: answers[index] != null
                              ? Colors.green[answers[index]! ? 400 : 300]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: currentQuestion == index
                                ? Colors.blue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              color: answers[index] != null
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(
            week: widget.week, answers: answers, questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = questions[currentQuestion];
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
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopBar(
                title: 'Quiz - ${widget.week}',
              ),
            ),
            Positioned(
              top: 120 * pix,
              left: 16 * pix,
              right: 16 * pix,
              bottom: 0,
              child: Column(
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (currentQuestion + 1) / questions.length,
                    backgroundColor: Colors.grey[200],
                    color: Colors.blue[800],
                    minHeight: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentQuestion + 1}/${questions.length}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _showQuestionList,
                        child: const Text(
                          'View all questions',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * pix),

                  // Question card
                  Expanded(
                    child: SingleChildScrollView(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current['question'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Options
                              ...current['options']
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int idx = entry.key;
                                String option = entry.value;
                                bool isSelected =
                                    answers[currentQuestion] != null;
                                bool isCorrect = idx == current['correct'];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      setState(() {
                                        answers[currentQuestion] = isCorrect;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isCorrect
                                                ? Colors.green[50]
                                                : Colors.red[50])
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? (isCorrect
                                                  ? Colors.green
                                                  : Colors.red)
                                              : Colors.grey[300]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? (isCorrect
                                                    ? Icons.check_circle
                                                    : Icons.cancel)
                                                : Icons.radio_button_unchecked,
                                            color: isSelected
                                                ? (isCorrect
                                                    ? Colors.green
                                                    : Colors.red)
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: isSelected
                                                    ? (isCorrect
                                                        ? Colors.green[800]
                                                        : Colors.red[800])
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),

                              // Explanation (shown after answering)
                              if (answers[currentQuestion] != null) ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue[200]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Explanation:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(current['explanation']),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 68 * pix,
                    height: 28 * pix,
                    margin: EdgeInsets.only(bottom: 8 * pix, top: 8 * pix),
                    alignment: Alignment.topRight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, size: 18, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          '${timeLeft ~/ 60}:${(timeLeft % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 12 * pix,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: currentQuestion > 0
                              ? () => setState(() => currentQuestion--)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.blue[800]!),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back, size: 18),
                              SizedBox(width: 8),
                              Text('Previous'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: currentQuestion < questions.length - 1
                              ? () => setState(() => currentQuestion++)
                              : () => _submitQuiz(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                currentQuestion < questions.length - 1
                                    ? 'Next'
                                    : 'Submit',
                              ),
                              if (currentQuestion < questions.length - 1) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 36 * pix),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

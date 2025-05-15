import 'package:flutter/material.dart';
import 'package:language_app/widget/top_bar.dart';

class SummaryScreen extends StatelessWidget {
  final String week;
  final List<bool?> answers;
  final List<Map<String, dynamic>> questions;

  const SummaryScreen(
      {super.key,
      required this.week,
      required this.answers,
      required this.questions});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    final correctCount = answers.where((a) => a == true).length;
    final scorePercentage = (correctCount / questions.length * 100).round();
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

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
                child: TopBar(title: 'Kết quả bài kiểm tra')),
            Positioned(
              top: 110 * pix,
              left: 16 * pix,
              right: 16 * pix,
              bottom: 16 * pix,
              child: Column(
                children: [
                  // Result summary card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            scorePercentage >= 70
                                ? Icons.celebration
                                : Icons.school,
                            size: 60,
                            color: scorePercentage >= 70
                                ? Colors.amber
                                : Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            scorePercentage >= 70
                                ? 'Excellent Work!'
                                : 'Keep Practicing!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You completed the $week quiz',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildScoreCircle(
                                  context,
                                  'Score',
                                  '$scorePercentage%',
                                  _getScoreColor(scorePercentage)),
                              _buildScoreCircle(context, 'Correct',
                                  '$correctCount', Colors.green),
                              _buildScoreCircle(
                                  context,
                                  'Incorrect',
                                  '${questions.length - correctCount}',
                                  Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Detailed results
                  Expanded(
                    child: ListView.separated(
                      itemCount: questions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        final isCorrect = answers[index] == true;
                        final userAnswer = answers[index];

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isCorrect ? Colors.green[50] : Colors.red[50],
                              foregroundColor:
                                  isCorrect ? Colors.green : Colors.red,
                              child:
                                  Icon(isCorrect ? Icons.check : Icons.close),
                            ),
                            title: Text(
                              'Question ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              userAnswer == null
                                  ? 'Not answered'
                                  : (isCorrect ? 'Correct' : 'Incorrect'),
                              style: TextStyle(
                                color: userAnswer == null
                                    ? Colors.grey
                                    : (isCorrect ? Colors.green : Colors.red),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      question['question'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Correct answer:',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green[100]!,
                                        ),
                                      ),
                                      child: Text(
                                        question['options']
                                            [question['correct']],
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (question
                                        .containsKey('explanation')) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        'Explanation:',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        question['explanation'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.blue[800]!),
                            ),
                            child: const Text(
                              'Back to Quiz',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TestScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Try Again',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(
      BuildContext context, String title, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.amber;
    return Colors.red;
  }
}

// Placeholder for TestScreen
class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Screen')),
      body: const Center(child: Text('Test Screen Content')),
    );
  }
}

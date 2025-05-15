import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DoExamScreen extends StatefulWidget {
  final String title;
  final String language;
  final String level;

  const DoExamScreen({
    Key? key,
    required this.title,
    required this.language,
    required this.level,
  }) : super(key: key);

  @override
  State<DoExamScreen> createState() => _DoExamScreenState();
}

class _DoExamScreenState extends State<DoExamScreen> {
  // Quiz state
  int _currentIndex = 0;
  int _currentSection = 0;
  int _currentContentIndex = 0;
  int _correctAnswers = 0;
  bool _quizCompleted = false;
  final PageController _pageController = PageController();
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  double _playbackSpeed = 0.75;

  // Quiz sections
  final List<String> _sections = [
    'Ngữ pháp',
    'Nghe',
    'Đọc hiểu',
  ];

  // Grammar questions
  final List<Map<String, dynamic>> grammarQuestions = [
    {
      'section': 'Ngữ pháp',
      'question': 'She ______ to school on foot sometimes.',
      'options': ['goes', 'went', 'has gone', 'will go'],
      'answer': 'goes',
      'explanation': 'Use simple present tense for habitual actions.',
    },
    {
      'section': 'Ngữ pháp',
      'question': 'We ______ dinner when she called yesterday.',
      'options': ['are having', 'were having', 'have had', 'had'],
      'answer': 'were having',
      'explanation':
          'Use past continuous for actions in progress at a specific time in the past.',
    },
    {
      'section': 'Ngữ pháp',
      'question': 'By next month, I ______ in this company for five years.',
      'options': [
        'will work',
        'will be working',
        'will have worked',
        'will have been working'
      ],
      'answer': 'will have worked',
      'explanation':
          'Use future perfect for actions that will be completed by a certain time in the future.',
    },
    {
      'section': 'Ngữ pháp',
      'question': 'If I ______ rich, I would buy a big house.',
      'options': ['am', 'was', 'were', 'would be'],
      'answer': 'were',
      'explanation':
          'Use "were" in second conditional sentences regardless of the subject.',
    },
    {
      'section': 'Ngữ pháp',
      'question': 'She ______ here since 2010.',
      'options': ['works', 'worked', 'has worked', 'had worked'],
      'answer': 'has worked',
      'explanation':
          'Use present perfect for actions that started in the past and continue to the present.',
    },
  ];

  // Listening content
  final List<Map<String, dynamic>> listeningContent = [
    {
      'title': 'Bài nghe 1: Cuộc hội thoại tại nhà hàng',
      'transcript':
          'Waiter: Hello and welcome to our restaurant.\nCustomer: Hi, thank you. I\'d like to see the menu please.\nWaiter: Here you are. Today\'s special is grilled salmon with vegetables.\nCustomer: That sounds delicious. I\'ll have that. And what drinks do you have?\nWaiter: We have various juices, sodas, and mineral water. We also have wine and beer.\nCustomer: I\'ll take a glass of orange juice, please.\nWaiter: Great choice. Your meal will be ready in about 15 minutes.',
      'questions': [
        {
          'question': 'What is the special dish today?',
          'options': [
            'Fried chicken',
            'Grilled salmon',
            'Vegetable soup',
            'Beef steak'
          ],
          'answer': 'Grilled salmon',
        },
        {
          'question': 'What does the customer order to drink?',
          'options': ['Wine', 'Beer', 'Orange juice', 'Mineral water'],
          'answer': 'Orange juice',
        },
        {
          'question': 'How long will the customer wait for the meal?',
          'options': ['5 minutes', '10 minutes', '15 minutes', '20 minutes'],
          'answer': '15 minutes',
        },
        {
          'question': 'Where does this conversation take place?',
          'options': [
            'At home',
            'At a restaurant',
            'At a café',
            'At a supermarket'
          ],
          'answer': 'At a restaurant',
        },
        {
          'question': 'What comes with the special dish?',
          'options': ['Rice', 'Potatoes', 'Vegetables', 'Bread'],
          'answer': 'Vegetables',
        },
      ],
    },
    {
      'title': 'Bài nghe 2: Dự báo thời tiết',
      'transcript':
          'Good morning listeners! Here\'s the weather forecast for today. Temperatures will range from 15 to 22 degrees Celsius. We expect mostly sunny conditions in the morning, with some clouds developing in the afternoon. There\'s a 30% chance of light rain in the evening, so you might want to carry an umbrella if you\'re going out. Winds will be moderate from the southwest. Tomorrow will be cooler with temperatures dropping to between 12 and 18 degrees, and we expect more rain throughout the day.',
      'questions': [
        {
          'question': 'What will the maximum temperature be today?',
          'options': ['15°C', '18°C', '22°C', '30°C'],
          'answer': '22°C',
        },
        {
          'question': 'What is the weather expected to be like in the morning?',
          'options': ['Rainy', 'Cloudy', 'Mostly sunny', 'Windy'],
          'answer': 'Mostly sunny',
        },
        {
          'question': 'What is the chance of rain in the evening?',
          'options': ['10%', '20%', '30%', '50%'],
          'answer': '30%',
        },
        {
          'question': 'What should you carry if going out in the evening?',
          'options': ['Sunglasses', 'Umbrella', 'Gloves', 'Sunscreen'],
          'answer': 'Umbrella',
        },
        {
          'question': 'How will tomorrow\'s temperature compare to today?',
          'options': ['Higher', 'The same', 'Lower', 'Unpredictable'],
          'answer': 'Lower',
        },
      ],
    },
    {
      'title': 'Bài nghe 3: Cuộc phỏng vấn công việc',
      'transcript':
          'Interviewer: Good morning, thanks for coming in today.\nCandidate: Good morning, thank you for the opportunity.\nInterviewer: So, tell me about your previous experience.\nCandidate: I\'ve worked as a marketing assistant for three years at ABC Company. My responsibilities included managing social media accounts, creating content, and analyzing campaign performance.\nInterviewer: That sounds relevant. Why are you interested in this position?\nCandidate: I\'m attracted to this role because it offers more creative control and I\'m impressed by your company\'s innovative approach to marketing. I believe my skills would be a good match.\nInterviewer: What would you say is your greatest strength?\nCandidate: I\'d say my ability to adapt quickly to changing situations while maintaining quality work.',
      'questions': [
        {
          'question': 'How long has the candidate worked at ABC Company?',
          'options': ['Two years', 'Three years', 'Four years', 'Five years'],
          'answer': 'Three years',
        },
        {
          'question':
              'What was NOT mentioned as one of the candidate\'s responsibilities?',
          'options': [
            'Managing social media accounts',
            'Creating content',
            'Analyzing campaign performance',
            'Customer service'
          ],
          'answer': 'Customer service',
        },
        {
          'question': 'Why is the candidate interested in the position?',
          'options': [
            'Higher salary',
            'Better location',
            'More creative control',
            'Flexible working hours'
          ],
          'answer': 'More creative control',
        },
        {
          'question': 'What does the candidate say about the company?',
          'options': [
            'It has a good reputation',
            'It has an innovative approach',
            'It offers training opportunities',
            'It has international offices'
          ],
          'answer': 'It has an innovative approach',
        },
        {
          'question':
              'What does the candidate mention as their greatest strength?',
          'options': [
            'Communication skills',
            'Technical knowledge',
            'Leadership ability',
            'Adaptability'
          ],
          'answer': 'Adaptability',
        },
      ],
    },
  ];

  // Reading content
  final List<Map<String, dynamic>> readingContent = [
    {
      'title': 'Bài đọc 1: Công nghệ và giáo dục',
      'passage':
          '''Technology has significantly transformed education, creating new opportunities for teaching and learning. Digital tools have made education more accessible to people around the world through online courses and resources. Students can now learn at their own pace and access materials beyond what traditional classrooms offer.

Interactive learning platforms provide immediate feedback, helping students identify areas for improvement quickly. Virtual reality and augmented reality technologies create immersive experiences that enhance understanding of complex concepts. Collaboration tools enable students to work together regardless of physical location, preparing them for the interconnected global workplace.

However, technology integration in education also presents challenges. The digital divide means that not all students have equal access to devices and internet connectivity. Some educators struggle to adapt to new teaching methods and technologies. Additionally, there are concerns about screen time and its potential impact on development and attention spans.

Despite these challenges, the benefits of educational technology are significant. As technology continues to evolve, so too will its applications in education. The key is to implement technology thoughtfully, ensuring it enhances rather than detracts from the learning experience.''',
      'questions': [
        {
          'question':
              'According to the passage, how has technology affected education?',
          'options': [
            'It has limited learning opportunities',
            'It has transformed education positively',
            'It has had no significant impact',
            'It has completely replaced traditional classrooms'
          ],
          'answer': 'It has transformed education positively',
        },
        {
          'question': 'What is an advantage of interactive learning platforms?',
          'options': [
            'They reduce the need for teachers',
            'They provide immediate feedback',
            'They are inexpensive to develop',
            'They eliminate the need for textbooks'
          ],
          'answer': 'They provide immediate feedback',
        },
        {
          'question':
              'What is mentioned as a challenge of technology integration in education?',
          'options': [
            'Digital divide',
            'High costs for schools',
            'Limited content available',
            'Student resistance to technology'
          ],
          'answer': 'Digital divide',
        },
        {
          'question':
              'How do collaboration tools benefit students according to the passage?',
          'options': [
            'They eliminate group projects',
            'They prepare students for global workplaces',
            'They reduce the need for physical classrooms',
            'They increase competition among peers'
          ],
          'answer': 'They prepare students for global workplaces',
        },
        {
          'question':
              'What is the author\'s overall perspective on educational technology?',
          'options': [
            'Enthusiastic without reservations',
            'Cautiously optimistic',
            'Neutral and objective',
            'Primarily concerned about negative effects'
          ],
          'answer': 'Cautiously optimistic',
        },
      ],
    },
    {
      'title': 'Bài đọc 2: Biến đổi khí hậu',
      'passage':
          '''Climate change represents one of the greatest challenges facing humanity today. The Earth's average temperature has increased by about 1°C since pre-industrial times, primarily due to greenhouse gas emissions from human activities. This warming is causing more frequent and severe weather events, rising sea levels, and disruptions to ecosystems worldwide.

The impacts of climate change vary by region. Coastal areas face threats from sea-level rise and stronger storms. Inland regions may experience more severe droughts and floods. Some areas might become uninhabitable due to extreme heat or water scarcity. Agriculture is particularly vulnerable, with changing weather patterns affecting crop yields and food security.

Addressing climate change requires both mitigation and adaptation strategies. Mitigation involves reducing greenhouse gas emissions through renewable energy, energy efficiency, and forest conservation. Adaptation means preparing for unavoidable impacts through infrastructure improvements, early warning systems, and community resilience planning.

International cooperation is essential, as climate change is a global issue that no single country can solve alone. The Paris Agreement represents a significant step forward, with countries pledging to limit warming to well below 2°C above pre-industrial levels. However, current commitments are insufficient to meet this goal, highlighting the need for more ambitious action.

Despite the challenges, there are reasons for hope. Renewable energy costs have fallen dramatically, making clean energy increasingly competitive with fossil fuels. Many cities and businesses are leading the way with climate initiatives. And young people around the world are mobilizing to demand stronger climate policies from their governments.''',
      'questions': [
        {
          'question':
              'By how much has the Earth\'s average temperature increased since pre-industrial times?',
          'options': ['0.5°C', '1°C', '1.5°C', '2°C'],
          'answer': '1°C',
        },
        {
          'question':
              'Which sectors are mentioned as being particularly vulnerable to climate change?',
          'options': [
            'Transportation',
            'Manufacturing',
            'Agriculture',
            'Technology'
          ],
          'answer': 'Agriculture',
        },
        {
          'question':
              'What does "mitigation" refer to in the context of climate change?',
          'options': [
            'Preparing for climate impacts',
            'Reducing greenhouse gas emissions',
            'Developing new technologies',
            'Creating international agreements'
          ],
          'answer': 'Reducing greenhouse gas emissions',
        },
        {
          'question':
              'According to the passage, what is the goal of the Paris Agreement?',
          'options': [
            'To eliminate all greenhouse gas emissions',
            'To limit warming to below 2°C',
            'To provide funding for affected countries',
            'To develop new clean energy technologies'
          ],
          'answer': 'To limit warming to below 2°C',
        },
        {
          'question':
              'What positive development does the passage mention regarding renewable energy?',
          'options': [
            'Universal adoption worldwide',
            'Government subsidies increasing',
            'Costs have fallen dramatically',
            'New storage technologies'
          ],
          'answer': 'Costs have fallen dramatically',
        },
      ],
    },
    {
      'title': 'Bài đọc 3: Trí tuệ nhân tạo',
      'passage':
          '''Artificial Intelligence (AI) is rapidly transforming nearly every aspect of modern society. At its core, AI involves creating computer systems capable of performing tasks that typically require human intelligence. These include problem-solving, pattern recognition, learning from experience, and understanding natural language.

Machine learning, a subset of AI, enables computers to learn from data without explicit programming. Deep learning, which uses neural networks with many layers, has led to remarkable advances in image and speech recognition. These technologies power many applications we use daily, from virtual assistants like Siri and Alexa to recommendation systems on streaming platforms.

AI is creating value across numerous sectors. In healthcare, it helps diagnose diseases from medical images and predicts patient outcomes. In transportation, it enables autonomous vehicles and optimizes traffic flow. In finance, it detects fraudulent transactions and automates trading. Manufacturing benefits from AI-powered robots and predictive maintenance systems.

However, the rise of AI also raises important ethical questions. Privacy concerns emerge as AI systems collect and analyze vast amounts of personal data. Bias in algorithms can perpetuate and amplify existing societal inequalities. And as AI automates more tasks, there are concerns about job displacement and economic disruption.

Looking forward, AI will continue to evolve and become more capable. Some researchers focus on developing artificial general intelligence (AGI) that could match or exceed human capabilities across a wide range of tasks. Others work on making AI systems more transparent, fair, and aligned with human values. How we design, deploy, and govern AI technologies will shape their impact on society for generations to come.''',
      'questions': [
        {
          'question':
              'What is the primary definition of Artificial Intelligence according to the passage?',
          'options': [
            'Creating human-like robots',
            'Computer systems performing tasks requiring human intelligence',
            'Automated manufacturing systems',
            'Technology for space exploration'
          ],
          'answer':
              'Computer systems performing tasks requiring human intelligence',
        },
        {
          'question': 'What is described as a subset of AI in the passage?',
          'options': [
            'Virtual reality',
            'Robotics',
            'Machine learning',
            'Neural processing'
          ],
          'answer': 'Machine learning',
        },
        {
          'question': 'Which application of AI in healthcare is mentioned?',
          'options': [
            'Performing surgery',
            'Diagnosing diseases from medical images',
            'Developing new medications',
            'Managing hospital staff'
          ],
          'answer': 'Diagnosing diseases from medical images',
        },
        {
          'question':
              'What ethical concern related to AI is NOT mentioned in the passage?',
          'options': [
            'Privacy issues',
            'Algorithmic bias',
            'Job displacement',
            'AI consciousness'
          ],
          'answer': 'AI consciousness',
        },
        {
          'question':
              'What does the passage say about artificial general intelligence (AGI)?',
          'options': [
            'It already exists',
            'It can never be achieved',
            'Some researchers are working to develop it',
            'It was developed in the 1990s'
          ],
          'answer': 'Some researchers are working to develop it',
        },
      ],
    },
  ];

  // Combined list of all questions
  List<Map<String, dynamic>> allQuestions = [];

  // User's selected answers
  List<dynamic> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _initializeQuiz();

    // Cấu hình FlutterTts
    _configureTts();
  }

  void _configureTts() {
    _tts.setLanguage(widget.language == 'English' ? 'en-US' : 'vi-VN');
    _tts.setSpeechRate(_playbackSpeed);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _initializeQuiz() {
    allQuestions = [];
    allQuestions.addAll(grammarQuestions);

    for (int i = 0; i < listeningContent.length; i++) {
      for (int j = 0; j < listeningContent[i]['questions'].length; j++) {
        Map<String, dynamic> question =
            Map.from(listeningContent[i]['questions'][j]);
        question['section'] = 'Nghe';
        question['contentIndex'] = i;
        question['contentType'] = 'listening';
        question['contentTitle'] = listeningContent[i]['title'];
        allQuestions.add(question);
      }
    }

    for (int i = 0; i < readingContent.length; i++) {
      for (int j = 0; j < readingContent[i]['questions'].length; j++) {
        Map<String, dynamic> question =
            Map.from(readingContent[i]['questions'][j]);
        question['section'] = 'Đọc hiểu';
        question['contentIndex'] = i;
        question['contentType'] = 'reading';
        question['contentTitle'] = readingContent[i]['title'];
        allQuestions.add(question);
      }
    }

    _userAnswers = List.filled(allQuestions.length, null);
  }

  void _checkAnswer(int questionIndex, dynamic answer) {
    setState(() {
      _userAnswers[questionIndex] = answer;
    });
  }

  void _submitQuiz() {
    int correctCount = 0;

    for (int i = 0; i < allQuestions.length; i++) {
      final userAnswer = _userAnswers[i];
      if (userAnswer == allQuestions[i]['answer']) {
        correctCount++;
      }
    }

    setState(() {
      _correctAnswers = correctCount;
      _quizCompleted = true;
    });
  }

  void _goToNextQuestion() {
    if (_currentIndex < allQuestions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitQuiz();
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _correctAnswers = 0;
      _quizCompleted = false;
      _initializeQuiz();
    });
    _pageController.jumpToPage(0);
  }

  void _toggleAudio() async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      final question = allQuestions[_currentIndex];
      if (question['contentType'] == 'listening') {
        int contentIndex = question['contentIndex'];
        String transcript = listeningContent[contentIndex]['transcript'];
        await _tts.setSpeechRate(_playbackSpeed);
        await _tts.speak(transcript);
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  bool _isNewContent(int index) {
    if (index == 0) return true;

    final currentQuestion = allQuestions[index];
    final prevQuestion = allQuestions[index - 1];

    if (currentQuestion['section'] != prevQuestion['section']) {
      return true;
    }

    if ((currentQuestion['section'] == 'Nghe' ||
            currentQuestion['section'] == 'Đọc hiểu') &&
        currentQuestion['contentIndex'] != prevQuestion['contentIndex']) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    if (_quizCompleted) {
      return _buildResultScreen(pix);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Bài kiểm tra: ${widget.title}"),
        backgroundColor: const Color(0xff5B7BFE),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _submitQuiz,
            child: Text(
              "Nộp bài",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16 * pix,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16 * pix),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Câu ${_currentIndex + 1}/${allQuestions.length}",
                        style: TextStyle(
                          fontSize: 16 * pix,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Đã trả lời: ${_userAnswers.where((a) => a != null).length}/${allQuestions.length}",
                        style: TextStyle(
                          fontSize: 14 * pix,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * pix),
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / allQuestions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 8 * pix,
                    borderRadius: BorderRadius.circular(4 * pix),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _currentSection =
                        _sections.indexOf(allQuestions[index]['section']);
                    if (allQuestions[index]['section'] == 'Nghe' ||
                        allQuestions[index]['section'] == 'Đọc hiểu') {
                      _currentContentIndex =
                          allQuestions[index]['contentIndex'];
                    }
                    if (_isPlaying) {
                      _tts.stop();
                      _isPlaying = false;
                    }
                  });
                },
                itemCount: allQuestions.length,
                itemBuilder: (context, index) {
                  final question = allQuestions[index];
                  final bool isNewContent = _isNewContent(index);

                  if (question['section'] == 'Ngữ pháp') {
                    return _buildGrammarQuestion(question, index, pix);
                  } else if (question['section'] == 'Nghe') {
                    return _buildListeningQuestion(
                        question, index, isNewContent, pix);
                  } else if (question['section'] == 'Đọc hiểu') {
                    return _buildReadingQuestion(
                        question, index, isNewContent, pix);
                  }

                  return Center(child: Text('Question type not supported'));
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16 * pix),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: Icon(Icons.arrow_back, size: 20 * pix),
                    label: Text('Trước', style: TextStyle(fontSize: 16 * pix)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * pix, vertical: 12 * pix),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * pix),
                      ),
                      disabledBackgroundColor: Colors.grey[100],
                      disabledForegroundColor: Colors.grey[400],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _goToNextQuestion(),
                    icon: Icon(Icons.arrow_forward, size: 20 * pix),
                    label: Text(
                      _currentIndex < allQuestions.length - 1
                          ? 'Tiếp'
                          : 'Nộp bài',
                      style: TextStyle(fontSize: 16 * pix),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5B7BFE),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * pix, vertical: 12 * pix),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * pix),
                      ),
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

  Widget _buildGrammarQuestion(
      Map<String, dynamic> question, int index, double pix) {
    final options = question['options'] as List;
    final userAnswer = _userAnswers[index];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16 * pix),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12 * pix),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              question['question'],
              style: TextStyle(
                fontSize: 18 * pix,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 24 * pix),
          ...List.generate(options.length, (optionIndex) {
            final option = options[optionIndex];
            final isSelected = userAnswer == option;

            return GestureDetector(
              onTap: () => _checkAnswer(index, option),
              child: Container(
                margin: EdgeInsets.only(bottom: 12 * pix),
                padding: EdgeInsets.all(16 * pix),
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(8 * pix),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24 * pix,
                      height: 24 * pix,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.blue : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check,
                              color: Colors.white, size: 16 * pix)
                          : null,
                    ),
                    SizedBox(width: 16 * pix),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16 * pix,
                          color: isSelected ? Colors.blue[800] : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListeningQuestion(
      Map<String, dynamic> question, int index, bool isNewContent, double pix) {
    final options = question['options'] as List;
    final userAnswer = _userAnswers[index];
    final contentIndex = question['contentIndex'];
    final contentData = listeningContent[contentIndex];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contentData['title'],
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 16 * pix),
          if (isNewContent)
            Container(
              padding: EdgeInsets.all(16 * pix),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12 * pix),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 48 * pix,
                          color: Colors.green,
                        ),
                        onPressed: _toggleAudio,
                      ),
                      SizedBox(width: 16 * pix),
                      DropdownButton<double>(
                        value: _playbackSpeed,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _playbackSpeed = value;
                              _tts.setSpeechRate(_playbackSpeed);
                            });
                          }
                        },
                        items: [
                          DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                          DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                          DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                          DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                          DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                          DropdownMenuItem(value: 2.0, child: Text('2.0x')),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * pix),
                  Text(
                    'Bấm play để nghe đoạn hội thoại',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16 * pix),
          Container(
            padding: EdgeInsets.all(16 * pix),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12 * pix),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu hỏi ${(index % 5) + 1}:',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 8 * pix),
                Text(
                  question['question'],
                  style: TextStyle(
                    fontSize: 18 * pix,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * pix),
          ...List.generate(options.length, (optionIndex) {
            final option = options[optionIndex];
            final isSelected = userAnswer == option;

            return GestureDetector(
              onTap: () => _checkAnswer(index, option),
              child: Container(
                margin: EdgeInsets.only(bottom: 12 * pix),
                padding: EdgeInsets.all(16 * pix),
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(8 * pix),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24 * pix,
                      height: 24 * pix,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.green : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check,
                              color: Colors.white, size: 16 * pix)
                          : null,
                    ),
                    SizedBox(width: 16 * pix),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16 * pix,
                          color:
                              isSelected ? Colors.green[800] : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReadingQuestion(
      Map<String, dynamic> question, int index, bool isNewContent, double pix) {
    final options = question['options'] as List;
    final userAnswer = _userAnswers[index];
    final contentIndex = question['contentIndex'];
    final contentData = readingContent[contentIndex];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contentData['title'],
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          SizedBox(height: 16 * pix),
          if (isNewContent)
            Container(
              padding: EdgeInsets.all(16 * pix),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12 * pix),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đọc đoạn văn sau:',
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12 * pix),
                  Text(
                    contentData['passage'],
                    style: TextStyle(
                      fontSize: 16 * pix,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            )
          else
            ExpansionTile(
              title: Text(
                'Xem lại đoạn văn',
                style: TextStyle(
                  fontSize: 16 * pix,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                Container(
                  padding: EdgeInsets.all(16 * pix),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12 * pix),
                      bottomRight: Radius.circular(12 * pix),
                    ),
                  ),
                  child: Text(
                    contentData['passage'],
                    style: TextStyle(
                      fontSize: 16 * pix,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          SizedBox(height: 16 * pix),
          Container(
            padding: EdgeInsets.all(16 * pix),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12 * pix),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu hỏi ${(index % 5) + 1}:',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                SizedBox(height: 8 * pix),
                Text(
                  question['question'],
                  style: TextStyle(
                    fontSize: 18 * pix,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * pix),
          ...List.generate(options.length, (optionIndex) {
            final option = options[optionIndex];
            final isSelected = userAnswer == option;

            return GestureDetector(
              onTap: () => _checkAnswer(index, option),
              child: Container(
                margin: EdgeInsets.only(bottom: 12 * pix),
                padding: EdgeInsets.all(16 * pix),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8 * pix),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24 * pix,
                      height: 24 * pix,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.orange : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check,
                              color: Colors.white, size: 16 * pix)
                          : null,
                    ),
                    SizedBox(width: 16 * pix),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16 * pix,
                          color:
                              isSelected ? Colors.orange[800] : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultScreen(double pix) {
    final percentage = (_correctAnswers / allQuestions.length) * 100;
    final grade = percentage >= 90
        ? 'Xuất sắc'
        : percentage >= 80
            ? 'Giỏi'
            : percentage >= 65
                ? 'Khá'
                : percentage >= 50
                    ? 'Trung bình'
                    : 'Cần cố gắng hơn';

    Color resultColor = percentage >= 80
        ? Colors.green
        : percentage >= 65
            ? Colors.blue
            : percentage >= 50
                ? Colors.orange
                : Colors.red;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16 * pix),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16 * pix),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assessment,
                        size: 32 * pix,
                        color: const Color(0xff5B7BFE),
                      ),
                      SizedBox(width: 10 * pix),
                      Text(
                        "Kết quả bài kiểm tra",
                        style: TextStyle(
                          fontSize: 24 * pix,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5B7BFE),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120 * pix,
                            height: 120 * pix,
                            decoration: BoxDecoration(
                              color: resultColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "$_correctAnswers/${allQuestions.length}",
                                    style: TextStyle(
                                      fontSize: 32 * pix,
                                      fontWeight: FontWeight.bold,
                                      color: resultColor,
                                    ),
                                  ),
                                  Text(
                                    "${percentage.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontSize: 16 * pix,
                                      fontWeight: FontWeight.bold,
                                      color: resultColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16 * pix),
                      Text(
                        grade,
                        style: TextStyle(
                          fontSize: 24 * pix,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                      SizedBox(height: 8 * pix),
                      Text(
                        _getResultMessage(percentage),
                        style: TextStyle(
                          fontSize: 16 * pix,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24 * pix),
                      Text(
                        "Kết quả theo từng phần",
                        style: TextStyle(
                          fontSize: 18 * pix,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16 * pix),
                      ..._sections.map((section) {
                        final sectionQuestions = allQuestions
                            .where((q) => q['section'] == section)
                            .toList();
                        int correctCount = 0;

                        for (int i = 0; i < allQuestions.length; i++) {
                          if (allQuestions[i]['section'] == section &&
                              _userAnswers[i] == allQuestions[i]['answer']) {
                            correctCount++;
                          }
                        }

                        final sectionPercentage = sectionQuestions.isNotEmpty
                            ? (correctCount / sectionQuestions.length) * 100
                            : 0;

                        Color sectionColor;
                        if (section == 'Ngữ pháp') {
                          sectionColor = Colors.blue;
                        } else if (section == 'Nghe') {
                          sectionColor = Colors.green;
                        } else {
                          sectionColor = Colors.orange;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12 * pix),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    section,
                                    style: TextStyle(
                                      fontSize: 16 * pix,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "$correctCount/${sectionQuestions.length} (${sectionPercentage.toStringAsFixed(0)}%)",
                                    style: TextStyle(
                                      fontSize: 16 * pix,
                                      fontWeight: FontWeight.bold,
                                      color: sectionColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6 * pix),
                              LinearProgressIndicator(
                                value: sectionQuestions.isNotEmpty
                                    ? correctCount / sectionQuestions.length
                                    : 0,
                                backgroundColor: Colors.grey[300],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(sectionColor),
                                minHeight: 8 * pix,
                                borderRadius: BorderRadius.circular(4 * pix),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 24 * pix),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _restart,
                      icon: Icon(Icons.refresh, size: 20 * pix),
                      label:
                          Text('Làm lại', style: TextStyle(fontSize: 16 * pix)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff5B7BFE),
                        side: BorderSide(color: const Color(0xff5B7BFE)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20 * pix, vertical: 12 * pix),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, size: 20 * pix),
                      label: Text('Quay lại',
                          style: TextStyle(fontSize: 16 * pix)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff5B7BFE),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20 * pix, vertical: 12 * pix),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8 * pix),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16 * pix),
                TextButton.icon(
                  onPressed: () {
                    _showReviewDialog(pix);
                  },
                  icon: Icon(Icons.visibility, size: 20 * pix),
                  label: Text('Xem lại các câu hỏi',
                      style: TextStyle(fontSize: 16 * pix)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReviewDialog(double pix) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20 * pix),
        ),
        backgroundColor: Colors.white,
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.all(20 * pix),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem lại câu trả lời',
                style: TextStyle(
                  fontSize: 20 * pix,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16 * pix),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...List.generate(allQuestions.length, (index) {
                        final question = allQuestions[index];
                        final userAnswer = _userAnswers[index];
                        final bool isCorrect = userAnswer == question['answer'];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12 * pix),
                          padding: EdgeInsets.all(12 * pix),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10 * pix),
                            border: Border.all(
                              color: isCorrect ? Colors.green : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4 * pix),
                                    decoration: BoxDecoration(
                                      color:
                                          isCorrect ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 16 * pix,
                                    ),
                                  ),
                                  SizedBox(width: 8 * pix),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Câu ${index + 1}: ${question['question']}',
                                          style: TextStyle(
                                            fontSize: 16 * pix,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8 * pix),
                                        Text(
                                          'Đáp án đúng: ${question['answer']}',
                                          style: TextStyle(
                                            fontSize: 14 * pix,
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (userAnswer != null)
                                          Text(
                                            'Đáp án của bạn: $userAnswer',
                                            style: TextStyle(
                                              fontSize: 14 * pix,
                                              color: isCorrect
                                                  ? Colors.green[800]
                                                  : Colors.red[800],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        if (userAnswer == null)
                                          Text(
                                            'Bạn chưa trả lời câu này',
                                            style: TextStyle(
                                              fontSize: 14 * pix,
                                              color: Colors.orange[800],
                                              fontStyle: FontStyle.italic,
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
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16 * pix),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Đóng',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    color: const Color(0xff5B7BFE),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getResultMessage(double percentage) {
    if (percentage >= 90) {
      return 'Tuyệt vời! Bạn đã hoàn thành xuất sắc bài kiểm tra này.';
    } else if (percentage >= 80) {
      return 'Rất tốt! Bạn đã nắm vững hầu hết nội dung.';
    } else if (percentage >= 65) {
      return 'Khá tốt! Tiếp tục luyện tập để hoàn thiện hơn.';
    } else if (percentage >= 50) {
      return 'Bạn cần luyện tập thêm để cải thiện kết quả của mình.';
    } else {
      return 'Đừng nản lòng! Hãy ôn tập lại và thử lại sau.';
    }
  }
}

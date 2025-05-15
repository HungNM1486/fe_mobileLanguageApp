import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:language_app/hung_nm/profile/setting/goal/goal_time_screen.dart';
import 'package:language_app/provider/study_plans_provider.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/phu_nv/LoginSignup/login_screen.dart'; 

class GoalSettingsScreen extends StatefulWidget {
  const GoalSettingsScreen({super.key});

  @override
  State<GoalSettingsScreen> createState() => _GoalSettingsScreenState();
}

class _GoalSettingsScreenState extends State<GoalSettingsScreen> {
  String _selectedGoal = 'basic';

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadGoal();
  }

  Future<void> _checkAuthAndLoadGoal() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkAuthStatus();
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Loginscreen()),
      );
      return;
    }
    final provider = Provider.of<StudyPlansProvider>(context, listen: false);
    await provider.fetchStudyPlan(context);
    if (provider.studyPlan != null) {
      setState(() {
        _selectedGoal = _mapLevelToGoal(provider.studyPlan!.level);
      });
    }
  }

  String _mapLevelToGoal(String level) {
    switch (level) {
      case 'basic':
        return 'basic';
      case 'advanced':
        return 'advanced';
      case 'intensive':
        return 'expert';
      default:
        return 'basic';
    }
  }

  Future<void> _saveGoalAndContinue(String goal) async {
    setState(() {
      _selectedGoal = goal;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoalTimeScreen(goal: goal)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);
    final provider = Provider.of<StudyPlansProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chọn mục tiêu"),
        backgroundColor: const Color(0xff5B7BFE),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/images/goal_background.png'),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16 * pix),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn mục tiêu học tập của bạn',
                style: TextStyle(
                  fontSize: 20 * pix,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5B7BFE),
                ),
              ),
              SizedBox(height: 8 * pix),
              Text(
                'Mục tiêu sẽ giúp bạn duy trì động lực và theo dõi tiến độ học tập',
                style: TextStyle(
                  fontSize: 14 * pix,
                  color: Colors.grey[600],
                ),
              ),
              if (provider.isLoading)
                Center(child: CircularProgressIndicator()),
              if (provider.errorMessage != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8 * pix),
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14 * pix),
                  ),
                ),
              SizedBox(height: 24 * pix),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGoalCard(
                        'basic',
                        'Cơ bản',
                        'Học các kỹ năng giao tiếp hàng ngày và ngữ pháp cơ bản',
                        Icons.sentiment_satisfied_rounded,
                        Colors.green,
                        pix,
                      ),
                      SizedBox(height: 16 * pix),
                      _buildGoalCard(
                        'advanced',
                        'Nâng cao',
                        'Phát triển kỹ năng đọc, viết và giao tiếp nâng cao',
                        Icons.trending_up_rounded,
                        Colors.blue,
                        pix,
                      ),
                      SizedBox(height: 16 * pix),
                      _buildGoalCard(
                        'expert',
                        'Chuyên sâu',
                        'Làm chủ ngôn ngữ ở mức độ gần với người bản xứ',
                        Icons.military_tech_rounded,
                        Colors.purple,
                        pix,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16 * pix),
              _buildContinueButton(pix),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(
    String value,
    String title,
    String description,
    IconData icon,
    Color color,
    double pix,
  ) {
    final isSelected = _selectedGoal == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16 * pix),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16 * pix),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56 * pix,
                height: 56 * pix,
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30 * pix,
                ),
              ),
              SizedBox(width: 16 * pix),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18 * pix,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 24 * pix,
                          height: 24 * pix,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? color : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? color : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16 * pix,
                                )
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * pix),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14 * pix,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16 * pix),
                    _buildGoalFeatures(value, color, isSelected, pix),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalFeatures(
      String goalType, Color color, bool isSelected, double pix) {
    final List<String> features;

    switch (goalType) {
      case 'basic':
        features = [
          'Học 15-30 phút mỗi ngày',
          'Từ vựng cơ bản hàng ngày',
          'Ngữ pháp đơn giản',
        ];
        break;
      case 'advanced':
        features = [
          'Học 30-60 phút mỗi ngày',
          'Kỹ năng giao tiếp nâng cao',
          'Đọc và viết văn bản phức tạp',
        ];
        break;
      case 'expert':
        features = [
          'Học 60+ phút mỗi ngày',
          'Thành thạo như người bản xứ',
          'Ngữ pháp và từ vựng chuyên ngành',
        ];
        break;
      default:
        features = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: EdgeInsets.only(bottom: 8 * pix),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isSelected ? color : Colors.grey.shade400,
                      size: 16 * pix,
                    ),
                    SizedBox(width: 8 * pix),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13 * pix,
                          color: isSelected
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildContinueButton(double pix) {
    Color buttonColor;
    switch (_selectedGoal) {
      case 'basic':
        buttonColor = Colors.green;
        break;
      case 'advanced':
        buttonColor = Colors.blue;
        break;
      case 'expert':
        buttonColor = Colors.purple;
        break;
      default:
        buttonColor = const Color(0xff5B7BFE);
    }

    return Container(
      width: double.infinity,
      height: 56 * pix,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            buttonColor,
            buttonColor.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12 * pix),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _saveGoalAndContinue(_selectedGoal),
          borderRadius: BorderRadius.circular(12 * pix),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tiếp tục',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8 * pix),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20 * pix,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
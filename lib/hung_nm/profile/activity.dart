import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:language_app/models/user_session_model.dart';
import 'package:language_app/provider/user_session_provider.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _selectedTimeFilter = 'Ngày';
  final Color _primaryColor = const Color(0xFF5B7BFE);
  final Color _secondaryColor = const Color(0xFF20C3AF);
  final Color _backgroundColor = const Color(0xFFF8FAFF);
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadTimeFilter();

    // Tải dữ liệu từ API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _loadTimeFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFilter = prefs.getString('activity_time_filter') ?? 'Ngày';
    setState(() {
      _selectedTimeFilter = savedFilter;
    });
  }

  Future<void> _saveTimeFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activity_time_filter', filter);
    setState(() {
      _selectedTimeFilter = filter;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await Provider.of<UserSessionProvider>(context, listen: false)
          .getOverview();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải dữ liệu: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = (size.width / 375).clamp(0.8, 1.2);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE9EFFF),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Top bar
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TopBar(
                  title: 'Hoạt động',
                ),
              ),
            ),
            // Main content
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: Consumer<UserSessionProvider>(
                  builder: (context, sessionProvider, child) {
                // Kiểm tra trạng thái loading
                if (sessionProvider.isLoading || _isRefreshing) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Lấy dữ liệu từ provider
                final streakDays =
                    sessionProvider.loginStreak?.currentStreak ?? 0;
                final totalStudyTime = sessionProvider.totalStudyTime;

                return RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16 * pix),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          _buildAnimatedHeader(pix),
                          SizedBox(height: 24 * pix),

                          // Streak
                          _buildStreakCard(pix, streakDays),
                          SizedBox(height: 24 * pix),

                          // Learning time
                          _buildLearningTimeSection(pix, sessionProvider),
                          SizedBox(height: 24 * pix),

                          // Stats
                          _buildStatCardsRow(pix, totalStudyTime),
                          SizedBox(height: 24 * pix),

                          // Learning progress
                          _buildLearningProgress(pix),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Phần header có animation
  Widget _buildAnimatedHeader(double pix) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hoạt động học tập",
              style: TextStyle(
                fontSize: 22 * pix,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [
                      const Color(0xFF5B7BFE),
                      const Color(0xFF3B5AFE),
                    ],
                  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
            SizedBox(height: 4 * pix),
            Text(
              "Theo dõi quá trình học của bạn",
              style: TextStyle(
                fontSize: 14 * pix,
                fontFamily: 'BeVietnamPro',
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.all(10 * pix),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12 * pix),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.insights,
            color: const Color(0xFF5B7BFE),
            size: 24 * pix,
          ),
        ),
      ],
    );
  }

  // Thẻ streak
  Widget _buildStreakCard(double pix, int streakDays) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5B7BFE),
            const Color(0xFF3B5AFE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20 * pix),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B7BFE).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 28 * pix,
                  ),
                  SizedBox(width: 8 * pix),
                  Text(
                    'Streak hiện tại',
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontFamily: 'BeVietnamPro',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * pix,
                  vertical: 6 * pix,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20 * pix),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: Colors.amber,
                      size: 16 * pix,
                    ),
                    SizedBox(width: 4 * pix),
                    Text(
                      '$streakDays ngày',
                      style: TextStyle(
                        fontSize: 14 * pix,
                        fontFamily: 'BeVietnamPro',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * pix),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (index) => _buildDayIndicator(index, pix, streakDays),
            ),
          ),
        ],
      ),
    );
  }

  // Thẻ thể hiện các ngày trong streak
  Widget _buildDayIndicator(int index, double pix, int streakDays) {
    final bool isActive = index < streakDays % 7;

    return Column(
      children: [
        Container(
          width: 30 * pix,
          height: 30 * pix,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: isActive
                ? const Color(0xFF5B7BFE)
                : Colors.white.withOpacity(0.5),
            size: 16 * pix,
          ),
        ),
        SizedBox(height: 4 * pix),
        Text(
          ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][index],
          style: TextStyle(
            fontSize: 12 * pix,
            fontFamily: 'BeVietnamPro',
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  // Phần thống kê thời gian học tập
  Widget _buildLearningTimeSection(
      double pix, UserSessionProvider sessionProvider) {
    // Lấy dữ liệu tương ứng với filter
    List<SessionStatisticItem> data;
    switch (_selectedTimeFilter) {
      case 'Ngày':
        data = sessionProvider.dailyData;
        break;
      case 'Tuần':
        data = sessionProvider.weeklyData;
        break;
      case 'Tháng':
        data = sessionProvider.monthlyData;
        break;
      default:
        data = sessionProvider.dailyData;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * pix),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thời gian học tập",
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * pix,
                  vertical: 6 * pix,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20 * pix),
                ),
                child: DropdownButton<String>(
                  value: _selectedTimeFilter,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF5B7BFE),
                  ),
                  iconSize: 20 * pix,
                  elevation: 16,
                  style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5B7BFE),
                  ),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _saveTimeFilter(newValue);
                    }
                  },
                  items: <String>['Ngày', 'Tuần', 'Tháng']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  dropdownColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * pix),
          SizedBox(
            height: 250 * pix,
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'Không có dữ liệu thời gian học tập',
                      style: TextStyle(
                        fontSize: 14 * pix,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(data),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: EdgeInsets.all(8 * pix),
                          tooltipMargin: 8 * pix,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final hours = rod.toY.floor();
                            final minutes = ((rod.toY - hours) * 60).round();
                            return BarTooltipItem(
                              '$hours h $minutes m',
                              TextStyle(
                                color: Colors.white,
                                fontSize: 12 * pix,
                                fontFamily: 'BeVietnamPro',
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) =>
                                _bottomTitles(value, pix, data),
                            reservedSize: 30 * pix,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}h',
                              style: TextStyle(
                                fontSize: 12 * pix,
                                fontFamily: 'BeVietnamPro',
                                color: Colors.grey,
                              ),
                            ),
                            reservedSize: 40 * pix,
                            interval: _getYInterval(data),
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(pix, data),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Các thẻ thống kê
  Widget _buildStatCardsRow(double pix, double totalStudyTime) {
    final hours = totalStudyTime.floor();
    final minutes = ((totalStudyTime - hours) * 60).round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          pix: pix,
          icon: Icons.timer,
          label: "Tổng thời gian học",
          value: "$hours h $minutes m",
          color: const Color(0xFF5B7BFE),
          gradientColors: [
            const Color(0xFF5B7BFE),
            const Color(0xFF3B5AFE),
          ],
        ),
      ],
    );
  }

  // Phần tiến độ học tập
  Widget _buildLearningProgress(double pix) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * pix),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * pix),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tiến độ học tập",
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontFamily: 'BeVietnamPro',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * pix,
                  vertical: 6 * pix,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20 * pix),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 16 * pix,
                    ),
                    SizedBox(width: 4 * pix),
                    Consumer<UserSessionProvider>(
                        builder: (context, provider, child) {
                      // Placeholder data - in a real app, get this from API
                      final totalWords = 320;
                      return Text(
                        "$totalWords từ vựng",
                        style: TextStyle(
                          fontSize: 12 * pix,
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * pix),

          // Danh sách tiến độ các kỹ năng
          _buildSkillProgressItem(
            pix,
            "Từ vựng",
            0.8,
            const Color(0xFF5B7BFE),
          ),
          SizedBox(height: 12 * pix),
          _buildSkillProgressItem(
            pix,
            "Ngữ pháp",
            0.65,
            const Color(0xFF4CAF50),
          ),
          SizedBox(height: 12 * pix),
          _buildSkillProgressItem(
            pix,
            "Nghe",
            0.45,
            const Color(0xFFFFA000),
          ),
          SizedBox(height: 12 * pix),
          _buildSkillProgressItem(
            pix,
            "Nói",
            0.3,
            const Color(0xFFF44336),
          ),
        ],
      ),
    );
  }

  // Tạo mục tiến độ kỹ năng
  Widget _buildSkillProgressItem(
    double pix,
    String skill,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skill,
              style: TextStyle(
                fontSize: 14 * pix,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(
                fontSize: 14 * pix,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * pix),
        Stack(
          children: [
            Container(
              height: 8 * pix,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4 * pix),
              ),
            ),
            Container(
              height: 8 * pix,
              width: MediaQuery.of(context).size.width * progress - 72 * pix,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(4 * pix),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tạo khung thống kê
  Widget _buildStatCard({
    required double pix,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required List<Color> gradientColors,
  }) {
    return Container(
      width: 150 * pix,
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20 * pix),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12 * pix),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30 * pix,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12 * pix),
          Text(
            label,
            style: TextStyle(
              fontSize: 14 * pix,
              fontFamily: 'BeVietnamPro',
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8 * pix),
          Text(
            value,
            style: TextStyle(
              fontSize: 18 * pix,
              fontFamily: 'BeVietnamPro',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Tạo các cột biểu đồ
  List<BarChartGroupData> _buildBarGroups(
      double pix, List<SessionStatisticItem> data) {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index].totalTime,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF5B7BFE),
                const Color(0xFF3B5AFE),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            width: 20 * pix,
            borderRadius: BorderRadius.circular(4 * pix),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(data),
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
  }

  // Tạo tiêu đề trục X
  Widget _bottomTitles(
      double value, double pix, List<SessionStatisticItem> data) {
    final index = value.toInt();
    if (index >= data.length) return const SizedBox();

    return Padding(
      padding: EdgeInsets.only(top: 8 * pix),
      child: Text(
        data[index].dayOrMonth,
        style: TextStyle(
          fontSize: 12 * pix,
          fontFamily: 'BeVietnamPro',
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Tính giá trị tối đa trục Y
  double _getMaxY(List<SessionStatisticItem> data) {
    if (data.isEmpty) return 10; // Giá trị mặc định nếu không có dữ liệu

    double maxValue =
        data.map((item) => item.totalTime).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2)
        .ceilToDouble(); // Thêm 20% để có khoảng cách trên biểu đồ
  }

  // Tính khoảng cách trục Y
  double _getYInterval(List<SessionStatisticItem> data) {
    final maxY = _getMaxY(data);
    return (maxY / 5).ceilToDouble();
  }
}

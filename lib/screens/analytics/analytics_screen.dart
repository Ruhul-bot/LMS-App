import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;

  // Sample data for analytics
  // In a real app, this would come from the backend
  final Map<String, double> _courseProgress = {
    'Mathematics': 85,
    'Physics': 70,
    'Chemistry': 60,
    'Biology': 90,
    'Computer Science': 75,
  };

  final List<Map<String, dynamic>> _quizScores = [
    {'name': 'Mathematics Quiz 1', 'score': 85, 'date': '10/01/2023'},
    {'name': 'Physics Quiz 1', 'score': 70, 'date': '15/01/2023'},
    {'name': 'Chemistry Quiz 1', 'score': 60, 'date': '20/01/2023'},
    {'name': 'Mathematics Quiz 2', 'score': 90, 'date': '25/01/2023'},
    {'name': 'Physics Quiz 2', 'score': 75, 'date': '30/01/2023'},
  ];

  final List<Map<String, dynamic>> _weeklyActivity = [
    {'day': 'Mon', 'hours': 2.5},
    {'day': 'Tue', 'hours': 1.8},
    {'day': 'Wed', 'hours': 3.2},
    {'day': 'Thu', 'hours': 2.0},
    {'day': 'Fri', 'hours': 1.5},
    {'day': 'Sat', 'hours': 4.0},
    {'day': 'Sun', 'hours': 3.0},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you would fetch data from your backend here
      // For now, we'll just simulate a delay
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'My Progress',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'COURSES'),
            Tab(text: 'QUIZZES'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorWidget()
              : TabBarView(
                controller: _tabController,
                children: [
                  // Overview Tab
                  _buildOverviewTab(user?.displayName ?? 'Student'),

                  // Courses Tab
                  _buildCoursesTab(),

                  // Quizzes Tab
                  _buildQuizzesTab(),
                ],
              ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text('Error loading analytics', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchAnalyticsData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(String userName) {
    // Calculate total study hours
    final totalHours = _weeklyActivity.fold<double>(
      0,
      (sum, item) => sum + (item['hours'] as double),
    );

    // Calculate average quiz score
    final averageScore =
        _quizScores.isEmpty
            ? 0.0
            : _quizScores.fold<double>(
                  0,
                  (sum, item) => sum + (item['score'] as int),
                ) /
                _quizScores.length;

    // Calculate completed courses
    final completedCourses =
        _courseProgress.values.where((progress) => progress >= 100).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Message
          Text('Hello, $userName!', style: AppTextStyles.heading1),
          const SizedBox(height: 8),
          Text(
            'Here\'s your learning progress',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.lightTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer,
                  value: totalHours.toStringAsFixed(1),
                  label: 'Study Hours',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.school,
                  value: completedCourses.toString(),
                  label: 'Completed Courses',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.quiz,
                  value: _quizScores.length.toString(),
                  label: 'Quizzes Taken',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.grade,
                  value: '${averageScore.toStringAsFixed(1)}%',
                  label: 'Avg. Quiz Score',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly Activity Chart
          _buildWeeklyActivityChart(),
          const SizedBox(height: 24),

          // Recent Activity
          Text('Recent Activity', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          _buildRecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.lightTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Fixed Weekly Activity Chart
  Widget _buildWeeklyActivityChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Activity', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 5,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_weeklyActivity[group.x.toInt()]['day']}: ${rod.toY.toStringAsFixed(1)} hrs',
                        const TextStyle(
                          color: Colors.white,
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
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            _weeklyActivity[value.toInt()]['day'],
                            style: AppTextStyles.smallText,
                          ),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        if (value == 0) {
                          text = '0';
                        } else if (value == 2.5) {
                          text = '2.5';
                        } else if (value == 5) {
                          text = '5';
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            text,
                            style: AppTextStyles.smallText.copyWith(
                              color: AppColors.lightTextColor,
                            ),
                          ),
                        );
                      },
                      interval: 2.5,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    _weeklyActivity.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data['hours'],
                            color: AppColors.primaryColor,
                            width: 22,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    final activities = [
      {
        'icon': Icons.play_circle_filled,
        'title': 'Watched a lecture',
        'description': 'Introduction to Calculus',
        'time': '2 hours ago',
      },
      {
        'icon': Icons.assignment_turned_in,
        'title': 'Completed a quiz',
        'description': 'Physics Quiz 2',
        'time': '1 day ago',
      },
      {
        'icon': Icons.book,
        'title': 'Started a new course',
        'description': 'Computer Science Fundamentals',
        'time': '2 days ago',
      },
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: AppColors.primaryColor,
                size: 24,
              ),
            ),
            title: Text(
              activity['title'] as String,
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              activity['description'] as String,
              style: AppTextStyles.smallText,
            ),
            trailing: Text(
              activity['time'] as String,
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.lightTextColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoursesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Course Progress', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        ..._courseProgress.entries.map(
          (entry) => _buildCourseProgressCard(
            courseName: entry.key,
            progress: entry.value,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseProgressCard({
    required String courseName,
    required double progress,
  }) {
    final isCompleted = progress >= 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    courseName,
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isCompleted
                            ? AppColors.successColor.withValues(alpha: 0.1)
                            : AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : '${progress.toInt()}%',
                    style: AppTextStyles.smallText.copyWith(
                      color:
                          isCompleted
                              ? AppColors.successColor
                              : AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? AppColors.successColor : AppColors.primaryColor,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCompleted
                      ? 'Completed on 15/01/2023'
                      : 'Last accessed 2 days ago',
                  style: AppTextStyles.smallText.copyWith(
                    color: AppColors.lightTextColor,
                  ),
                ),
                if (!isCompleted)
                  TextButton(
                    onPressed: () {
                      // Navigate to course
                    },
                    child: Text(
                      'Continue',
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
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

  Widget _buildQuizzesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Quiz Performance', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        _buildQuizPerformanceChart(),
        const SizedBox(height: 24),
        Text('Quiz History', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        ..._quizScores.map(
          (quiz) => _buildQuizScoreCard(
            quizName: quiz['name'],
            score: quiz['score'],
            date: quiz['date'],
          ),
        ),
      ],
    );
  }

  // Fixed Quiz Performance Chart
  Widget _buildQuizPerformanceChart() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz Scores', style: AppTextStyles.heading3),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              'Q${value.toInt() + 1}',
                              style: AppTextStyles.smallText,
                            ),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          String text = '';
                          if (value == 0) {
                            text = '0';
                          } else if (value == 50) {
                            text = '50';
                          } else if (value == 100) {
                            text = '100';
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              text,
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.lightTextColor,
                              ),
                            ),
                          );
                        },
                        interval: 50,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  minX: 0,
                  maxX: _quizScores.length.toDouble() - 1,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          _quizScores.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value['score'].toDouble(),
                            );
                          }).toList(),
                      isCurved: true,
                      color: AppColors.primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.2),
                            AppColors.primaryColor.withValues(alpha: 0.0),
                          ],
                          stops: const [0.5, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizScoreCard({
    required String quizName,
    required int score,
    required String date,
  }) {
    final isPassed = score >= 60;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    isPassed
                        ? AppColors.successColor.withValues(alpha: 0.1)
                        : AppColors.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$score%',
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isPassed
                            ? AppColors.successColor
                            : AppColors.errorColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quizName,
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Taken on $date',
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isPassed
                        ? AppColors.successColor.withValues(alpha: 0.1)
                        : AppColors.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPassed ? 'Passed' : 'Failed',
                style: AppTextStyles.smallText.copyWith(
                  color:
                      isPassed ? AppColors.successColor : AppColors.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/lecture_model.dart';
import '../../providers/course_provider.dart';
import 'live_player_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;
  List<LectureModel> _liveLectures = [];
  List<LectureModel> _upcomingLectures = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLiveLectures();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveLectures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );
      await courseProvider.fetchLiveLectures();

      // Filter lectures into live and upcoming
      final allLiveLectures = courseProvider.liveLectures;
      final now = DateTime.now();

      setState(() {
        _liveLectures =
            allLiveLectures
                .where(
                  (lecture) =>
                      lecture.isLive &&
                      lecture.scheduledTime != null &&
                      lecture.scheduledTime!.isBefore(now) &&
                      lecture.endTime != null &&
                      lecture.endTime!.isAfter(now),
                )
                .toList();

        _upcomingLectures =
            allLiveLectures
                .where(
                  (lecture) =>
                      lecture.isLive &&
                      lecture.scheduledTime != null &&
                      lecture.scheduledTime!.isAfter(now),
                )
                .toList();

        // Sort upcoming lectures by scheduled time
        _upcomingLectures.sort(
          (a, b) => a.scheduledTime!.compareTo(b.scheduledTime!),
        );

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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Live Classes',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'LIVE NOW'), Tab(text: 'UPCOMING')],
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
                  // Live Now Tab
                  _buildLiveNowTab(),

                  // Upcoming Tab
                  _buildUpcomingTab(),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchLiveLectures,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.refresh),
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
          Text('Error loading live classes', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchLiveLectures,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveNowTab() {
    if (_liveLectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.live_tv_outlined,
              size: 64,
              color: AppColors.lightTextColor,
            ),
            const SizedBox(height: 16),
            Text('No Live Classes', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'There are no live classes at the moment.\nCheck the upcoming tab for scheduled classes.',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _liveLectures.length,
      itemBuilder: (context, index) {
        return _buildLiveClassCard(_liveLectures[index], isLive: true);
      },
    );
  }

  Widget _buildUpcomingTab() {
    if (_upcomingLectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_outlined,
              size: 64,
              color: AppColors.lightTextColor,
            ),
            const SizedBox(height: 16),
            Text('No Upcoming Classes', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'There are no upcoming live classes scheduled.',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingLectures.length,
      itemBuilder: (context, index) {
        return _buildLiveClassCard(_upcomingLectures[index], isLive: false);
      },
    );
  }

  Widget _buildLiveClassCard(LectureModel lecture, {required bool isLive}) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final course = courseProvider.getCourseById(lecture.courseId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: 3,
      child: InkWell(
        onTap:
            isLive
                ? () => _navigateToLivePlayer(lecture)
                : () => _showReminderDialog(lecture),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Badge or Scheduled Time
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isLive ? Colors.red : AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.borderRadius),
                  topRight: Radius.circular(AppSizes.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isLive ? Icons.live_tv : Icons.event,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLive
                        ? 'LIVE NOW'
                        : 'Scheduled: ${_formatDateTime(lecture.scheduledTime!)}',
                    style: AppTextStyles.smallText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Lecture Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(lecture.title, style: AppTextStyles.heading3),
                  const SizedBox(height: 8),

                  // Course Name
                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 16,
                        color: AppColors.lightTextColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          course?.title ?? 'Unknown Course',
                          style: AppTextStyles.bodyText,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Instructor
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.lightTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        course?.instructor ?? 'Unknown Instructor',
                        style: AppTextStyles.bodyText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Duration
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: AppColors.lightTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${lecture.durationInMinutes} minutes',
                        style: AppTextStyles.bodyText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          isLive
                              ? () => _navigateToLivePlayer(lecture)
                              : () => _showReminderDialog(lecture),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isLive ? Colors.red : AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(
                        isLive ? Icons.play_arrow : Icons.notifications_active,
                      ),
                      label: Text(
                        isLive ? 'Join Now' : 'Set Reminder',
                        style: AppTextStyles.buttonText,
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

  void _navigateToLivePlayer(LectureModel lecture) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LivePlayerScreen(lecture: lecture),
      ),
    );
  }

  void _showReminderDialog(LectureModel lecture) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Set Reminder', style: AppTextStyles.heading2),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Would you like to be notified when "${lecture.title}" goes live?',
                  style: AppTextStyles.bodyText,
                ),
                const SizedBox(height: 16),
                Text(
                  'Scheduled for:',
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(lecture.scheduledTime!),
                  style: AppTextStyles.bodyText,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.lightTextColor,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement notification scheduling
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder set successfully!'),
                      backgroundColor: AppColors.successColor,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: Text(
                  'Set Reminder',
                  style: AppTextStyles.bodyText.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
  }
}

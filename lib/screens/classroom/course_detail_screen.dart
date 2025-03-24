import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/course_model.dart';
import '../../models/lecture_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/custom_button.dart';
import '../payment/payment_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch course details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(
        context,
        listen: false,
      ).selectCourse(widget.courseId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          if (courseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (courseProvider.errorMessage != null) {
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
                  Text('Error loading course', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    courseProvider.errorMessage!,
                    style: AppTextStyles.bodyText,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      courseProvider.selectCourse(widget.courseId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final course = courseProvider.selectedCourse;

          if (course == null) {
            return const Center(child: Text('Course not found'));
          }

          return _buildCourseDetailContent(course, courseProvider);
        },
      ),
    );
  }

  Widget _buildCourseDetailContent(
    CourseModel course,
    CourseProvider courseProvider,
  ) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isEnrolled =
        authProvider.userModel?.enrolledCourses.contains(course.id) ?? false;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                course.title,
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              background:
                  course.thumbnailUrl != null
                      ? Image.network(
                        course.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.7,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.school,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        color: AppColors.primaryColor.withValues(alpha: 0.7),
                        child: const Center(
                          child: Icon(
                            Icons.school,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
            ),
          ),
        ];
      },
      body: Column(
        children: [
          // Course Info Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and Enroll Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.price > 0
                              ? '₹${course.price.toStringAsFixed(2)}'
                              : 'Free',
                          style: AppTextStyles.heading2.copyWith(
                            color:
                                course.price > 0
                                    ? AppColors.textColor
                                    : AppColors.accentColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Instructor: ${course.instructor}',
                          style: AppTextStyles.smallText,
                        ),
                      ],
                    ),
                    CustomButton(
                      text:
                          isEnrolled
                              ? 'Enrolled'
                              : (course.price > 0 ? 'Buy Now' : 'Enroll Now'),
                      onPressed:
                          isEnrolled
                              ? () {}
                              : () => _handleEnrollment(course, authProvider),
                      isOutlined: isEnrolled,
                      backgroundColor:
                          isEnrolled ? null : AppColors.accentColor,
                      width: 120,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Course Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.video_library_outlined,
                      value: '${course.totalLectures}',
                      label: 'Lectures',
                    ),
                    _buildStatItem(
                      icon: Icons.quiz_outlined,
                      value: '${course.totalQuizzes}',
                      label: 'Quizzes',
                    ),
                    _buildStatItem(
                      icon: Icons.topic_outlined,
                      value: '${course.topics.length}',
                      label: 'Topics',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.lightTextColor,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'About'),
              Tab(text: 'Lectures'),
              Tab(text: 'Reviews'),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // About Tab
                _buildAboutTab(course),

                // Lectures Tab
                _buildLecturesTab(courseProvider),

                // Reviews Tab
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.heading3),
        Text(label, style: AppTextStyles.smallText),
      ],
    );
  }

  Widget _buildAboutTab(CourseModel course) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text('Description', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(course.description, style: AppTextStyles.bodyText),
          const SizedBox(height: 24),

          // Topics
          Text('Topics Covered', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          ...course.topics.map(
            (topic) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.accentColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(topic, style: AppTextStyles.bodyText)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Last Updated
          Text(
            'Last Updated: ${_formatDate(course.updatedAt)}',
            style: AppTextStyles.smallText,
          ),
        ],
      ),
    );
  }

  Widget _buildLecturesTab(CourseProvider courseProvider) {
    final lectures = courseProvider.courseLectures;
    final authProvider = Provider.of<AuthProvider>(context);
    final isEnrolled =
        authProvider.userModel?.enrolledCourses.contains(widget.courseId) ??
        false;

    if (!isEnrolled) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.lightTextColor,
            ),
            const SizedBox(height: 16),
            Text('Enroll to access lectures', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'You need to enroll in this course to access the lectures.',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (lectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library_outlined,
              size: 64,
              color: AppColors.lightTextColor,
            ),
            const SizedBox(height: 16),
            Text('No lectures available', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Lectures for this course will be available soon.',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lectures.length,
      itemBuilder: (context, index) {
        return _buildLectureItem(lectures[index], index);
      },
    );
  }

  Widget _buildLectureItem(LectureModel lecture, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
                lecture.isLive
                    ? const Icon(Icons.live_tv, color: Colors.red)
                    : Text(
                      '${index + 1}',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
          ),
        ),
        title: Text(
          lecture.title,
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${lecture.durationInMinutes} min',
              style: AppTextStyles.smallText,
            ),
            if (lecture.isLive && lecture.scheduledTime != null)
              Text(
                'Scheduled: ${_formatDateTime(lecture.scheduledTime!)}',
                style: AppTextStyles.smallText.copyWith(color: Colors.red),
              ),
          ],
        ),
        trailing: const Icon(Icons.play_circle_outline),
        onTap: () {
          // Navigate to video player or live stream
          // This will be implemented in the next steps
        },
      ),
    );
  }

  Widget _buildReviewsTab() {
    // Placeholder for reviews tab
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star_outline,
            size: 64,
            color: AppColors.lightTextColor,
          ),
          const SizedBox(height: 16),
          Text('No reviews yet', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Be the first to review this course!',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // void _handleEnrollment(CourseModel course, AuthProvider authProvider) {
  //   if (course.price > 0) {
  //     // Navigate to payment screen
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => PaymentScreen(
  //           courseId: course.id,
  //           amount: course.price,
  //         ),
  //       ),
  //     );
  //   } else {
  //     // Free course, enroll directly
  //     final courseProvider = Provider.of<CourseProvider>(context, listen: false);

  //     courseProvider.enrollInCourse(
  //       authProvider.userModel!.uid,
  //       course.id,
  //     ).then((success) {
  //       if (success) {
  //         if (!context.mounted) return;
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Successfully enrolled in the course!'),
  //             backgroundColor: AppColors.successColor,
  //           ),
  //         );

  //         // Refresh the course details
  //         courseProvider.selectCourse(course.id);
  //       }
  //     });
  //   }
  // }

  void _handleEnrollment(CourseModel course, AuthProvider authProvider) {
    if (course.price > 0) {
      // Navigate to payment screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) =>
                  PaymentScreen(courseId: course.id, amount: course.price),
        ),
      );
    } else {
      // Free course, enroll directly
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );

      courseProvider.enrollInCourse(authProvider.userModel!.uid, course.id).then((
        success,
      ) {
        // Store this in a local variable to avoid direct context use after async gap
        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully enrolled in the course!'),
              backgroundColor: AppColors.successColor,
            ),
          );

          // This is also using context indirectly via Provider.of
          // Make sure we're still mounted
          if (mounted) {
            // Refresh the course details
            courseProvider.selectCourse(course.id);
          }
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

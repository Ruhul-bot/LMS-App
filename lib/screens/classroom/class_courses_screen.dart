import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';
import 'course_detail_screen.dart';

class ClassCoursesScreen extends StatefulWidget {
  final String classLevel;
  final String title;

  const ClassCoursesScreen({
    super.key,
    required this.classLevel,
    required this.title,
  });

  @override
  State<ClassCoursesScreen> createState() => _ClassCoursesScreenState();
}

class _ClassCoursesScreenState extends State<ClassCoursesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch courses for this class level
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(
        context,
        listen: false,
      ).fetchCoursesByClassLevel(widget.classLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          widget.title,
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
      ),
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
                  Text('Error loading courses', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    courseProvider.errorMessage!,
                    style: AppTextStyles.bodyText,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      courseProvider.fetchCoursesByClassLevel(
                        widget.classLevel,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final courses = courseProvider.classCourses;

          if (courses.isEmpty) {
            return _buildEmptyState();
          }

          return _buildCoursesList(courses);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.lightTextColor,
          ),
          const SizedBox(height: 16),
          Text('No courses available', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'There are no courses available for ${widget.title} at the moment.',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(List<CourseModel> courses) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: InkWell(
        onTap: () => _navigateToCourseDetail(course.id),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borderRadius),
                topRight: Radius.circular(AppSizes.borderRadius),
              ),
              child: Container(
                height: 160,
                width: double.infinity,
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                child:
                    course.thumbnailUrl != null
                        ? Image.network(
                          course.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            );
                          },
                        )
                        : Center(
                          child: Icon(
                            Icons.school_outlined,
                            size: 48,
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
              ),
            ),

            // Course Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    course.title,
                    style: AppTextStyles.heading3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Instructor
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.lightTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Instructor: ${course.instructor}',
                        style: AppTextStyles.smallText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Lectures and Quizzes
                  Row(
                    children: [
                      const Icon(
                        Icons.video_library_outlined,
                        size: 16,
                        color: AppColors.lightTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.totalLectures} lectures',
                        style: AppTextStyles.smallText,
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.quiz_outlined,
                        size: 16,
                        color: AppColors.lightTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.totalQuizzes} quizzes',
                        style: AppTextStyles.smallText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    course.description,
                    style: AppTextStyles.bodyText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Price and Enroll Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        course.price > 0
                            ? '₹${course.price.toStringAsFixed(2)}'
                            : 'Free',
                        style: AppTextStyles.heading3.copyWith(
                          color:
                              course.price > 0
                                  ? AppColors.textColor
                                  : AppColors.accentColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToCourseDetail(course.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCourseDetail(String courseId) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    courseProvider.selectCourse(courseId);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(courseId: courseId),
      ),
    );
  }
}

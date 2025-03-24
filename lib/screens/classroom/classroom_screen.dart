import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/course_provider.dart';
import 'class_courses_screen.dart';

class ClassroomScreen extends StatelessWidget {
  const ClassroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Classroom',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a Class', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text(
                'Choose your class level to browse available courses',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.lightTextColor,
                ),
              ),
              const SizedBox(height: 24),

              // Class Levels Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  // Class 9
                  _buildClassCard(
                    context,
                    classLevel: '9',
                    title: 'Class 9',
                    color: Colors.blue,
                    icon: Icons.filter_9,
                  ),

                  // Class 10
                  _buildClassCard(
                    context,
                    classLevel: '10',
                    title: 'Class 10',
                    color: Colors.green,
                    icon: Icons.filter_list,
                  ),

                  // Class 11
                  _buildClassCard(
                    context,
                    classLevel: '11',
                    title: 'Class 11',
                    color: Colors.orange,
                    icon: Icons.filter_1,
                  ),

                  // Class 12
                  _buildClassCard(
                    context,
                    classLevel: '12',
                    title: 'Class 12',
                    color: Colors.purple,
                    icon: Icons.filter_2,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Miscellaneous Section
              _buildMiscellaneousCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required String classLevel,
    required String title,
    required Color color,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => _navigateToClassCourses(context, classLevel, title),
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'View Courses',
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiscellaneousCard(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToClassCourses(context, 'misc', 'Miscellaneous'),
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.category_outlined,
                size: 32,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Miscellaneous Courses', style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(
                    'Competitive exams, skill development, and more',
                    style: AppTextStyles.smallText,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.lightTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToClassCourses(
    BuildContext context,
    String classLevel,
    String title,
  ) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    courseProvider.fetchCoursesByClassLevel(classLevel);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                ClassCoursesScreen(classLevel: classLevel, title: title),
      ),
    );
  }
}

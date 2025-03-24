import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../classroom/classroom_screen.dart';
import '../live/live_screen.dart';
import '../quiz/quiz_screen.dart';
import '../analytics/analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'LMS App',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Welcome, ${authProvider.userModel?.displayName ?? 'Student'}!',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                'What would you like to learn today?',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.lightTextColor,
                ),
              ),
              const SizedBox(height: 24),

              // Feature Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  // Classroom Widget
                  _buildFeatureCard(
                    context,
                    title: 'Classroom',
                    icon: Icons.class_outlined,
                    color: Colors.blue,
                    onTap:
                        () =>
                            _navigateToScreen(context, const ClassroomScreen()),
                  ),

                  // Live Streaming Widget
                  _buildFeatureCard(
                    context,
                    title: 'Live Classes',
                    icon: Icons.live_tv_outlined,
                    color: Colors.red,
                    onTap: () => _navigateToScreen(context, const LiveScreen()),
                  ),

                  // Quizzes Widget
                  _buildFeatureCard(
                    context,
                    title: 'Quizzes',
                    icon: Icons.quiz_outlined,
                    color: Colors.orange,
                    onTap: () => _navigateToScreen(context, const QuizScreen()),
                  ),

                  // Analytics Widget
                  _buildFeatureCard(
                    context,
                    title: 'My Progress',
                    icon: Icons.analytics_outlined,
                    color: Colors.green,
                    onTap:
                        () =>
                            _navigateToScreen(context, const AnalyticsScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Enrolled Courses Section
              Text('My Enrolled Courses', style: AppTextStyles.heading2),
              const SizedBox(height: 16),

              // Placeholder for enrolled courses
              Container(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 48,
                      color: AppColors.lightTextColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You haven\'t enrolled in any courses yet.',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.lightTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Browse Courses',
                      onPressed:
                          () => _navigateToScreen(
                            context,
                            const ClassroomScreen(),
                          ),
                      width: size.width * 0.6,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Upcoming Live Classes
              Text('Upcoming Live Classes', style: AppTextStyles.heading2),
              const SizedBox(height: 16),

              // Placeholder for upcoming live classes
              Container(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.event_outlined,
                      size: 48,
                      color: AppColors.lightTextColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No upcoming live classes scheduled.',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.lightTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'View Schedule',
                      onPressed:
                          () => _navigateToScreen(context, const LiveScreen()),
                      width: size.width * 0.6,
                      isOutlined: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Logout', style: AppTextStyles.heading2),
            content: Text(
              'Are you sure you want to logout?',
              style: AppTextStyles.bodyText,
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
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  authProvider.signOut();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                ),
                child: Text(
                  'Logout',
                  style: AppTextStyles.bodyText.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

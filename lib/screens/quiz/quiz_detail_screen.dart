import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/quiz_model.dart';
import '../../providers/course_provider.dart';

class QuizDetailScreen extends StatelessWidget {
  final String quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);

    // Find the quiz by ID
    final quiz = courseProvider.courseQuizzes.firstWhere(
      (q) => q.id == quizId,
      orElse:
          () => courseProvider.allQuizzes.firstWhere(
            (q) => q.id == quizId,
            orElse: () => throw Exception('Quiz not found'),
          ),
    );

    final course = courseProvider.getCourseById(quiz.courseId);

    // Simulate a completed quiz for demo purposes
    // In a real app, you would check if the user has completed this quiz
    final bool isCompleted =
        courseProvider.allQuizzes.isNotEmpty &&
        quiz.id == courseProvider.allQuizzes[0].id;

    // Simulate a score for a completed quiz
    final int? score = isCompleted ? 85 : null;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Quiz Details',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Title
            Text(quiz.title, style: AppTextStyles.heading1),
            const SizedBox(height: 8),

            // Course Name
            if (course != null)
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
                      course.title,
                      style: AppTextStyles.bodyText,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Quiz Status Card
            _buildStatusCard(isCompleted, score, quiz),
            const SizedBox(height: 24),

            // Quiz Info
            Text('Quiz Information', style: AppTextStyles.heading2),
            const SizedBox(height: 16),

            // Quiz Info Card
            _buildInfoCard(quiz),
            const SizedBox(height: 24),

            // Quiz Description
            Text('Description', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(quiz.description, style: AppTextStyles.bodyText),
            const SizedBox(height: 24),

            // Instructions
            Text('Instructions', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            ..._buildInstructions(),
            const SizedBox(height: 32),

            // Start Quiz Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isCompleted
                        ? () => _showResultsDialog(context, score ?? 0)
                        : () => _navigateToQuizAttempt(context, quiz),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCompleted
                          ? AppColors.lightTextColor
                          : AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(isCompleted ? Icons.visibility : Icons.play_arrow),
                label: Text(
                  isCompleted ? 'View Results' : 'Start Quiz',
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isCompleted, int? score, QuizModel quiz) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          color:
              isCompleted
                  ? AppColors.successColor.withValues(alpha: 0.1)
                  : AppColors.primaryColor.withValues(alpha: 0.1),
        ),
        child: Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.quiz_outlined,
              size: 48,
              color:
                  isCompleted ? AppColors.successColor : AppColors.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted ? 'Quiz Completed' : 'Quiz Not Attempted',
              style: AppTextStyles.heading3.copyWith(
                color:
                    isCompleted
                        ? AppColors.successColor
                        : AppColors.primaryColor,
              ),
            ),
            if (isCompleted && score != null) ...[
              const SizedBox(height: 8),
              Text(
                'Your Score: $score%',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                score >= quiz.passingScore ? 'Passed' : 'Failed',
                style: AppTextStyles.bodyText.copyWith(
                  color:
                      score >= quiz.passingScore
                          ? AppColors.successColor
                          : AppColors.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(QuizModel quiz) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.help_outline,
              'Questions',
              '${quiz.questions.length} questions',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.timer_outlined,
              'Time Limit',
              '${quiz.timeLimit} minutes',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.check_circle_outline,
              'Passing Score',
              '${quiz.passingScore}%',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.repeat,
              'Attempts Allowed',
              '${quiz.attemptsAllowed}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.bodyText),
        ],
      ),
    );
  }

  List<Widget> _buildInstructions() {
    final instructions = [
      'Read each question carefully before answering.',
      'Once you submit your answers, you cannot change them.',
      'You must score at least the passing score to pass the quiz.',
      'The timer will start once you begin the quiz.',
      'Make sure you have a stable internet connection.',
    ];

    return instructions.map((instruction) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.arrow_right,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(instruction, style: AppTextStyles.bodyText)),
          ],
        ),
      );
    }).toList();
  }

  void _navigateToQuizAttempt(BuildContext context, QuizModel quiz) {
    Navigator.pushNamed(context, '/quiz-attempt', arguments: {'quiz': quiz});
  }

  void _showResultsDialog(BuildContext context, int score) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quiz Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                const SizedBox(height: 16),
                Text('Your Score: $score%'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

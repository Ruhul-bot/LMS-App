import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/quiz_model.dart';
import '../../providers/course_provider.dart';
import 'quiz_detail_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<QuizModel> _availableQuizzes = [];
  List<QuizModel> _completedQuizzes = [];

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );
      await courseProvider.fetchAllQuizzes();

      final allQuizzes = courseProvider.allQuizzes;

      // In a real app, you would check which quizzes the user has completed
      // For now, we'll just simulate some completed quizzes
      final completedQuizIds = [
        if (allQuizzes.isNotEmpty) allQuizzes[0].id,
        if (allQuizzes.length > 2) allQuizzes[2].id,
      ];

      setState(() {
        _completedQuizzes =
            allQuizzes
                .where((quiz) => completedQuizIds.contains(quiz.id))
                .toList();

        _availableQuizzes =
            allQuizzes
                .where((quiz) => !completedQuizIds.contains(quiz.id))
                .toList();

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
          'Quizzes',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorWidget()
              : _buildQuizContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchQuizzes,
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
          Text('Error loading quizzes', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchQuizzes, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    if (_availableQuizzes.isEmpty && _completedQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.quiz_outlined,
              size: 64,
              color: AppColors.lightTextColor,
            ),
            const SizedBox(height: 16),
            Text('No Quizzes Available', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'There are no quizzes available at the moment.\nCheck back later or enroll in more courses.',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Quizzes
          if (_availableQuizzes.isNotEmpty) ...[
            Text('Available Quizzes', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            ..._availableQuizzes.map((quiz) => _buildQuizCard(quiz, false)),
            const SizedBox(height: 24),
          ],

          // Completed Quizzes
          if (_completedQuizzes.isNotEmpty) ...[
            Text('Completed Quizzes', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            ..._completedQuizzes.map((quiz) => _buildQuizCard(quiz, true)),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz, bool isCompleted) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final course = courseProvider.getCourseById(quiz.courseId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToQuizDetail(quiz),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz Title and Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: AppTextStyles.heading3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.successColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: AppTextStyles.smallText.copyWith(
                              color: AppColors.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
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
              const SizedBox(height: 4),

              // Quiz Info
              Row(
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 16,
                    color: AppColors.lightTextColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${quiz.questions.length} questions',
                    style: AppTextStyles.bodyText,
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppColors.lightTextColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${quiz.timeLimit} minutes',
                    style: AppTextStyles.bodyText,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Passing Score
              Row(
                children: [
                  const Icon(
                    Icons.grade_outlined,
                    size: 16,
                    color: AppColors.lightTextColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Passing Score: ${quiz.passingScore}%',
                    style: AppTextStyles.bodyText,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quiz Description
              Text(
                quiz.description,
                style: AppTextStyles.bodyText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToQuizDetail(quiz),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCompleted
                            ? AppColors.lightTextColor
                            : AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }

  void _navigateToQuizDetail(QuizModel quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizDetailScreen(quizId: quiz.id),
      ),
    );
  }
}

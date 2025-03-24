import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/quiz_model.dart';

class QuizAttemptScreen extends StatefulWidget {
  final QuizModel quiz;

  const QuizAttemptScreen({super.key, required this.quiz});

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {};
  bool _isSubmitting = false;
  bool _isQuizCompleted = false;
  int? _score;

  // Timer variables
  late Timer _timer;
  late int _remainingSeconds;
  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    // Convert minutes to seconds
    _remainingSeconds = widget.quiz.timeLimit * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
          _submitQuiz();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isQuizCompleted,
      onPopInvoked: (didPop) async {
        if (!didPop && !_isQuizCompleted) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Quit Quiz?',
                style: AppTextStyles.heading2,
              ),
              content: Text(
                'Are you sure you want to quit? Your progress will be lost.',
                style: AppTextStyles.bodyText,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.lightTextColor,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorColor,
                  ),
                  child: Text(
                    'Quit',
                    style: AppTextStyles.bodyText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (shouldPop ?? false) {
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Text(
            widget.quiz.title,
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color:
                    _remainingSeconds < 60
                        ? AppColors.errorColor
                        : _remainingSeconds < 300
                        ? Colors.orange
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color:
                        _remainingSeconds < 60
                            ? Colors.white
                            : _remainingSeconds < 300
                            ? Colors.white
                            : AppColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formattedTime,
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          _remainingSeconds < 60
                              ? Colors.white
                              : _remainingSeconds < 300
                              ? Colors.white
                              : AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: _isQuizCompleted ? _buildResultsScreen() : _buildQuizContent(),
      ),
    );
  }

  Widget _buildQuizContent() {
    final questions = widget.quiz.questions;
    final currentQuestion = questions[_currentQuestionIndex];

    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / questions.length,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),

        // Question counter
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_selectedAnswers.length} answered',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.lightTextColor,
                ),
              ),
            ],
          ),
        ),

        // Question and answers
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                Text(
                  currentQuestion.questionText,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 24),

                // Answer options
                ...List.generate(
                  currentQuestion.options.length,
                  (index) => _buildAnswerOption(
                    index,
                    currentQuestion.options[index],
                    _selectedAnswers[_currentQuestionIndex] == index,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              if (_currentQuestionIndex > 0)
                ElevatedButton.icon(
                  onPressed: _goToPreviousQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: AppColors.textColor,
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                )
              else
                const SizedBox(width: 100),

              // Question navigation indicator
              Text(
                '${_currentQuestionIndex + 1}/${questions.length}',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Next/Submit button
              ElevatedButton.icon(
                onPressed:
                    _isSubmitting
                        ? null
                        : _currentQuestionIndex < questions.length - 1
                        ? _goToNextQuestion
                        : () => _showSubmitDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(
                  _currentQuestionIndex < questions.length - 1
                      ? Icons.arrow_forward
                      : Icons.check,
                ),
                label: Text(
                  _currentQuestionIndex < questions.length - 1
                      ? 'Next'
                      : 'Submit',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerOption(int index, String option, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.1)
                    : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.primaryColor
                            : Colors.grey.shade400,
                    width: 1,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final isPassed = _score! >= widget.quiz.passingScore;
    final correctAnswers =
        (widget.quiz.questions.length * _score! / 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Result icon
          Icon(
            isPassed ? Icons.check_circle : Icons.cancel,
            size: 80,
            color: isPassed ? AppColors.successColor : AppColors.errorColor,
          ),
          const SizedBox(height: 24),

          // Result title
          Text(
            isPassed ? 'Congratulations!' : 'Better luck next time!',
            style: AppTextStyles.heading1.copyWith(
              color: isPassed ? AppColors.successColor : AppColors.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isPassed
                      ? AppColors.successColor.withValues(alpha: 0.1)
                      : AppColors.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Column(
              children: [
                Text('Your Score', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                Text(
                  '$_score%',
                  style: AppTextStyles.heading1.copyWith(
                    color:
                        isPassed
                            ? AppColors.successColor
                            : AppColors.errorColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPassed
                      ? 'You have passed the quiz!'
                      : 'You did not pass the quiz.',
                  style: AppTextStyles.bodyText,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow(
                    label: 'Total Questions',
                    value: '${widget.quiz.questions.length}',
                  ),
                  const Divider(),
                  _buildStatRow(
                    label: 'Correct Answers',
                    value: '$correctAnswers',
                    valueColor: AppColors.successColor,
                  ),
                  const Divider(),
                  _buildStatRow(
                    label: 'Incorrect Answers',
                    value: '${widget.quiz.questions.length - correctAnswers}',
                    valueColor: AppColors.errorColor,
                  ),
                  const Divider(),
                  _buildStatRow(
                    label: 'Passing Score',
                    value: '${widget.quiz.passingScore}%',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.primaryColor),
                  ),
                  child: Text(
                    'Back to Quiz List',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      !isPassed
                          ? () {
                              // Reset quiz state and restart
                              setState(() {
                                _currentQuestionIndex = 0;
                                _selectedAnswers = {};
                                _isQuizCompleted = false;
                                _score = null;
                                _initializeTimer();
                              });
                            }
                          : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: Text('Retry Quiz', style: AppTextStyles.buttonText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyText),
          Text(
            value,
            style: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _showSubmitDialog() {
    final unansweredCount =
        widget.quiz.questions.length - _selectedAnswers.length;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Submit Quiz?', style: AppTextStyles.heading2),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to submit your answers?',
                  style: AppTextStyles.bodyText,
                ),
                const SizedBox(height: 16),
                Text(
                  'Questions answered: ${_selectedAnswers.length}/${widget.quiz.questions.length}',
                  style: AppTextStyles.bodyText,
                ),
                if (unansweredCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'You have $unansweredCount unanswered questions.',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Time remaining: $_formattedTime',
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
                  Navigator.of(context).pop();
                  _submitQuiz();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: Text(
                  'Submit',
                  style: AppTextStyles.bodyText.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _submitQuiz() {
    setState(() {
      _isSubmitting = true;
    });

    // Cancel the timer
    _timer.cancel();

    // Calculate score
    int correctAnswers = 0;

    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final selectedAnswer = _selectedAnswers[i];
      if (selectedAnswer != null &&
          selectedAnswer == widget.quiz.questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }

    final score = (correctAnswers / widget.quiz.questions.length * 100).round();

    // In a real app, you would save the quiz results to the backend here

    // Show results after a brief delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSubmitting = false;
        _isQuizCompleted = true;
        _score = score;
      });
    });
  }
}

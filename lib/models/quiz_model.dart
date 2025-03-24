class QuizModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int timeInMinutes;
  final int passingScore;
  final DateTime createdAt;
  final int timeLimit;
  final int attemptsAllowed;

  QuizModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.questions,
    required this.timeInMinutes,
    required this.passingScore,
    required this.createdAt,
    this.timeLimit = 30, // Default 30 minutes
    this.attemptsAllowed = 3, // Default 3 attempts
  });

  factory QuizModel.fromMap(Map<String, dynamic> map, String docId) {
    return QuizModel(
      id: docId,
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      questions:
          (map['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(q))
              .toList() ??
          [],
      timeInMinutes: map['timeInMinutes'] ?? 0,
      passingScore: map['passingScore'] ?? 0,
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as dynamic).toDate()
              : DateTime.now(),
      timeLimit: map['timeLimit'] ?? 30,
      attemptsAllowed: map['attemptsAllowed'] ?? 3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeInMinutes': timeInMinutes,
      'passingScore': passingScore,
      'createdAt': createdAt,
      'timeLimit': timeLimit,
      'attemptsAllowed': attemptsAllowed,
    };
  }
}

class QuizQuestion {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;

  // Add getter for questionText to maintain compatibility
  String get questionText => text;

  QuizQuestion({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      text: map['text'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      explanation: map['explanation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }
}

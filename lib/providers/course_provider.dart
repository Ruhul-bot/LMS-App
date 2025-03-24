import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/lecture_model.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';
import '../services/course_service.dart';

class CourseProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();

  List<CourseModel> _allCourses = [];
  List<CourseModel> _classCourses = [];
  List<CourseModel> _enrolledCourses = [];
  CourseModel? _selectedCourse;
  List<LectureModel> _courseLectures = [];
  List<QuizModel> _courseQuizzes = [];
  List<QuizModel> _allQuizzes = [];
  List<LectureModel> _liveLectures = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _currentClassLevel = '';

  // Getters
  List<CourseModel> get allCourses => _allCourses;
  List<CourseModel> get classCourses => _classCourses;
  List<CourseModel> get enrolledCourses => _enrolledCourses;
  CourseModel? get selectedCourse => _selectedCourse;
  List<LectureModel> get courseLectures => _courseLectures;
  List<QuizModel> get courseQuizzes => _courseQuizzes;
  List<QuizModel> get allQuizzes => _allQuizzes;
  List<LectureModel> get liveLectures => _liveLectures;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentClassLevel => _currentClassLevel;

  // Update method for ProxyProvider
  void update(UserModel? userModel) {
    if (userModel != null) {
      fetchEnrolledCourses(userModel.uid);
    }
  }

  // Fetch all courses
  Future<void> fetchAllCourses() async {
    _setLoading(true);
    _clearError();

    try {
      _allCourses = await _courseService.getAllCourses();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch courses by class level
  Future<void> fetchCoursesByClassLevel(String classLevel) async {
    _setLoading(true);
    _clearError();
    _currentClassLevel = classLevel;

    try {
      _classCourses = await _courseService.getCoursesByClassLevel(classLevel);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch user's enrolled courses
  Future<void> fetchEnrolledCourses(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _enrolledCourses = await _courseService.getUserEnrolledCourses(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get course by ID
  CourseModel? getCourseById(String courseId) {
    return _allCourses.firstWhere(
      (course) => course.id == courseId,
      orElse:
          () => _enrolledCourses.firstWhere(
            (course) => course.id == courseId,
            orElse:
                () => _classCourses.firstWhere(
                  (course) => course.id == courseId,
                  orElse: () => throw Exception('Course not found'),
                ),
          ),
    );
  }

  // Set selected course and fetch its details
  Future<void> selectCourse(String courseId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedCourse = await _courseService.getCourseById(courseId);

      if (_selectedCourse != null) {
        await Future.wait([
          fetchCourseLectures(courseId),
          fetchCourseQuizzes(courseId),
        ]);
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch lectures for a course
  Future<void> fetchCourseLectures(String courseId) async {
    try {
      _courseLectures = await _courseService.getLecturesForCourse(courseId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Fetch quizzes for a course
  Future<void> fetchCourseQuizzes(String courseId) async {
    try {
      _courseQuizzes = await _courseService.getQuizzesForCourse(courseId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Fetch all quizzes
  Future<void> fetchAllQuizzes() async {
    _setLoading(true);
    _clearError();

    try {
      _allQuizzes = await _courseService.getAllQuizzes();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch live lectures
  Future<void> fetchLiveLectures() async {
    _setLoading(true);
    _clearError();

    try {
      _liveLectures = await _courseService.getLiveLectures();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Enroll user in a course
  Future<bool> enrollInCourse(String userId, String courseId) async {
    _setLoading(true);
    _clearError();

    try {
      await _courseService.enrollUserInCourse(userId, courseId);
      await fetchEnrolledCourses(userId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear selected course
  void clearSelectedCourse() {
    _selectedCourse = null;
    _courseLectures = [];
    _courseQuizzes = [];
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/lecture_model.dart';
import '../models/quiz_model.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all courses
  Future<List<CourseModel>> getAllCourses() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('courses').get();

      return querySnapshot.docs.map((doc) {
        return CourseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get courses by class level
  Future<List<CourseModel>> getCoursesByClassLevel(String classLevel) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('courses')
              .where('classLevel', isEqualTo: classLevel)
              .get();

      return querySnapshot.docs.map((doc) {
        return CourseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get course by ID
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('courses').doc(courseId).get();

      if (doc.exists) {
        return CourseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get lectures for a course
  Future<List<LectureModel>> getLecturesForCourse(String courseId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('lectures')
              .where('courseId', isEqualTo: courseId)
              .orderBy('createdAt')
              .get();

      return querySnapshot.docs.map((doc) {
        return LectureModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get quizzes for a course
  Future<List<QuizModel>> getQuizzesForCourse(String courseId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('quizzes')
              .where('courseId', isEqualTo: courseId)
              .get();

      return querySnapshot.docs.map((doc) {
        return QuizModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get all quizzes
  Future<List<QuizModel>> getAllQuizzes() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('quizzes')
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        return QuizModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get live lectures
  Future<List<LectureModel>> getLiveLectures() async {
    try {
      // Get current time
      DateTime now = DateTime.now();

      // Get lectures that are scheduled for today or in the future
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('lectures')
              .where('isLive', isEqualTo: true)
              .where('scheduledTime', isGreaterThanOrEqualTo: now)
              .orderBy('scheduledTime')
              .get();

      return querySnapshot.docs.map((doc) {
        return LectureModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Enroll user in a course
  Future<void> enrollUserInCourse(String userId, String courseId) async {
    try {
      // Add course to user's enrolled courses
      await _firestore.collection('users').doc(userId).update({
        'enrolledCourses': FieldValue.arrayUnion([courseId]),
      });

      // Create enrollment record
      await _firestore.collection('enrollments').add({
        'userId': userId,
        'courseId': courseId,
        'enrollmentDate': FieldValue.serverTimestamp(),
        'paymentStatus': 'completed',
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get user's enrolled courses
  Future<List<CourseModel>> getUserEnrolledCourses(String userId) async {
    try {
      // Get user document to retrieve enrolled courses
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return [];
      }

      List<String> enrolledCourseIds = List<String>.from(
        (userDoc.data() as Map<String, dynamic>)['enrolledCourses'] ?? [],
      );

      if (enrolledCourseIds.isEmpty) {
        return [];
      }

      // Get all enrolled courses
      List<CourseModel> enrolledCourses = [];

      for (String courseId in enrolledCourseIds) {
        CourseModel? course = await getCourseById(courseId);
        if (course != null) {
          enrolledCourses.add(course);
        }
      }

      return enrolledCourses;
    } catch (e) {
      rethrow;
    }
  }
}

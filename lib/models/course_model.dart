class CourseModel {
  final String id;
  final String title;
  final String description;
  final String classLevel; // "9", "10", "11", "12", "misc"
  final double price;
  final String instructor;
  final String? thumbnailUrl;
  final List<String> topics;
  final int totalLectures;
  final int totalQuizzes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.classLevel,
    required this.price,
    required this.instructor,
    this.thumbnailUrl,
    required this.topics,
    required this.totalLectures,
    required this.totalQuizzes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map, String docId) {
    return CourseModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      classLevel: map['classLevel'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      instructor: map['instructor'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      topics: List<String>.from(map['topics'] ?? []),
      totalLectures: map['totalLectures'] ?? 0,
      totalQuizzes: map['totalQuizzes'] ?? 0,
      createdAt: map['createdAt'] != null 
        ? (map['createdAt'] as dynamic).toDate() 
        : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
        ? (map['updatedAt'] as dynamic).toDate() 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'classLevel': classLevel,
      'price': price,
      'instructor': instructor,
      'thumbnailUrl': thumbnailUrl,
      'topics': topics,
      'totalLectures': totalLectures,
      'totalQuizzes': totalQuizzes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

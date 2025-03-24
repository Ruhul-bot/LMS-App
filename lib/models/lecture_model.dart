class LectureModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final String videoUrl;
  final int durationInMinutes;
  final bool isLive;
  final DateTime? scheduledTime;
  final DateTime createdAt;

  // Computed property for endTime
  DateTime? get endTime => scheduledTime?.add(Duration(minutes: durationInMinutes));

  LectureModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.durationInMinutes,
    required this.isLive,
    this.scheduledTime,
    required this.createdAt,
  });

  factory LectureModel.fromMap(Map<String, dynamic> map, String docId) {
    return LectureModel(
      id: docId,
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      durationInMinutes: map['durationInMinutes'] ?? 0,
      isLive: map['isLive'] ?? false,
      scheduledTime: map['scheduledTime'] != null 
        ? (map['scheduledTime'] as dynamic).toDate() 
        : null,
      createdAt: map['createdAt'] != null 
        ? (map['createdAt'] as dynamic).toDate() 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'durationInMinutes': durationInMinutes,
      'isLive': isLive,
      'scheduledTime': scheduledTime,
      'createdAt': createdAt,
    };
  }
}

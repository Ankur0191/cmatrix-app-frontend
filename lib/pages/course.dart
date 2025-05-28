
class Course {
  final String course_id;
  final String course_name;
  final String course_details;
  final int duration;
  bool is_favorite;

  Course({
    required this.course_id, required this.course_name, required this.course_details, required this.duration,this.is_favorite = false
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      course_id: json['course_id'] ?? '',
      course_name: json['course_name'] ?? '',
      course_details: json['course_details'] ?? '',
      duration: json['duration'] ?? 0,
      is_favorite: json['is_favorite'] ?? false
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'course_id': course_id,
      'course_name': course_name,
      'course_details': course_details,
      'duration': duration,
      'is_favorite': is_favorite,
    };
  }
}

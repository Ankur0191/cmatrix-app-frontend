class Lecture {
  final String course_id;
  final String title;
  final String youtube_url;
  final String thumbnail_url;
  Lecture({
    required this.course_id, required this.title, required this.youtube_url, required this.thumbnail_url
  });
  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      course_id: json['course_id'],
      title: json['title'],
      youtube_url: json['youtube_url'],
      thumbnail_url: json['thumbnail_url'],
    );
  }
}
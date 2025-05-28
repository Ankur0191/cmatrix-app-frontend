import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../auth_helper.dart';
import '../course.dart';

Future<List<Course>> getFavCourses(BuildContext context, AuthService authService) async {
  String url = 'https://d10c-103-103-56-94.ngrok-free.app/fav_courses';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('access_token');
  if (token == null) {
    throw Exception('No token found');
  }
  final response = await http.get(Uri.parse(url), headers: {"Authorization": "Bearer $token"});
  var responseData = json.decode(response.body);
  authService.handleApiResponse(response, context);
  List<Course> favcourseList = [];
  for (var singleCourse in responseData) {
    Course course = Course(
        course_id: singleCourse["course_id"],
        course_name: singleCourse["course_name"],
        course_details: singleCourse["course_details"],
        duration: singleCourse["duration"],
      is_favorite: true
    );

    favcourseList.add(course);
  }
  return favcourseList;
}

List _imagePathList = [
  'lib/images/programming.png',
  'lib/images/computer.png',
  'lib/images/os.png',
  "lib/images/data.png",
  'lib/images/language.png',
  'lib/images/dbms.png',
  'lib/images/architecture.png',
  'lib/images/software.png',
  'lib/images/ai.png',
  'lib/images/graphics.png',
];

// Function to get a random image path
String getRandomImagePath() {
  Random random = Random();
  int randomIndex = random.nextInt(_imagePathList.length);
  return _imagePathList[randomIndex];
}

class UserCourses extends StatefulWidget {
  const UserCourses({super.key});

  @override
  State<UserCourses> createState() => _UserCoursesState();
}

class _UserCoursesState extends State<UserCourses> {
  List<Course> _favoriteCourses = [];
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, String> courseImages = {};
  final AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    _loadFavoriteCourses();
  }
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFavoriteCourses() async {
    try {
      List<Course> courses = await getFavCourses(context,_authService);
      setState(() {
        _favoriteCourses = courses;
        _isLoading = false;
        for (var course in courses) {
          if (!courseImages.containsKey(course.course_id)) {
            courseImages[course.course_id] = getRandomImagePath();
          }
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError || _favoriteCourses.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/images/Shrug-bro.png'),
            const SizedBox(height: 20),
            Text(
              'No favorite courses yet.',
              style: GoogleFonts.saira(fontSize: 20),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _favoriteCourses.length,
        itemBuilder: (ctx, index) {
          String courseImagePath = courseImages[_favoriteCourses[index].course_id] ?? getRandomImagePath();
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white70,
            child: ListTile(
              leading: Image.asset(
                courseImagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                "${_favoriteCourses[index].course_id}: ${_favoriteCourses[index].course_name}",
              ),
              subtitle: Text(
                "${_favoriteCourses[index].course_details}\nDuration: ${_favoriteCourses[index].duration} months",
              ),
            ),
          );
        },
      ),
    );
  }
}

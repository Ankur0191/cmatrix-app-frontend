import 'package:flutter/material.dart';
import 'course.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_helper.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<List<Course>> getCourses(int page, BuildContext context, AuthService authService) async {
  String url = 'https://d10c-103-103-56-94.ngrok-free.app/home_page?page=$page';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('access_token');
  if (token == null) {
    throw Exception('No token found');
  }
  final response = await http.get(Uri.parse(url), headers: {"Authorization": "Bearer $token"});
  var responseData = json.decode(response.body);
  authService.handleApiResponse(response, context);
  List<Course> courseList = [];
  if (responseData.containsKey('courses')) {
    var courseData = responseData['courses'];
    // Iterate through each course data and create Course objects
    for (var singleCourse in courseData) {
      Course course = Course(
        course_id: singleCourse["course_id"],
        course_name: singleCourse["course_name"],
        course_details: singleCourse["course_details"],
        duration: singleCourse["duration"],
        is_favorite: singleCourse["is_favorite"],
      );
      courseList.add(course);
    }
  }
  return courseList;
}

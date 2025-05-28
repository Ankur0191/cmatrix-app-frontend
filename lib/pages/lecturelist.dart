import 'package:flutter/material.dart';
import 'auth_helper.dart';
import 'lecture.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Lecture>> getLectures(BuildContext context, AuthService authService) async {
  String url = 'https://d10c-103-103-56-94.ngrok-free.app/lectures';
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('access_token');
  if (token == null) {
    throw Exception('No token found');
  }
  final response = await http.get(Uri.parse(url), headers: {'Authorization' : 'Bearer $token'});
  var responseData = json.decode(response.body);
  authService.handleApiResponse(response, context);
  //Creating a list to store input data;
  List<Lecture> lectureList = [];
  for (var singleLecture in responseData) {
    Lecture course = Lecture(
        course_id: singleLecture["course_id"] ?? '',
        title: singleLecture["title"] ?? '',
        youtube_url: singleLecture["youtube_url"] ?? '',
        thumbnail_url: singleLecture["thumbnail_url"] ?? '');
    //Adding lecture to the list.
    lectureList.add(course);
  }
  return lectureList;
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Login_or_Register.dart';

class AuthService {
  void handleApiResponse(http.Response response, BuildContext context) {
    if (response.statusCode == 401) {
      autoLogoutUser(context);
    }
  }
  
  void autoLogoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
    );
  }
}
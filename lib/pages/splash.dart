import 'package:flutter/material.dart';
import 'Login_or_Register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _showSplashScreen();
    checkAuth();
  }

  Future<void> _showSplashScreen() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {});
  }

  Future<void> checkAuth() async {
    String url = 'https://d10c-103-103-56-94.ngrok-free.app/home_page';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
      );
      throw Exception('No token found');

    }
    final response = await http.get(Uri.parse(url), headers: {"Authorization": "Bearer $token"});
    if (response.statusCode == 401) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
      );
    }
    else {
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(token: token)),
    );
    }
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
       child: Image.asset('lib/images/Learning app_transparent.png',scale: 2),
      ),
    );
  }
}

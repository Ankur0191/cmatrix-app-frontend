import 'package:flutter/material.dart';
import 'Login_or_Register.dart';
import 'profile_info.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'UserPages/UserHome.dart';
import 'UserPages/courses_page.dart';
import 'UserPages/profile_page.dart';
import 'UserPages/live_page.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_helper.dart';

class HomePage extends StatefulWidget {
  final String? token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String userName = 'User';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void SignUserOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token == null) {
        throw Exception('No token found');
      }
      Response response = await post(
        Uri.parse('https://d10c-103-103-56-94.ngrok-free.app/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _loadUserName() async {
    await getProfile(context,_authService);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
    });
  }

  final List<Widget> _pages = [
    const UserHome(),
    UserCourses(),
    const UserLive(),
    UserProfile(),
  ];


  @override
  Widget build(BuildContext context) {
    final List<String> appBarTitles = [
      'Hello, $userName',
      'My Courses',
      'Live Courses',
      'Profile',
    ];
            return Scaffold(
              backgroundColor: Colors.grey[300],
              appBar: AppBar(
                backgroundColor: Colors.red[800],
                centerTitle: false,
                title: Text(
                  appBarTitles[_selectedIndex], style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                ),
                actions: [
                  IconButton(onPressed: SignUserOut,
                      icon: const Icon(
                          Icons.logout, color: Colors.white, size: 30)
                  )
                ],
              ),
              body: _pages[_selectedIndex],
              bottomNavigationBar:
              Container(
                color: Colors.red[800],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 20),
                  child: GNav(
                      backgroundColor: Colors.red.shade800,
                      color: Colors.white,
                      activeColor: Colors.white,
                      tabBackgroundColor: Colors.redAccent,
                      gap: 8,
                      selectedIndex: _selectedIndex,
                      //Need to change to different pages
                      onTabChange: navigateBottomBar,
                      tabs: const [
                        GButton(
                          icon: Icons.home,
                          iconSize: 25,
                          text: 'Home',
                        ),
                        GButton(
                          icon: Icons.school,
                          iconSize: 25,
                          text: 'Courses',
                        ),
                        GButton(
                          icon: Icons.live_tv_rounded,
                          iconSize: 25,
                          text: 'Live',
                        ),
                        GButton(
                          icon: Icons.account_circle_sharp,
                          iconSize: 25,
                          text: 'Profile',
                        )
                      ]
                  ),
                ),
              ),
            );
  }
}



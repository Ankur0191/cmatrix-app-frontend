import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../pages/auth_helper.dart';
import '../../pages/courselist.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../course.dart';
import 'package:http/http.dart' as http;

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

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  late Future<List<Course>> favoriteCourses;
  TextEditingController searchController = TextEditingController();
  List<Course> allCourses = [];
  List<Course> filteredCourses = [];
  Map<String, String> courseImages = {};
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    loadCourses(currentPage);
    _scrollController.addListener(_scrollListener);
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> addFavCourse(Course selectedCourse) async {
    String url = 'https://d10c-103-103-56-94.ngrok-free.app/add_fav';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fav_id': selectedCourse.course_id}),
    );
    _authService.handleApiResponse(response, context);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      print('Course added to favorites successfully');
      setState(() {
        selectedCourse.is_favorite = true;
      });
      print(selectedCourse.is_favorite);
    } else {
      print('Failed to fav course: ${response.statusCode}');
    }
  }

  Future<void> removeFavCourse(Course selectedCourse) async {
    String url = 'https://d10c-103-103-56-94.ngrok-free.app/remove_fav';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fav_id': selectedCourse.course_id}),
    );
    _authService.handleApiResponse(response, context);

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      print('Course removed from favorites successfully');

      setState(() {
        selectedCourse.is_favorite = false; // Update the favorite status
      });
    } else {
      // Handle error
      print('Failed to remove fav course: ${response.statusCode}');
    }
  }


  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Reached the bottom
      if (!isLoading && hasMore) {
        currentPage++;
        loadCourses(currentPage);
      }
    }
  }

  Future<void> loadCourses(int page) async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Course> newCourses = await getCourses(page, context, _authService);
      setState(() {
        allCourses.addAll(newCourses);
        filteredCourses = allCourses;
        for (var course in newCourses) {
          if (!courseImages.containsKey(course.course_id)) {
            courseImages[course.course_id] = getRandomImagePath();
          }
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error loading courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Course>> searchResults(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    final response = await http.get(Uri.parse(
        'https://d10c-103-103-56-94.ngrok-free.app/search?query=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },);
    _authService.handleApiResponse(response, context);
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((resultJson) {
        try {
          return Course.fromJson(resultJson);
        } catch (e) {
          print('Error parsing course: $e');
          print('Course data: $resultJson');
          rethrow;
        }
      }).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }

  void searchFunction(String query) async {
    if (query.isNotEmpty) {
      List<Course> searchResultsList = await searchResults(query);
      setState(() {
        filteredCourses = searchResultsList;
      });
    } else {
      setState(() {
        filteredCourses = allCourses;
      });
    }
  }

  void onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      searchFunction(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
                backgroundColor: Colors.grey[300],
                body: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset('lib/images/videotut.png', scale: 10),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Let's upgrade your skill!",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.workSans(textStyle: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[600],
                               ),),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search',
                                      border: InputBorder.none
                                    ),
                                   onChanged: onSearchChanged,
                                  ),
                                ),
                                IconButton(onPressed: () {
                                  searchFunction(searchController.text);
                                } ,icon: const Icon(Icons.search), color: Colors.grey,)
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                  Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredCourses.length + (isLoading ? 1 : 0),
                        itemBuilder: (ctx,index) {
                          if (index < filteredCourses.length) {
                            Color tileColor = index % 2 == 0
                                ? Colors.grey[200]!
                                : Colors.white;
                            String courseImagePath = courseImages[filteredCourses[index]
                                .course_id] ??
                                getRandomImagePath();
                            Course course = filteredCourses[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0),
                              color: tileColor,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      isThreeLine: true,
                                      title: Text("${course.course_id}: ${course
                                          .course_name}",
                                        textAlign: TextAlign.left,),
                                      subtitle: Text(
                                        "${course
                                            .course_details}\nDuration: ${course
                                            .duration} months",
                                        textAlign: TextAlign.left,
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                          bottom: 20.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      courseImagePath,
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (course.is_favorite) {
                                        removeFavCourse(course);
                                      } else {
                                        addFavCourse(course);
                                      }
                                    },
                                    icon: Icon(
                                      Icons.favorite,
                                      color: course.is_favorite
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    iconSize: 30,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                  ),
                  ]
                      ),
    );

  }
}

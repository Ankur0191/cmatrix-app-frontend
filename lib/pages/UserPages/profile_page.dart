import 'dart:io';

import 'package:flutter/material.dart';
import '../../pages/auth_helper.dart';
import '../../pages/change_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile_info.dart';

class Profile {
  final String profile_about;
  final List<dynamic> courses;
  final String email;
  final String profile_picture;
  final String name;

  Profile({
    required this.profile_about, required this.courses,required this.email,required this.profile_picture, required this.name
  });
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      profile_about: json['about'],
      courses: json['courses'],
      email: json['email'],
      profile_picture: json['profile_picture'],
      name: json['name'],
    );
  }
  String getName() {
    return name;
  }
}

void showImagePicker(BuildContext context) {
  showModalBottomSheet(backgroundColor: Colors.grey[400],context: context, builder: (builder) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 4.5,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {},
              child: const SizedBox(
                child: Column(
                  children: [Icon(Icons.image, size: 100,), Text('Gallery')],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {},
              child: const SizedBox(
                child: Column(
                  children: [Text('Choose an avatar', style: TextStyle(),)],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {},
              child: const SizedBox(
                child: Column(
                  children: [Icon(Icons.camera_alt, size: 100,), Text('Camera')],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}



class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<Profile> user_profile;
  String? profilePicturePath;
  final AuthService _authService = AuthService();



  @override
  void initState() {
    super.initState();
    user_profile = getProfile(context, _authService);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
     profilePicturePath = prefs.getString('profile_picture') ;
    });
  }
  Future<void> _updateProfile() async {
    setState(() {
      user_profile = getProfile(context, _authService);
    });
    await _loadProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SingleChildScrollView(
              child : FutureBuilder<Profile>(
                future: user_profile,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    Profile profile = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            const SizedBox(width: 50,),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              height: 240,
                              width: 210,
                              child: ClipOval(
                                child: profilePicturePath != null
                                    ? Image.file(File(profilePicturePath!),fit: BoxFit.cover,width: 0,height: 5,)
                                    : Image.asset(profile.profile_picture, scale: 1,fit:BoxFit.cover),
                              ),
                       ),
                            Positioned(
                              height: 90,
                              width: 90,
                              bottom: 0,
                              right: 3,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                    icon: Image.asset('lib/images/edit.png'),
                                    iconSize: 3,
                                    onPressed: () async {
                                      bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeAvatar()));
                                      if (result == true) {
                                       await _updateProfile();
                                      }
                                    }
                                ),
                              ),
                            ),
                          ]
                      ),
                        Text(profile.name,style: const TextStyle(fontFamily: 'Garamond',fontWeight: FontWeight.bold),),
                        Text(profile.email,style: const TextStyle(fontFamily: 'Garamond',fontWeight: FontWeight.w400,)),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Align(alignment: Alignment.centerLeft,
                            child: Text('About', style: TextStyle(fontFamily: 'Garamond',fontWeight: FontWeight.bold,fontSize: 16, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                               border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey[200],
                            ),
                          child: Text(profile.profile_about),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Align( alignment: Alignment.centerLeft,
                              child: Text('Courses Completed',style: TextStyle(fontFamily: 'Garamond',fontWeight: FontWeight.bold,fontSize: 16,color: Colors.grey[600]))),
                        ),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            shrinkWrap: true,
                              itemCount: profile.courses.length,
                              itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(profile.courses[index].toString()),
                              );
                              }
                            ),
                        ),
                        const SizedBox(height: 10,),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No profile data available'));
                  }
                },

              ),
          ),
    );
  }
}

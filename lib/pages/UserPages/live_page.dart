import 'package:flutter/material.dart';
import '../../pages/lecture.dart';

import '../../pages/lecturelist.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../auth_helper.dart';

List<String> thumbnailID = [
  'HtSuA80QTyo',
  'NX_0rF9Keaw',
  '2aM5nTmvlK4',
  'lX9ZOrnO81Y',
  'QoQpUf7iZGo',
  '1zDgkdWzPMM',
  'YCxjPw2YHvk',
  '6O6ZhN5Rx7M',
  'z2FBOhFVcZ0',
  'nAE1HvdZOo8',
  'koo8pWM4T6o',
  'iUCN5xUut8I',
  'y5fU4q5hTjg',
  'GCc6JHewRYw',
  'ZSjflwLSbaE',
  'aTy8cH79Lw',
  'p0VUfSGCHrM',
  'H7MZySfxtSc',
  'UVplA0E3Z4c',
  'ov1sDkfln-0'
];

class UserLive extends StatefulWidget {
  const UserLive({super.key});

  @override
  State<UserLive> createState() => _UserLiveState();
}

class _UserLiveState extends State<UserLive> {
  final AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Expanded(
        child: Column(
            children: [
              const SizedBox(height: 20),
          Text(
          'Wonderful live courses, interact with teachers',
          textAlign: TextAlign.left,
          style:GoogleFonts.workSans(textStyle:TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
             Expanded(
               child: FutureBuilder<List<Lecture>>(
                      future: getLectures(context, _authService),
                      builder: (BuildContext ctx, AsyncSnapshot<List<Lecture>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if ( !snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No courses available.'));
                        } else {
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (ctx, index) {
                                Color tileColor = index % 2 == 0 ? Colors.grey[200]! : Colors.white;
                                String videoId = thumbnailID[index % thumbnailID.length];
                                Lecture lecture = snapshot.data![index];
                                String courseId = lecture.course_id;
                                String title = lecture.title;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  color: tileColor,
                                  child: Column(
                                    children: [
                                      YoutubePlayer(
                                        controller: YoutubePlayerController(
                                          initialVideoId: videoId,
                                          flags: const YoutubePlayerFlags(
                                            autoPlay: false,
                                            mute: false,
                                          ),
                                        ),
                                        showVideoProgressIndicator: true,
                                        progressIndicatorColor: Colors.blueAccent,
                                      ),
                                      ListTile(
                                        title: Text("$courseId: $title", textAlign: TextAlign.left,),
                                          contentPadding: const EdgeInsets.only(bottom: 20.0),
                                        ),
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                      ),
                                    ],
                                  ),
                                );
                              }
                          );
                        }
                      }
                  ),
             ),
            ],
          ),
      ),
    );
  }
}

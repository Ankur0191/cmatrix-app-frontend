import 'package:flutter/material.dart';
import 'pages/splash.dart';  // Corrected import path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),  // Make sure 'Splash' is the correct widget name
    );
  }
}

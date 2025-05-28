import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'create_pswd_google.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

const List<String> scopes = <String>[
  'profile',
  'email',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

class SignInDemo extends StatefulWidget {
  final dynamic onTap;
  const SignInDemo({super.key, required this.onTap});

  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      setState(() {
        _currentUser = account;
      });
      if (account != null) {
        await loginWithGoogle(account);
      }
    });
  }

  Future<void> getToken(String email) async {
    String url = 'https://d10c-103-103-56-94.ngrok-free.app/get_access_token?email=$email';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String token = responseData['access_token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);

        print('Token received and stored successfully.');
      } else {
        print('Failed to receive token: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching token: $error');
    }
  }


  Future<void> loginWithGoogle(GoogleSignInAccount account) async {
    final GoogleSignInAuthentication auth = await account.authentication;
    print(auth.idToken);
    final response = await http.post(
      Uri.parse('https://d10c-103-103-56-94.ngrok-free.app/google_auth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'access_token': auth.idToken,
      }),
    );

    if (response.statusCode == 200) {
      print("Logged in Successfully");
      final responseBody = jsonDecode(response.body);
      final token = responseBody['access_token'];
      const keyToken = 'access_token';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyToken, token);
      print(keyToken);
      await getToken(account.email);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreatePassword(token: token)));
      print('Token sent to server successfully.');
    } else {
      setState(() {
        print('Failed to send token to server.');
      });
    }
  }

  Future<void> _handleSignIn() async {
    await _googleSignIn.signOut();
    await _googleSignIn.disconnect();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    _googleSignIn.disconnect();
    setState(() {
      _currentUser = null;
      _contactText = '';
    });
  }

    Widget _buildBody() {
      final GoogleSignInAccount? user = _currentUser;
      if (user != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              height: 300,
              width: 300,
              child: Image.asset('/Users/angie/StudioProjects/flutter_app/lib/images/google_login.png'),
            ),
            ListTile(
              leading: GoogleUserCircleAvatar(identity: user),
              title: Text(user.displayName ?? ''),
              subtitle: Text(user.email),
            ),
            const Text('Signed in successfully.'),
            Text(_contactText),
            ElevatedButton(
              onPressed: _handleSignOut,
              child: const Text('SIGN OUT'),
            ),
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              height: 300,
              width: 300,
              child: Image.asset('/Users/angie/StudioProjects/flutter_app/lib/images/google_login.png'),
            ),
            const Text('You are not currently signed in.'),
            SignInButton(
              Buttons.google,
              onPressed: () {_handleSignIn();}
            ),
          ],
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Google Sign In'),

        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ),
      );
    }
}

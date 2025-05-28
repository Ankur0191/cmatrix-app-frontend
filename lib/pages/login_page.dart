import 'dart:convert';
import 'forgot_pswd.dart';
import 'googleSignIn.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'my_TextField.dart';
import 'my_button.dart';
import 'square_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading  = false;
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  void showErrorMessage(String error) {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[300],
        title: Center(
            child: Text(error),
          ),
        );
      },
    );
  }

  void askNotif() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[300],
        title: const Center(
          child: Text('"Edulink" would like to send you notifications'),
        ),
      );
    });
  }

  Future<void> signUserIn(String email, String password) async {
    showDialog(barrierDismissible: false, context: context, builder: (context) {
      return Center(
        child: CircularProgressIndicator(backgroundColor: Colors.red[400],color: Colors.black,),
        );
      },
    );
    try {
      Response response = await post(
        Uri.parse('https://d10c-103-103-56-94.ngrok-free.app/login'),
          headers : {"Content-Type": "application/json"},
        body : jsonEncode({
          "email": email,
          "password": password
        }),
      );
      Navigator.pop(context);
      if (response.statusCode == 200) {
        print("Logged in Successfully");
        final responseBody = jsonDecode(response.body);
        final token = responseBody['access_token'];
        const keyToken = 'access_token';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(keyToken, token);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(token: token)),
          );
        }

        } else {
        print('Login failed');
        showErrorMessage('Login failed. Please try again.');
      }
    } catch (e) {
          if (mounted) {
            Navigator.pop(context);
          }
      print(e.toString());
    }
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //logo
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    height: 200,
                    width: 300,
                    child: Image.asset('lib/images/Learning app_transparent.png'),
                  ),
                  const SizedBox(height: 30),
                  //Welcome Back
                  Text(
                    "Welcome back, you've been missed!",
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontFamily: 'Garamond'
                    ),
                  ),
                  //const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child:MyTextField(
                      controller: emailController,
                      hintText: 'Email address',
                      obscureText: false,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  // forgot password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ForgotPswd()));},
                          child: Text("Forgot Password?",
                               style: TextStyle(color: Colors.grey.shade700),),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  //sign in button
                  MyButton(
                    text: "Sign In",
                    onTap: () {
                      signUserIn(emailController.text.toString(), passwordController.text.toString());
                    },
                  ),
                  const SizedBox(height: 30),
                  //or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('Or continue with',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  //google and apple sign in
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: const SquareTile(imagePath: 'lib/images/google.png'),
                        onPressed: () {Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignInDemo(onTap: widget.onTap,)),
                        );},
                      ),
                      const SizedBox(width: 10),
                      const SquareTile(imagePath: 'lib/images/apple.png'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  //not a member? create account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center ,
                    children: [
                      Text("Not a member?", style: TextStyle(
                          color: Colors.grey[800]
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text("Register Now", style: TextStyle(
                            color: Colors.blue
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

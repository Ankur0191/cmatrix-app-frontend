import 'dart:convert';
import 'otp.dart';
import 'top_snackbar.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'my_TextField.dart';
import 'my_button.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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

  void signUserUp(String name,String email, String password, String cfmpswd) async {
    //show loading circle
    showDialog(barrierDismissible: false, context: context, builder: (context) {
      return Center(
        child: CircularProgressIndicator(backgroundColor: Colors.red[400],color: Colors.black,),
      );
    },
    );
    try {
      Response response = await post(
        Uri.parse('https://d10c-103-103-56-94.ngrok-free.app/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "confirm_password": cfmpswd
        }),
      );
      Navigator.pop(context);
      if (response.statusCode == 302 || response.statusCode == 200) {
        print("Created Successfully");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => otp(onTap: widget.onTap,))
        );
        } else if (password != cfmpswd) {
          print('Passwords do not match');
          showTopSnackBar(
            context,
            "Passwords don't match, please try again!",
          );
        } else if (response.statusCode == 400) {
          print('User already exists');
          showTopSnackBar(
            context,
            'This user already exists!',
          );
        }
      } catch (e) {
        Navigator.pop(context);
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
                //Welcome Back
                Text(
                  "Create an account with us!",
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontFamily: 'Garamond'
                  ),
                ),
                const SizedBox(height: 10),
                //Username
                MyTextField(
                  controller: nameController,
                  hintText: 'Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                Container(
                  child:MyTextField(
                    controller: emailController,
                    hintText: 'Email address',
                    obscureText: false,
                  ),
                ),

                //password
                const SizedBox(height: 10,),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10,),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                //sign in button
                MyButton(
                  text: "Sign Up",
                  onTap: () {
                       signUserUp(nameController.text,emailController.text, passwordController.text, confirmPasswordController.text);
                      }
                    ),
                    const SizedBox(height: 20),
                const SizedBox(height: 10),
                //not a member? create account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: [
                    Text("Already have an account?", style: TextStyle(
                        color: Colors.grey[800]
                    ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text("Login Now", style: TextStyle(
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

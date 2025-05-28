import 'dart:convert';

import 'package:flutter/material.dart';
import 'Login_or_Register.dart';
import 'top_snackbar.dart';
import 'package:http/http.dart';

import 'my_TextField.dart';
import 'my_button.dart';

class ForgotPswd extends StatefulWidget {
  const ForgotPswd({super.key});

  @override
  State<ForgotPswd> createState() => _ForgotPswdState();
}

class _ForgotPswdState extends State<ForgotPswd> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void resetPassword(String email, String password, String confirmPassword) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.red[400],
            color: Colors.black,
          ),
        );
      },
    );
    try {
      Response response = await post(
        Uri.parse('https://d10c-103-103-56-94.ngrok-free.app/forget_password'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "email": email,
          "password" : password,
          "confirm_password" : confirmPassword
        }),
      );
      Navigator.pop(context);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => LoginOrRegisterPage()));
        showTopSnackBar(
          context,
          'Password successfully reset!',
          backgroundColor: Colors.blue,
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          const SizedBox(height: 50,),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              height: 400,
              width: 400,
              child: Image.asset('lib/images/forgotpswd.png'),
            ),
          //Welcome Back
          Text(
            "Reset your password",
            style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontFamily: 'Garamond'
            ),
          ),
          const SizedBox(height: 10),
          Container(
            //margin: const EdgeInsets.only(top: 20),
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
              text: "Reset Password",
              onTap: () {
                resetPassword(emailController.text, passwordController.text, confirmPasswordController.text);
              }
          ),
            ],
          ),
    );
  }
}

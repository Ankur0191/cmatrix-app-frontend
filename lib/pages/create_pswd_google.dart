import 'dart:convert';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_TextField.dart';
import 'my_button.dart';

class CreatePassword extends StatefulWidget {
  final token;
  const CreatePassword({super.key, required this.token});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  final pswdController = TextEditingController();
  final cfmpswdController = TextEditingController();


  void createPassword(String password, String cfmpswd) async {
    //show loading circle
    showDialog(context: context, builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      Response response = await post(
        Uri.parse('https://d10c-103-103-56-94.ngrok-free.app/set_password'),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer ${widget.token}'},
        body: jsonEncode({
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
                builder: (context) => HomePage(token: widget.token))
        );
      } else if (password != cfmpswd) {
        print('Passwords do not match');
      } else if (response.statusCode == 400) {
        print('User already exists');
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
      body: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              height: 400,
              width: 400,
              child: Image.asset('/Users/angie/StudioProjects/flutter_app/lib/images/welcome.png'),
            ),
            //const SizedBox(height: 10,),
            Text(
              "Create a password with us!",
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontFamily: 'Garamond'
              ),
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: pswdController,
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: cfmpswdController,
              hintText: 'Confirm Password',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            MyButton(
                text: "Sign Up",
                onTap: () {
                  createPassword(pswdController.text, cfmpswdController.text);
                }
            ),
            const SizedBox(height: 20),
          ]
      ),
    );
  }
}
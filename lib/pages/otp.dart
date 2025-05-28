import 'dart:convert';
import 'package:flutter/material.dart';
import 'top_snackbar.dart';
import 'package:http/http.dart';
import 'login_page.dart';
import 'my_button.dart';

class otp extends StatefulWidget {
  final Function()? onTap;
  const otp({super.key, required this.onTap});

  @override
  State<otp> createState() => _otpState();
}

class _otpState extends State<otp> {
  final List<TextEditingController> _otpControllers = List.generate(5, (_) => TextEditingController());
  final otpController = TextEditingController();

  void joinOTPforVerify() {
    String otp = _otpControllers.map((controller) => controller.text).join();
    verifyOTP(otp);
  }
  void joinOTPforResend() {
    String otp = _otpControllers.map((controller) => controller.text).join();
    resendOTP(otp);
  }

  void verifyOTP(String otp) async {
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
        Uri.parse('https://d10c-103-103-56-94.ngrok-free.app/verify_otp'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "otp": otp,
        }),
      );
      Navigator.pop(context);
      if (response.statusCode == 200) {
        showTopSnackBar(
          context,
          'User registered successfully!',
          backgroundColor: Colors.blue
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage(onTap: widget.onTap)),
        );
      }
      else {
        showTopSnackBar(
            context,
            'Incorrect OTP',
        );
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void resendOTP(String otp) async {
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
        Uri.parse('https://d10c-103-103-56-94.ngrok-free.app/resend_otp'),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "otp": otp,
        }),
      );
      Navigator.pop(context);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => super.widget));
        showTopSnackBar(
          context,
          'OTP Resent!',
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
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              height: 400,
              width: 400,
              child: Image.asset('/Users/angie/StudioProjects/flutter_app/lib/images/otp.png'),
            ),
            Text(
              "We've sent an OTP code to your email!",
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontFamily: 'Garamond'
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return SizedBox(
                  width: 40,
                  child: TextFormField(
                    controller: _otpControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 4) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {joinOTPforResend();},
                    child: Text("Resend OTP",
                      style: TextStyle(color: Colors.grey.shade700),),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MyButton(
                text: "Verify OTP",
                onTap: () {
                  joinOTPforVerify();
                }
            ),
            const SizedBox(height: 20),
          ]
      ),
    );
  }
}

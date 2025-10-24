import 'dart:async';
import 'dart:convert';
import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/submit.dart';
import 'package:PN2025/user.dart';
import 'package:PN2025/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

TextEditingController email = TextEditingController();

class getPinUI extends StatefulWidget {
  String deviceID;
  final void Function(String) onPinSent;
  getPinUI({super.key, required this.onPinSent, required this.deviceID});

  @override
  State<getPinUI> createState() => _getPinUIState();
}

class _getPinUIState extends State<getPinUI> {
  Future<int> registerUser(String email) async {
    try {
      var response = await http
      .post(
        Uri.parse('${globals.url}auth/request-otp/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "deviceID": widget.deviceID,
          "eventId": "",
        }),
      )
      .timeout(Duration(seconds: 3));
      if(response.statusCode == 200)
      {
        globals.loginToken = response.headers["set-cookie"].toString().split("=")[1].split(";")[0];
      }
      return response.statusCode;
    }on TimeoutException catch (_) {
      return 408;
    } catch (e) {
      debugPrint(e.toString());
      debugPrint("Fail");
      return 500;
    }
  }
  void showDialogBox() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Email Confirmation",
              style: TextStyle(color: Colors.black),
            ),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  Container(
                    child: const Text(
                      "We have sent a 4-digit PIN to your email to your email to verify your account.Please cheack it and reenter it.",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result == null) {
      widget.onPinSent(email.text);
    }
  }
  void sendPin(String email,BuildContext context) async{
    if (email.isEmpty ) {
      email = "viswanathanmanickam5@gmail.com";
      // utils.snackBarMessage(context, 'Please enter email');
      // return;
    } 
    if (utils.isValidEmail(email)) {
      registerUser(email).then((statusCode) 
      {
        switch(statusCode)
        {
          case 200:
            User.instance.setEmail(email);
            showDialogBox();
            break;
          case 400:
            utils.snackBarMessage(context, 'Bad Request');
            break;
          case 408:
            utils.snackBarMessage(context, 'Server Timed Out!');
            break;
          case 500:
            utils.snackBarMessage(context, 'Internal Server Error');
            break;
        }
      });
    }else {
      utils.snackBarMessage(context, '$email is an invalid email');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            TextField(
              onSubmitted: (email) {
                sendPin(email, context);
              },
              decoration: const InputDecoration(labelText: "Email"),
              controller: email,
            ),
          ],
        ),
        submitButton(
          text: "Get OTP", 
          onSubmit: (){
            sendPin(email.text,context);
          }
        ),
      ],
    );
  }
}
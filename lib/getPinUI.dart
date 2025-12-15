import 'dart:async';
import 'package:NagaratharEvents/customDialogBox.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/submit.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:NagaratharEvents/utils.dart' as utils;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

final SharedPreferencesAsync prefs = SharedPreferencesAsync();

class getPinUI extends StatefulWidget {
  String deviceID;
  final void Function(String) onPinSent;
  Function() updateLoading;
  getPinUI({super.key, required this.onPinSent, required this.deviceID, required this.updateLoading});

  @override
  State<getPinUI> createState() => _getPinUIState();
}

class _getPinUIState extends State<getPinUI> {
  TextEditingController email = TextEditingController();
  Future<Response<dynamic>> registerUser(String email) async {
    widget.updateLoading();
    final response = await NetworkService().postRoute({
      "email": email,
      "deviceID": widget.deviceID,
      "eventId": "",
    }, 
    "auth/request-otp",
    skipIntercept: true);
    widget.updateLoading();
    return response;
  }
  void showDialogBox(String message) async {
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return customDialogBox(
            height: 300,
            title: "Email Sent", 
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  message,
                  style: TextStyle(fontSize: globals.paraFontSize),
                ),
              ],
            ),
          );
        },
      );
    if (result == null) {
      email.clear();
      widget.onPinSent(email.text);
    }
  }
  void sendPin(String email, BuildContext context) async{
    if (email.isEmpty ) {
      email = "viswanathanmanickam5@gmail.com";
      // utils.snackBarMessage('Please enter email');
      // return;
    } 
    if (utils.isValidEmail(email)) {
      registerUser(email).then((response) 
      {
        switch(response.statusCode){
          case 200:
            User.instance.setEmail(email);
            prefs.setBool('gotEmail', true);
            showDialogBox(response.data);
            break;
          case 404:
            utils.snackBarMessage('Email not registered!');
            break;
        }
      });
    }else {
      utils.snackBarMessage('$email is an invalid email');
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
              style: TextStyle(fontSize: globals.bodyFontSize),
              onSubmitted: (email) {
                sendPin(email, context);
              },
              keyboardType: TextInputType.emailAddress,
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
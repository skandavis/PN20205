import 'dart:async';
import 'package:PN2025/networkService.dart';
import 'package:PN2025/submit.dart';
import 'package:PN2025/user.dart';
import 'package:PN2025/utils.dart' as utils;
import 'package:flutter/material.dart';

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
    final response = await NetworkService().postRoute({
      "email": email,
      "deviceID": widget.deviceID,
      "eventId": "",
    }, 
    "auth/request-otp");
    return response.statusCode!;
  }
  void showDialogBox() async {
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
          constraints: BoxConstraints(
              maxHeight: 300,
              maxWidth: 400
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Colors.white
            ),
            child: Column(
              children: [
                Container(
                  height: 75,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                    color: Color.fromARGB(255,31,53,76)
                  ),
                  child: Center(
                    child: Text(
                      "Check Email", 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 28
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  height: 225,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("We have sent a 6-digit PIN to your email to your email to verify your account. Please check it and reenter it.",style: TextStyle(fontSize: 20),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    if (result == null) {
      widget.onPinSent(email.text);
    }
  }
  void sendPin(String email, BuildContext context) async{
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
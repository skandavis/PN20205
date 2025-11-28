import 'dart:async';
import 'package:NagaratharEvents/eventInfo.dart';
import 'package:NagaratharEvents/multiDigitInput.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/homePage.dart';
import 'package:NagaratharEvents/loginPage.dart';
import 'package:NagaratharEvents/submit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart' as utils;

final SharedPreferencesAsync prefs = SharedPreferencesAsync();
class enterPinUI extends StatefulWidget {
  String ApnsToken;
  Function() updateLoading;
  enterPinUI({super.key, required this.ApnsToken, required this.updateLoading});

  @override
  State<enterPinUI> createState() => _enterPinUIState();
}
class _enterPinUIState extends State<enterPinUI> {
  String pin = '';
  Future<int> authenticate(int pin) async {
    widget.updateLoading();
    // await Future.delayed(Duration(seconds: 10));
    final response = await NetworkService().postRoute(
    {
      // "email": "viswanathanmanickam5@gmail.com",
      // "deviceID":"C94E3948-77C0-43DE-864F-D31CE817284B",
      "deviceAPN":  widget.ApnsToken,
      "passcode": pin,
      // "eventId": "37af1ea2-282a-42fb-91f4-4c63188507be",
    }, 'auth/verify-otp');
    if(response.statusCode == 200){
      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      prefs.setBool('loggedIn', true);
      final responseMap = json.decode(response.data) as Map<String, dynamic>;
      User.instance.fromJson(responseMap.remove('user'));
      EventInfo.instance.fromJson(responseMap);
      for (var photo in responseMap["photos"]) {
        globals.mainPageImages.add(photo["url"].substring(1));
      } 
    }
    widget.updateLoading();
    return response.statusCode!;
  }
  void login (String pin, BuildContext context) {
    if(pin.isEmpty){
      utils.snackBarMessage(context, 'Please enter PIN');
      return;
    }
    if(pin.length<6){
      utils.snackBarMessage(context, 'PIN must be 6 digits');
      return;
    }
    try{
      int.parse(pin);
    }catch(e){
      utils.snackBarMessage(context, 'PIN must be numeric');
      return;
    }
    authenticate(int.parse(pin))
      .then((statusCode){
        switch(statusCode)
        {
          case 200:
            prefs.remove('gotEmail');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(),
              ),
            );
            break;
          case 400:
            utils.snackBarMessage(context, 'Bad Request');
            break;
          case 401:
            utils.snackBarMessage(context, 'PIN is invalid for account!');
            break;
          case 408:
            utils.snackBarMessage(context, 'Server Timed Out!');
            break;
          default:
            utils.snackBarMessage(context, 'Internal Server Error!');
        }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                multiDigitInput(
                  digits: 6,
                  onChanged: (code) {
                    setState(() {
                      pin = code;
                    });
                  },
                  onSubmitted: () {
                    login(pin, context);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => loginPage(sentPassword: false,),
                          ),
                        );
                      },
                      child: const Text(
                        "Didn't get an Email",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            submitButton(
              text: "Login", 
              onSubmit: (){
                login(pin, context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
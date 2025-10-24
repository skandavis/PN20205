import 'dart:async';
import 'package:PN2025/eventInfo.dart';
import 'package:PN2025/multiDigitInput.dart';
import 'package:PN2025/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding
import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/homePage.dart';
import 'package:PN2025/loginPage.dart';
import 'package:PN2025/submit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart' as utils;

class loginUI extends StatefulWidget {
  String pin = '';
  loginUI({super.key});

  @override
  State<loginUI> createState() => _loginUIState();
}
class _loginUIState extends State<loginUI> {
  Future<int> authenticate(int pin) async {
    try {
      var url = Uri.parse('${globals.url}auth/verify-otp');
      var response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              // 'Authorization': 'Bearer ${globals.loginToken}',
              'Cookie': "loginToken="+globals.loginToken
            },
            body: jsonEncode({
              // "email": "viswanathanmanickam5@gmail.com",
              // "deviceID":"C94E3948-77C0-43DE-864F-D31CE817284B",
              "passcode": pin,
              // "eventId": "37af1ea2-282a-42fb-91f4-4c63188507be",
            }),
          )
          .timeout(Duration(seconds: 3));

      if (response.statusCode == 200) {
        debugPrint("Success");
        globals.sessionToken = response.headers["set-cookie"].toString().split(",")[2];
        final SharedPreferencesAsync prefs = SharedPreferencesAsync();
        await prefs.setString('cookie', globals.sessionToken);
        Map<String, dynamic> responseMap = json.decode(response.body) as Map<String, dynamic>;
        User.instance.fromJson(responseMap.remove('user'));
        EventInfo.instance.fromJson(responseMap);
        for (var photo in responseMap["photos"]) {
          globals.mainPageImages.add(photo["url"].substring(1));
        }
        return response.statusCode;
      }
      else{
        return response.statusCode;
      }
    } on TimeoutException catch (_) {
      return 408;
    } catch (e) {
      debugPrint(e.toString());
      debugPrint("Fail");
      return 500;
    }
  }
  void login (String pin, BuildContext context) {
    if(pin.isEmpty){
      pin = "505637";
      // utils.snackBarMessage(context, 'Please enter pin');
      // return;
    }
    authenticate(int.parse(pin))
      .then((statusCode){
        switch(statusCode)
        {
          case 200:
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            multiDigitInput(
              digits: 6,
              onChanged: (code) {
                setState(() {
                  widget.pin = code;
                });
              },
              onSubmitted: () {
                login(widget.pin, context);
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
                        builder: (context) => loginPage(),
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
            login(widget.pin, context);
          },
        ),
      ],
    );
  }
}
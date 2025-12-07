import 'dart:async';
import 'package:NagaratharEvents/messageReciever.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/homePage.dart';
import 'package:NagaratharEvents/introPage.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferencesAsync prefs = SharedPreferencesAsync();

class SplashScreen extends StatefulWidget {
  bool showMainPage;
  SplashScreen({super.key, required this.showMainPage});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Duration of the splash screen before navigating to the main screen
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                widget.showMainPage ? MyHomePage() : const introPage()),
      );
      getAndCheckToken();
    });
  }

  void getAndCheckToken() async{
    globals.ApnsToken = await requestNotificationPermission(context, !widget.showMainPage);
    if(!widget.showMainPage) return;
    bool? hasPermission = await prefs.getBool('notificationPermission');
    prefs.setBool('notificationPermission', globals.ApnsToken.isNotEmpty);
    if(globals.ApnsToken.isNotEmpty == hasPermission!){
      //send to backend
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 24, 19, 118),
            Colors.black,
          ], begin: Alignment.centerLeft, end: Alignment.centerRight),
        ),
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/PillayarGold.png',
                width: MediaQuery.sizeOf(context).width * .7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

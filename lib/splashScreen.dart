import 'dart:async';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/messageReciever.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/homePage.dart';
import 'package:NagaratharEvents/introPage.dart';

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

  getAndCheckToken() async {
    globals.ApnsToken = await requestNotificationPermission(context, !widget.showMainPage);
    bool? enabled = await prefs.getBool('notificationsEnabled');
    if(enabled == null) return;
    if(enabled == globals.ApnsToken.isNotEmpty) return;
    //send token to backend
    prefs.setBool('notificationsEnabled', globals.ApnsToken.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            globals.darkAccent,
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

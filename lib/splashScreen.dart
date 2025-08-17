import 'dart:async';
import 'package:flutter/material.dart';
import 'package:PN2025/homePage.dart';
import 'package:PN2025/introPage.dart';

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
                widget.showMainPage ? MyHomePage(selectedIndex: 0,) : const introPage()),
      );
    });
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

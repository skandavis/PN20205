import 'package:flutter/material.dart';
import 'package:NagaratharEvents/messageReciever.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class introPage extends StatefulWidget {
  const introPage({super.key});

  @override
  State<introPage> createState() => _introPageState();
}

class _introPageState extends State<introPage> {
  bool gotEmail = false;
  @override
  void initState() {
    super.initState();
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    prefs.getBool('gotEmail').then((value) {
      if (value == true) {
        setState(() {
          gotEmail = true;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return messageReciever(
      body: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              globals.darkAccent,
              Colors.black,
            ], begin: Alignment.centerLeft, end: Alignment.centerRight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.event,
                        size: 64,
                        color: Colors.white,
                      ),
                      Text(
                        "Nagarathar",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: globals.titleFont,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                       Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Theme.of(context).textTheme.headlineLarge?.fontSize,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => loginPage(sentPassword: gotEmail,),
                            ),
                          );
                        },
                        child: Container(
                          height: 75,
                          width: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:  globals.secondaryColor,
                                width: 2),
                            borderRadius: BorderRadius.circular(25),
                            color:  globals.secondaryColor,
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: globals.backgroundColor,
                                fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,                              
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

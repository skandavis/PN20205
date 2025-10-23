import 'package:flutter/material.dart';
import 'package:PN2025/messageReciever.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/loginPage.dart';

class introPage extends StatefulWidget {
  const introPage({super.key});

  @override
  State<introPage> createState() => _introPageState();
}

class _introPageState extends State<introPage> {
  @override
  Widget build(BuildContext context) {
    return messageReciever(
      body: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color.fromARGB(255, 24, 19, 118),
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
                          fontSize: Theme.of(context).textTheme.headlineLarge?.fontSize,
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
                          fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
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
                              builder: (context) => loginPage(),
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
                              "Sign Up",
                              style: TextStyle(
                                color: globals.backgroundColor,
                                fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,                              
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

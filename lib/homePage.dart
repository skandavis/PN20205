import 'package:flutter/material.dart';
import 'package:NagaratharEvents/contactUsPage.dart';
import 'package:NagaratharEvents/activitiesPage.dart';
import 'package:NagaratharEvents/faqPage.dart';
import 'package:NagaratharEvents/notificationsPage.dart';
import 'package:NagaratharEvents/mainPage.dart';
import 'package:NagaratharEvents/messageReciever.dart';
import 'package:NagaratharEvents/settingsPage.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatefulWidget {
  int selectedIndex = 0;
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var pages = {
    "Home" : const mainPage(),
    "Activities" : const activitiesPage(),
    "Notifications" : const notificationsPage(),
    "FAQ" : const faqPage(),
    "Contact Us" : const contactUsPage(),
    "Settings" : const settingsPage(),
  }.entries.toList();

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return messageReciever(
      body: Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height*.075,
          title: Text(
            pages[widget.selectedIndex].key,
            style: TextStyle(
              fontFamily: GoogleFonts.arvo().fontFamily,
              fontSize: 36,
              color: Colors.white
              ),
            ),
          backgroundColor: globals.backgroundColor,
        ),
        backgroundColor: globals.backgroundColor,
        body: Container(
          decoration: const BoxDecoration(),
          clipBehavior: Clip.hardEdge,
          child: pages[widget.selectedIndex].value
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedFontSize: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14.0,
          unselectedItemColor: globals.backgroundColor,
          selectedItemColor:  globals.accentColor,
          items: [
            BottomNavigationBarItem(
              label: "Home",
              icon: Icon(
                Icons.home,
              ),
            ),
            BottomNavigationBarItem(
              label: "Activities",
              icon: Icon(
                Icons.event,
              ),
            ),
            BottomNavigationBarItem(
              label: "Messages",
              icon: Icon(
                Icons.question_answer,
              ),
            ),
            BottomNavigationBarItem(
              label: "FAQ",
              icon: Icon(
                Icons.contact_support,
              ),
            ),
            BottomNavigationBarItem(
              label: "Contact Us",
              icon: Icon(
                Icons.email,
              ),
            ),
            BottomNavigationBarItem(
              label: "Settings",
              icon: Icon(
                Icons.settings,
              ),
            ),
          ],
          currentIndex: widget.selectedIndex,
          onTap: (int index) {
            setState(() {
              widget.selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

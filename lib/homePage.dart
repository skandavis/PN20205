import 'package:flutter/material.dart';
import 'package:PN2025/contactUsPage.dart';
import 'package:PN2025/activitiesPage.dart';
import 'package:PN2025/faqPage.dart';
import 'package:PN2025/notificationsPage.dart';
import 'package:PN2025/mainPage.dart';
import 'package:PN2025/messageReciever.dart';
import 'package:PN2025/settingsPage.dart';
import 'package:PN2025/globals.dart' as globals;

class MyHomePage extends StatefulWidget {
  int selectedIndex = 0;
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var pages = {
    "Home" : const mainPage(),
    "Events" : const activitiesPage(),
    "Announcments" : const notificationsPage(),
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
          title: Text("data"),
        ),
        backgroundColor: globals.backgroundColor,
        body: Container(
          decoration: const BoxDecoration(),
          clipBehavior: Clip.hardEdge,
          child: pages[widget.selectedIndex].value
        ),
        bottomNavigationBar: SizedBox(
          height: MediaQuery.sizeOf(context).height*.1,
          child: BottomNavigationBar(
            backgroundColor: globals.backgroundColor,
            unselectedItemColor: globals.backgroundColor,
            selectedItemColor:  globals.accentColor,
            items:  const [
              BottomNavigationBarItem(
                label: "Home",
                icon: Icon(
                  size: 20,
                  Icons.home,
                ),
              ),
              BottomNavigationBarItem(
                label: "Activities",
                icon: Icon(
                  size: 20,
                  Icons.event,
                ),
              ),
              BottomNavigationBarItem(
                label: "Messages",
                icon: Icon(
                  size: 20,
                  Icons.question_answer,
                ),
              ),
              BottomNavigationBarItem(
                label: "FAQ",
                icon: Icon(
                  size: 20,
                  Icons.contact_support,
                ),
              ),
              BottomNavigationBarItem(
                label: "Contact Us",
                icon: Icon(
                  size: 20,
                  Icons.email,
                ),
              ),
              BottomNavigationBarItem(
                label: "Settings",
                icon: Icon(
                  size: 20,
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
      ),
    );
  }
}

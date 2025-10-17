import 'package:flutter/material.dart';
import 'package:PN2025/contactUsPage.dart';
import 'package:PN2025/activitiesPage.dart';
import 'package:PN2025/faqPage.dart';
import 'package:PN2025/announcmentsPage.dart';
import 'package:PN2025/mainPage.dart';
import 'package:PN2025/messageReciever.dart';
import 'package:PN2025/settingsPage.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  int selectedIndex;
  MyHomePage({super.key, required this.selectedIndex});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var pages = {
    "Home" : const mainPage(),
    "Events" : const activitiesPage(),
    "Announcments" : const announcmentsPage(),
    "FAQ" : const faqPage(),
    "Contact Us" : const contactUsPage(),
    "Settings" : const settingsPage(),
  }.entries.toList();

  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  @override
  void initState() {
    super.initState();
    setState(() {
      prefs.getString("name").then((value) {
        globals.fields.addAll({"name":value});
      });
      prefs.getString("phone").then((value) {
        globals.fields.addAll({"phone":value});
      });
      prefs.getString("city").then((value) {
        globals.fields.addAll({"city":value});
      });
      prefs.getString("email").then((value) {
        globals.fields.addAll({"email":value});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return messageReciever(
      body: Scaffold(
        backgroundColor: globals.backgroundColor,
        appBar: AppBar(
          title: Text(
            pages[widget.selectedIndex].key,
            style: TextStyle(
              fontSize:Theme.of(context).textTheme.displaySmall?.fontSize
            ),
          ),
          backgroundColor: globals.backgroundColor,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(),
          clipBehavior: Clip.hardEdge,
          height: MediaQuery.of(context).size.height * 0.8,
          child: pages[widget.selectedIndex].value
        ),
        // body: DailyCalendarPage(),
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
                label: "Events",
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

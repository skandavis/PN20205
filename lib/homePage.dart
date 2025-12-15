import 'package:flutter/material.dart';
import 'package:NagaratharEvents/contactUsPage.dart';
import 'package:NagaratharEvents/activitiesPage.dart';
import 'package:NagaratharEvents/faqPage.dart';
import 'package:NagaratharEvents/notificationsPage.dart';
import 'package:NagaratharEvents/mainPage.dart';
import 'package:NagaratharEvents/messageReciever.dart';
import 'package:NagaratharEvents/settingsPage.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class homePage extends StatefulWidget {
  int selectedIndex = 0;
  static final pageControllers = List.generate(6, (_) => ValueNotifier<int>(0));
  static final pages = {
    "Home" : mainPage(isVisible: pageControllers[0]),
    "Activities" : activitiesPage(isVisible: pageControllers[1],),
    "Notifications" : notificationsPage(isVisible: pageControllers[2],),
    "FAQ" : faqPage(isVisible: pageControllers[3],),
    "Contact Us" : contactUsPage(isVisible: pageControllers[4],),
    "Settings" : settingsPage(isVisible: pageControllers[5]),
  }.entries.toList();

  homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {

  @override
  void initState() {
    super.initState();
    homePage.pageControllers[0].value = 1;
  }

  @override
  Widget build(BuildContext context) {
    return messageReciever(
      body: Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height*.075,
          title: Text(
            homePage.pages[widget.selectedIndex].key,
            style: TextStyle(
              fontFamily: globals.titleFont,
              fontSize: globals.titleFontSize,
              color: Colors.white
              ),
            ),
          backgroundColor: globals.backgroundColor,
        ),
        backgroundColor: globals.backgroundColor,
        body: IndexedStack(
          index: widget.selectedIndex,
          children: homePage.pages.map((e) => e.value).toList(),
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
            homePage.pageControllers[widget.selectedIndex].value = 2;
            homePage.pageControllers[index].value = 1;
            setState(() {
              widget.selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

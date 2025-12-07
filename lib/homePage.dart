import 'package:flutter/material.dart';
import 'package:NagaratharEvents/contactUsPage.dart';
import 'package:NagaratharEvents/activitiesPage.dart';
import 'package:NagaratharEvents/faqPage.dart';
import 'package:NagaratharEvents/notificationsPage.dart';
import 'package:NagaratharEvents/mainPage.dart';
import 'package:NagaratharEvents/messageReciever.dart';
import 'package:NagaratharEvents/settingsPage.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class MyHomePage extends StatefulWidget {
  int selectedIndex = 0;
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final pageControllers = List.generate(6, (_) => ValueNotifier<bool>(false));

  late var pages = {
    "Home" : mainPage(isVisible: pageControllers[0]),
    "Activities" : activitiesPage(isVisible: pageControllers[1],),
    "Notifications" : notificationsPage(isVisible: pageControllers[2],),
    "FAQ" : faqPage(isVisible: pageControllers[3],),
    "Contact Us" : contactUsPage(isVisible: pageControllers[4],),
    "Settings" : settingsPage(isVisible: pageControllers[5],),
  }.entries.toList();

  @override
  void initState() {
    super.initState();
    pageControllers[0].value = true;
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
              fontFamily: globals.titleFont,
              fontSize: 36,
              color: Colors.white
              ),
            ),
          backgroundColor: globals.backgroundColor,
        ),
        backgroundColor: globals.backgroundColor,
        body: IndexedStack(
          index: widget.selectedIndex,
          children: pages.map((e) => e.value).toList(),
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
          pageControllers[widget.selectedIndex].value = false;
          pageControllers[index].value = true;
            setState(() {
              widget.selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

import 'package:PN2025/familyPage.dart';
import 'package:PN2025/user.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/accountPage.dart';
import 'package:PN2025/introPage.dart';
import 'package:PN2025/settingsOption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PN2025/globals.dart' as globals;

class settingsPage extends StatefulWidget {
  const settingsPage({super.key});

  @override
  State<settingsPage> createState() => _settingsPageState();
}

class _settingsPageState extends State<settingsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const accountPage(),
              ),
            );
          },
          child: settingsOption(
            icon: Icons.person,
            name: "Account",
          ),
        ),
        if(User.instance.isPrimaryUser())
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const familyPage(),
                ),
              );
            },
            child: settingsOption(icon: Icons.family_restroom, name: "Family"),
          ),
        GestureDetector(
          onTap: () async {
            final SharedPreferencesAsync prefs = SharedPreferencesAsync();
            await prefs.remove('loggedIn');
            globals.mainPageImages.clear();
            // globals.totalActivities.clear();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const introPage(),
              ),
            );
          },
          child: settingsOption(
            icon: Icons.logout,
            name: "Logout",
          ),
        )
      ],
    );
  }
}

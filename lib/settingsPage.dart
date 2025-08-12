import 'package:flutter/material.dart';
import 'package:pn2025/accountPage.dart';
import 'package:pn2025/introPage.dart';
import 'package:pn2025/settingsOption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pn2025/globals.dart' as globals;

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
        GestureDetector(
          onTap: () async {
            final SharedPreferencesAsync prefs = SharedPreferencesAsync();
            await prefs.remove('cookie');
            globals.token = "";
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

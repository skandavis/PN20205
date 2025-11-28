import 'package:NagaratharEvents/familyPage.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/accountPage.dart';
import 'package:NagaratharEvents/introPage.dart';
import 'package:NagaratharEvents/settingsOption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class settingsPage extends StatefulWidget {
  final ValueNotifier<bool> isVisible;
  const settingsPage({super.key, required this.isVisible});

  @override
  State<settingsPage> createState() => _settingsPageState();
}

class _settingsPageState extends State<settingsPage> {

  void initState() {
    super.initState();
    widget.isVisible.addListener(_onVisibilityChanged);
  }
  
  @override
  void dispose() {
    widget.isVisible.removeListener(_onVisibilityChanged);
    super.dispose();
  }

  void _onVisibilityChanged() {
    if (widget.isVisible.value) {
      // is visible;
    } else {
      // is not visible
    }
  }

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

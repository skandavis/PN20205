import 'package:NagaratharEvents/familyPage.dart';
import 'package:NagaratharEvents/qrCodePage.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:NagaratharEvents/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/accountPage.dart';
import 'package:NagaratharEvents/settingsOption.dart';

class settingsPage extends StatefulWidget {
  final ValueNotifier<bool> isVisible;
  const settingsPage({super.key, required this.isVisible});

  @override
  State<settingsPage> createState() => _settingsPageState();
}

class _settingsPageState extends State<settingsPage> {

  @override
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
                builder: (context) => accountPage(firstTime: false,),
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
                builder: (context) => qrCodePage(),
              ),
            );
          },
          child: settingsOption(
            icon: Icons.qr_code_2,
            name: "Check In",
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
          onTap: utils.logout,
          child: settingsOption(
            icon: Icons.logout,
            name: "Logout",
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pn2025/announcmentsPage.dart';
import 'package:pn2025/customDrawerTile.dart';

class CustomDrawer extends StatelessWidget {
  List<dynamic> users;
  CustomDrawer({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 100),
            child: Icon(
              Icons.lock_open_rounded,
              size: 80,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .60,
            child: ListView.builder(
              itemCount: users.length + 1,
              itemBuilder: (context, index) {
                return customDrawerTile(
                  title: index < users.length
                      ? users[index]["username"]
                      : "General",
                  icon: Icons.verified_user_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => announcmentsPage(
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

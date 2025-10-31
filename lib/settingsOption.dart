import 'package:flutter/material.dart';

class settingsOption extends StatefulWidget {
  IconData icon;
  String name;
  settingsOption({super.key, required this.icon, required this.name});

  @override
  State<settingsOption> createState() => _settingsOptionState();
}

class _settingsOptionState extends State<settingsOption> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                widget.icon,
                size: 40,
                color: Colors.white,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .05,
              ),
              Text(
                widget.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  color: Colors.white
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_right,
            size: 40,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

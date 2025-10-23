import 'package:PN2025/globals.dart' as globals;
import 'package:flutter/material.dart';

class participantfielditem extends StatefulWidget {
  IconData icon;
  String title;
  String value;
  participantfielditem({super.key, required this.icon, required this.title, required this.value});

  @override
  State<participantfielditem> createState() => _participantfielditemState();
}

class _participantfielditemState extends State<participantfielditem> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Icon(
          widget.icon,
          color: globals.secondaryColor,
          size: 32,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: TextStyle(color: globals.secondaryColor),
            ),
            Text(
              widget.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold
              ),
            ),
          ]
        )
      ]),
    );
  }
}
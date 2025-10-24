import 'package:PN2025/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'dart:math';
class familyMemberSquare extends StatefulWidget {
  String name;
  String email;
  familyMemberSquare({super.key,required this.email, required this.name});

  @override
  State<familyMemberSquare> createState() => _familyMemberSquareState();
}


class _familyMemberSquareState extends State<familyMemberSquare> {
  @override
  Widget build(BuildContext context) {
    final Random random = Random();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Color.fromARGB(
          255, 
          random.nextInt(256),
          random.nextInt(256), 
          random.nextInt(256),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.person, size: 64, color: globals.backgroundColor),
          Text(widget.name,
              style: TextStyle(color: globals.backgroundColor, fontSize: 14)),
          Text(widget.email,
              style: TextStyle(color: globals.backgroundColor, fontSize: 14)),
        ],
      ),
    );
  }
}
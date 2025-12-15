import 'package:NagaratharEvents/familyMember.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:NagaratharEvents/globals.dart' as globals;

class familyMemberSquare extends StatefulWidget {
  final FamilyMember  familyMember;

  const familyMemberSquare({
    super.key,
    required this.familyMember
  });

  @override
  State<familyMemberSquare> createState() => _familyMemberSquareState();
}

class _familyMemberSquareState extends State<familyMemberSquare> {
  late Color bgColor;
  late Color textColor;

  @override
  void initState() {
    super.initState();
    final Random random = Random();
    bgColor = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );

    textColor = _getContrastingTextColor(bgColor);
  }

  Color _getContrastingTextColor(Color background) {
    final double luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: bgColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.person, size: 64, color: textColor),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(widget.familyMember.name, style: TextStyle(color: textColor, fontSize: globals.bodyFontSize, fontWeight: FontWeight.bold),)),
        ],
      ),
    );
  }
}

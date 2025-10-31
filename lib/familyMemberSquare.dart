import 'package:flutter/material.dart';
import 'dart:math';

class familyMemberSquare extends StatefulWidget {
  final String name;
  final String email;

  const familyMemberSquare({
    super.key,
    required this.email,
    required this.name,
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

    // Determine brightness of the color
    textColor = _getContrastingTextColor(bgColor);
  }

  Color _getContrastingTextColor(Color background) {
    // Use luminance to determine if the color is light or dark
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
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(widget.name, style: TextStyle(color: textColor, fontSize: 14))),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(widget.email, style: TextStyle(color: textColor, fontSize: 14))),
        ],
      ),
    );
  }
}

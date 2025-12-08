import 'package:flutter/material.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
class participantDetailTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  const participantDetailTile({super.key, required this.icon, required this.title, required this.value});

  @override
  State<participantDetailTile> createState() => _participantDetailTileState();
}

class _participantDetailTileState extends State<participantDetailTile> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon, 
            color: globals.secondaryColor,
            size: 28
          ),
          SizedBox(height: 4),
          Text(
            widget.title,
            style: TextStyle(color: globals.secondaryColor, fontSize: globals.smallFontSize),
          ),
          Text(
            widget.value,
            style: TextStyle(
              color: Colors.white,
              fontSize: globals.smallFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
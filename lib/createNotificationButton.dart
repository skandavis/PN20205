import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/sendMessageDialog.dart';
import 'package:flutter/material.dart';

class createNotificationButton extends StatefulWidget {
  Function(String,String)? sendMessage;
  String route;
  createNotificationButton({super.key, this.sendMessage, required this.route});

  @override
  State<createNotificationButton> createState() => _createNotificationButtonState();
}

class _createNotificationButtonState extends State<createNotificationButton> {

  void showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return sendMessageDialog(route: widget.route,sendMessage: widget.sendMessage);
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showDialogBox,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: globals.secondaryColor,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}
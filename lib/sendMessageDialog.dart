import 'package:PN2025/checkBox.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/gradientTextField.dart';
import 'package:PN2025/utils.dart' as utils;
import 'package:flutter/material.dart';

class sendMessageDialog extends StatefulWidget {
  Function(String,String)? sendMessage;
  String route;
  sendMessageDialog({super.key, required this.route, this.sendMessage});

  @override
  State<sendMessageDialog> createState() => _sendMessageDialogState();
}

class _sendMessageDialogState extends State<sendMessageDialog> {
TextEditingController messageController = TextEditingController();

void updateIsPush() {
  globals.isPush = !globals.isPush;
}
void sendMessage(BuildContext context) async {
  final messageText = messageController.text.trim();
  debugPrint(globals.isPush.toString());
  if (messageText.isEmpty)
  {
    utils.snackBarMessage(context, 'Please enter a message');
    Navigator.pop(context);
    return;
  } 
  if (messageText.length<5)
  {
    utils.snackBarMessage(context, 'Message is too small');
    Navigator.pop(context);
    return;
  } 
  final type = globals.isPush ? "P" : "N";
  final responseCode = await utils.postRoute(
    {
      'message': messageText,
      'type': type,
    },
    widget.route,
  );

  if (responseCode == 200) {
    setState(() {
      messageController.clear();
      globals.isPush = false;
    });

    utils.snackBarMessage(context, "Message Sent!", color: Colors.green);
    if(widget.sendMessage != null)
    {
      widget.sendMessage!(messageText,type);
    }
    Navigator.pop(context);
  } else {
    utils.snackBarMessage(context, "Unable to send Message!");
    Navigator.pop(context); 
  }
}
  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(
        maxWidth: 300,
        maxHeight: 400
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Colors.white
        ),
        child: Column(
          children: [
            Container(
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                color: Color.fromARGB(255,31,53,76)
              ),
              child: Center(
                child: Text(
                  "Create Notification", 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 28
                  ),
                ),
              ),
            ),
            Container(
              height: 325,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  gradientTextField(
                    maxLines: 5,
                    controller: messageController,
                    hint: "Ex: Meet at Main Hall",
                    label: "Message", 
                    icon: Icons.message,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Check(name: "Push", onChange: updateIsPush, color: globals.iceBlue),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: globals.secondaryColor,
                      ),
                      width: 150,
                      height: 60,
                      child: Center(
                        child: Text(
                          "Send",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

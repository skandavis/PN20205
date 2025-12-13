import 'package:NagaratharEvents/checkBox.dart';
import 'package:NagaratharEvents/customDialogBox.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/gradientTextField.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/utils.dart' as utils;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class sendMessageDialog extends StatefulWidget {
  Function(Response)? sendMessage;
  String route;
  sendMessageDialog({super.key, required this.route, this.sendMessage});

  @override
  State<sendMessageDialog> createState() => _sendMessageDialogState();
}

class _sendMessageDialogState extends State<sendMessageDialog> {
TextEditingController messageController = TextEditingController();
bool isPush = false;
void updateIsPush() {
  isPush = !isPush;
}
void sendMessage(BuildContext context) async {
  FocusManager.instance.primaryFocus?.unfocus();  
  final messageText = messageController.text.trim();
  if (messageText.isEmpty)
  {
    utils.snackBarAboveMessage('Please enter a message');
    return;
  } 
  if (messageText.length<5)
  {
    utils.snackBarAboveMessage('Message is too small');
    return;
  } 
  final type = isPush ? "P" : "N";
  final response = await NetworkService().postRoute(
    {
      'message': messageText,
      'type': type,
    },
    widget.route,
  );

  if (response.statusCode! == 200) {
    setState(() {
      messageController.clear();
      isPush = false;
    });

    utils.snackBarMessage("Message Sent!", color: Colors.green);
    if(widget.sendMessage != null)
    {
      widget.sendMessage!(response);
    }
    Navigator.pop(context);
  } else {
    utils.snackBarMessage("Unable to send Message!");
    Navigator.pop(context); 
  }
}
  @override
  Widget build(BuildContext context) {
    return customDialogBox(
      title: "Create Notification", 
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              Check(
                name: "Push", 
                onChange: updateIsPush, 
                color: globals.iceBlue,
              ),
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
                    fontSize: globals.subTitleFontSize
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

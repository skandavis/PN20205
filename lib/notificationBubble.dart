import 'package:NagaratharEvents/customDialogBox.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:NagaratharEvents/notification.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class notificationBubble extends StatefulWidget {
  Notification notification;
  Function delete;
  bool newMessage;
  notificationBubble(
      {super.key,
      required this.notification,
      required this.delete,
      required this.newMessage});

  @override
  State<notificationBubble> createState() => _notificationBubbleState();
}

class _notificationBubbleState extends State<notificationBubble> {
  User user = User.instance;
  void showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return customDialogBox(
          height: 350,
          title: "Delete Notification",
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Are you really sure you want to delete this notification? Understand that this change will affect all users in the event.",
                style: TextStyle(fontSize: globals.paraFontSize),
              ),
              GestureDetector(
                onTap: () {
                  widget.delete();
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.red,
                  ),
                  width: 150,
                  height: 60,
                  child: Center(
                    child: Text(
                      "Delete",
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
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.notification.creatorName.contains(' ') ? "${widget.notification.creatorName.split(' ')[0]} ${widget.notification.creatorName.split(' ')[1][0]}." : widget.notification.creatorName,
              style: TextStyle(
                color: Colors.white,
                fontSize: globals.paraFontSize,
                fontWeight: FontWeight.bold
              ),
            ),
            Text(
              DateFormat('EE MMM d, h:mm a').format(widget.notification.creationTime),
              style:  TextStyle(
                color: Colors.white,
                fontSize: globals.paraFontSize,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        if(user.isAdmin)
        Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
                onPressed: (context) {
                  showDialogBox();
                },
              ),
            ],
          ),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 1,
            decoration: BoxDecoration(
              color: widget.newMessage?Colors.amber:Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.5),
              child: Text(
                widget.notification.message,
                style: TextStyle(
                  color: Colors.black, 
                  fontSize: globals.bodyFontSize
                ),
              ),
            ),
          ),
        ),
        if(!user.isAdmin)
        Container(
          width: MediaQuery.sizeOf(context).width * 1,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.5),
            child: Text(
              widget.notification.message,
              style: TextStyle(fontSize: globals.bodyFontSize),
            ),
          ),
        )
      ],
    );
  }
}

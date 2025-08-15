import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'utils.dart' as utils;


class announcment extends StatefulWidget {
  bool newMessage;
  DateTime date = DateTime.now();
  String message;
  Function delete;
  int id;
  bool canDelete;
  announcment(
      {super.key,
      required this.newMessage,
      required this.message,
      required this.delete,
      required this.id,
      required this.canDelete});

  @override
  State<announcment> createState() => _announcmentState();
}

class _announcmentState extends State<announcment> {
  void removeNotification() async {
    utils.deleteRoute('notifications/${widget.id}');
  }

  @override
  Widget build(BuildContext context) {
    void showDialogBox() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: AlertDialog(
              backgroundColor: const Color.fromARGB(255, 15, 9, 95),
              title: Text(
                "Do you want to delete?",
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold
                ),
              ),
              content: SizedBox(
                height: 20,
                width: MediaQuery.sizeOf(context).width * .8,
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                      color: Colors.red,
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: TextButton(
                        onPressed: () {
                          widget.delete();
                          removeNotification();
                          Navigator.of(context).pop();
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            Text(
                              "Delete",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              DateFormat('EEEE MMM d, h:mm a').format(widget.date),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        if(widget.canDelete)
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
                  widget.message,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        if(!widget.canDelete)
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
                widget.message,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          )
      ],
    );
  }
}

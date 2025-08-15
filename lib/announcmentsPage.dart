import 'package:flutter/material.dart';
import 'package:PN2025/announcment.dart';
import 'package:PN2025/checkBox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart' as utils;
import 'package:PN2025/globals.dart' as globals;
import 'package:collection/collection.dart';
import 'package:collection/collection.dart';

class announcmentsPage extends StatefulWidget {
  const announcmentsPage({super.key});

  @override
  State<announcmentsPage> createState() => _announcmentsPageState();
}



class _announcmentsPageState extends State<announcmentsPage> {
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController(); // Define in your state
  static List<dynamic>? messages;
  static List<dynamic> newMessages = [];
  bool isPush = false;
  static String? type;
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();


  void updateIsPush() {
    setState(() {
      isPush = !isPush;
    });
  }

  void showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 15, 9, 95),
            title: Text(
              "New Announcement",
              softWrap: true,
              maxLines: 2,
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold
              ),
            ),
            content: SizedBox(
              height: MediaQuery.sizeOf(context).height * .18,
              width: MediaQuery.sizeOf(context).width * .8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextField(
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    minLines: 2,
                    controller: messageController,
                    autofocus: true,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Ex: Everyone come to dinner",
                    ),
                  ),
                  Check(
                    color: Colors.white,
                    name: "Push Notification",
                    onChange: updateIsPush,
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      messageController.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Quit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: const WidgetStatePropertyAll(
                        Colors.white,
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        globals.accentColor,
                      ),
                    ),
                    onPressed: () async{
                      if (messageController.text.isEmpty||messages==null) {
                        return;
                      }
                      sendMessage(context);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.send), // Icon to display
                    label: const Text('Send'), // Text to display
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void sendMessage(BuildContext context) async {
    utils.postRoute(
      {
        'message': messageController.text,
        "type": isPush ? "P" : "N",
      },
      'notifications',
    ).then((statusCode){
      if(statusCode ==200)
      {
        setState(() {
          messages!.add({
            "id": messages!.length + 1,
            "message": messageController.text,
            "type": "P"
          });
        });
        messageController.clear();
        utils.snackBarMessage(context, "Message Sent!",color: Colors.green);
      }else
      {
        utils.snackBarMessage(context, "Unable to send Message!");
      }
    });
  }
  @override
  void initState() {
    if(messages==null)
    {
      utils.getRoute('notifications').then((value) {
        setState(() {
          if(value == null) return;
          messages = value['notifications'];
          debugPrint(value.toString());
        });
        debugPrint("notifcatio loaded");
      });
    }
    if(type==null)
    {
      prefs.getString("userType").then((value) {
        setState(() {
          type = value!;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(messages==null)
        const Column(
          children: [
            CircularProgressIndicator(),
            Text(
              "Loading",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 44
              ),
            )
          ],
        ),
        if(messages!=null)
        Container(
          height: MediaQuery.sizeOf(context).height * .7,
          padding: const EdgeInsets.all(20),
          child: RefreshIndicator(
            onRefresh: () async{
              print('Overscrolled at top!');
              utils.getRoute('notifications').then((value) {
                if(value == null) return;
                setState(() {
                  if(ListEquality().equals(value["notifications"], messages))
                  {
                    debugPrint('hey');
                    return;
                  }

                  final eq = const DeepCollectionEquality();

                  newMessages = value["notifications"].where((item1) =>
                    !messages!.any((item2) => eq.equals(item1, item2))).toList();

                  print(newMessages);
                  messages = value['notifications'];
                });
                debugPrint("notifcatio loaded");
              });
            },
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages!.length,
              itemBuilder: (context, index) {
                index = messages!.length-1-index;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    announcment(
                      newMessage: newMessages.any((item) => DeepCollectionEquality().equals(item, messages![index])),
                      canDelete: type == "Admin" || type == "SuperAdmin",
                      id: messages![index]["id"],
                      delete: () {
                        setState(() {
                          messages!.removeAt(index);
                        });
                      },
                      message: messages![index]["message"],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        if (type == "Admin" || type == "SuperAdmin")
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
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
              )
            ],
          )
      ],
    );
  }
}

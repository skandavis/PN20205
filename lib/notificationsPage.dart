import 'package:PN2025/createNotificationButton.dart';
import 'package:PN2025/user.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:PN2025/notificationBubble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart' as utils;
import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/notification.dart';

class notificationsPage extends StatefulWidget {
  const notificationsPage({super.key});

  @override
  State<notificationsPage> createState() => _notificationsPageState();
}

class _notificationsPageState extends State<notificationsPage> {
  ScrollController scrollController = ScrollController();
  List<Notification> messages = [];
  Set<String> newMessageIds = {}; // Track IDs of new messages
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  User user = User.instance;


  void sendMessage(String messageText, String type) async {
      final newNotification = Notification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: messageText,
        type: type,
        creatorName: "You",
        creationTime: DateTime.now(),
      );

      setState(() {
        messages.insert(0, newNotification);
        newMessageIds.add(newNotification.id); // Mark as new
      });
  }

  @override
  void initState() {
    super.initState();
    if (messages.isEmpty) {
      utils.getMultipleRoute('notifications').then((value) {
        if (value.isEmpty) return;
        setState(() {
          messages = value.map((item) => Notification.fromJson(item)).toList();
        });
        debugPrint("notifications loaded");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*.05,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize:Theme.of(context).textTheme.displaySmall?.fontSize
          ),
        ),
        backgroundColor: globals.backgroundColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: Stack(
          children: [
            if (messages.isEmpty)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  Text(
                    "Loading",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 44),
                  )
                ],
              ),
            if (messages.isNotEmpty)
              Container(
                height: MediaQuery.sizeOf(context).height,
                padding: const EdgeInsets.all(20),
                child: RefreshIndicator(
                  onRefresh: () async {
                    final fetched = await utils.getMultipleRoute('notifications');
                    if (fetched.isEmpty) return;
        
                    final fetchedList = fetched
                        .map((item) => Notification.fromJson(item))
                        .toList();
        
                    // Find messages that exist in fetched but not in current messages
                    final currentIds = messages.map((m) => m.id).toSet();
                    final newOnes = fetchedList
                        .where((f) => !currentIds.contains(f.id))
                        .toList();
        
                    setState(() {
                      // Clear old "new" status and mark only the newly fetched ones
                      newMessageIds.clear();
                      newMessageIds.addAll(newOnes.map((n) => n.id));
                      messages = fetchedList;
                    });
        
                    if (newOnes.isNotEmpty) {
                      utils.snackBarMessage(
                        context,
                        "${newOnes.length} new message${newOnes.length > 1 ? 's' : ''}",
                        color: Colors.blue,
                      );
                    }
                  },
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isNew = newMessageIds.contains(message.id);
        
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: notificationBubble(
                          newMessage: isNew,
                          notification: message,
                          delete: () {
                            setState(() {
                              messages.removeAt(index);
                              newMessageIds.remove(message.id);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (user.isAdmin())
            Positioned(
              bottom: 25,
              right:25,
              child: createNotificationButton(sendMessage: sendMessage,route: 'notifications',),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:PN2025/createNotificationButton.dart';
import 'package:PN2025/loadingScreen.dart';
import 'package:PN2025/networkService.dart';
import 'package:PN2025/user.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:PN2025/notificationBubble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart' as utils;
import 'package:PN2025/notification.dart';

class notificationsPage extends StatefulWidget {
  const notificationsPage({super.key});

  @override
  State<notificationsPage> createState() => _notificationsPageState();
}

class _notificationsPageState extends State<notificationsPage> {
  ScrollController scrollController = ScrollController();
  static List<Notification>? messages;
  static Set<String> newMessageIds = {};
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
        if(messages == null){
          messages = [newNotification];
        }else{
          messages!.add(newNotification);
        }
        newMessageIds.add(newNotification.id); // Mark as new
      });
  }

  @override
  void initState() {
    super.initState();
    if (messages ==null) {
      NetworkService().getMultipleRoute('notifications').then((value) {
        if (value == null) return;
        setState(() {
          messages = value.map((item) => Notification.fromJson(item)).toList();
        });
        debugPrint("notifications loaded");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: Stack(
        children: [
          messages!=null ? Container(
            height: MediaQuery.sizeOf(context).height,
            padding: const EdgeInsets.all(20),
            child: RefreshIndicator(
              onRefresh: () async {
                final fetched = await NetworkService().getMultipleRoute('notifications');
                if (fetched == null) return;
    
                final fetchedList = fetched
                    .map((item) => Notification.fromJson(item))
                    .toList();
    
                final currentIds = messages!.map((m) => m.id).toSet();
                final newOnes = fetchedList
                    .where((f) => !currentIds.contains(f.id))
                    .toList();
    
                setState(() {
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
                itemCount: messages!.length,
                itemBuilder: (context, index) {
                  final message = messages![index];
                  final isNew = newMessageIds.contains(message.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: notificationBubble(
                      newMessage: isNew,
                      notification: message,
                      delete: () {
                        setState(() {
                          messages!.removeAt(index);
                          newMessageIds.remove(message.id);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ):loadingScreen(),
          if (user.isAdmin())
          Positioned(
            bottom: 25,
            right:25,
            child: createNotificationButton(sendMessage: sendMessage,route: 'notifications',),
          )
        ],
      ),
    );
  }
}
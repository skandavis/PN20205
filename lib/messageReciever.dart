import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;

final SharedPreferencesAsync prefs = SharedPreferencesAsync();

class messageReciever extends StatefulWidget {
  Widget body;
  messageReciever({super.key, required this.body});

  @override
  State<messageReciever> createState() => _messageRecieverState();
}

class _messageRecieverState extends State<messageReciever> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue,
          content: Text(

            message.notification?.body ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
      globals.refreshActivities = message.data.containsKey('refresh');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      globals.refreshActivities = message.data.containsKey('refresh');
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.body;
  }
}

Future<String> requestNotificationPermission(BuildContext context, bool shouldShowDialog) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  switch (settings.authorizationStatus) {
    case AuthorizationStatus.authorized:
    if(shouldShowDialog){
      prefs.setBool('notificationPermission', true);
    }
      return getMessagingToken();

    case AuthorizationStatus.denied:
      if (shouldShowDialog) {
        prefs.setBool('notificationPermission', false);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Notifications Disabled"),
              content: Text(
                "You won't receive push notifications unless you enable them in Settings. Once you do you'll need to re-open the app for the changes to take effect.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openAppSettings();
                  },
                  child: Text("Open Settings"),
                ),
              ],
            );
          },
        );
      }

      return "";
    default:
      return "";
  }
}


Future<String> getMessagingToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  return token!;
}

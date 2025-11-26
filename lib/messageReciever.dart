import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
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
      ('Received a foreground message!');
      ('Message data: ${message.data}');

      if (message.notification != null) {
        ('Message contains a notification: ${message.notification}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(message.notification!.body ?? ''),
            action: SnackBarAction(
              label: message.notification!.title ?? '',
              onPressed: () {
                // Handle action
              },
            ),
          ),
        );
      }
    });
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return widget.body;
  }
}

Future<void> requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    ('User granted permission');
    getApnsToken();
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    ('User granted provisional permission');
  } else {
    ('User declined or has not accepted permission');
  }
}

Future<String> getApnsToken() async {
  String? token = Platform.isAndroid
      ? await FirebaseMessaging.instance.getToken()
      : await FirebaseMessaging.instance.getAPNSToken();
  return token!;
}

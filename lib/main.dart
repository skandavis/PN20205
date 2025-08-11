import 'package:flutter/material.dart';
import 'package:flutter_application_2/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_2/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/globals.dart' as globals;
import 'package:flutter_application_2/utils.dart' as utils;

bool showMainPage = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  prefs.getString('cookie').then((value) {
    if (value == null) {
      showMainPage = false;
    } else {
      globals.token = value;
      loadEvents();
    }
  });
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}
void loadEvents() async
{
  try {
    final response = await utils.getRoute('events');
    globals.totalEvents = response["events"];
    debugPrint(globals.totalEvents.toString());
  } catch (e) {
    debugPrint("error loading event data: $e");
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: SplashScreen(
        showMainPage: showMainPage,
      ),
    );
  }
}

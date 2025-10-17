import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:PN2025/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:PN2025/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PN2025/globals.dart' as globals;

bool showMainPage = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  prefs.getString('cookie').then((value) {
    if (value == null) {
      showMainPage = false;
    } else {
      globals.sessionToken = value;
      // loadEvents();
    }
  });
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
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

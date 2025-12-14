import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:NagaratharEvents/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'globals.dart' as globals;
import 'package:timezone/data/latest.dart' as tz;

bool showMainPage = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  prefs.getBool('loggedIn').then((value) {
    if (value == null) {
      showMainPage = false;
    }
  });
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  tz.initializeTimeZones();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: mediaQuery.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.2,
        ),),
      child: MaterialApp(
        navigatorKey: globals.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          textTheme: GoogleFonts.notoSansTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        // theme: ThemeData(),
        home: SplashScreen(
          showMainPage: showMainPage,
        ),
      ),
    );
  }
}

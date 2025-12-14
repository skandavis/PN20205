import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:NagaratharEvents/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
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
  tz.initializeTimeZones();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(App());
}

@pragma('vm:entry-point')
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globals.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      showMainPage: showMainPage,
    );
  }
}


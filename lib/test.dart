import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the current MediaQuery data for the device
    final mediaQuery = MediaQuery.of(context);

    // 2. Wrap your entire application (MaterialApp) with a new MediaQuery
    return MediaQuery(
      // 3. Copy the existing data and apply the clamping logic to textScaler
      data: mediaQuery.copyWith(
        textScaler: mediaQuery.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.2,
        ),
      ),
      // 4. Place your main app widget as the child
      child: MaterialApp( // or CupertinoApp
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Container(),
        // Add other properties like routes, etc.
      ),
    );
  }
}
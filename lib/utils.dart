import 'dart:async';
import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

  void snackBarMessage(BuildContext context, String message,{Color color = const Color.fromARGB(255, 185, 14, 1)})
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content:
            Text(message),
      ),
    );
  }


Future<void> addEventWithPermission(String title, String description, String location, DateTime startDate, DateTime endDate) async {
  // if (globals.calenderPermission.isGranted) {
    debugPrint("Granted");
    final event = Event(
      title: title,
      description: description,
      location: location,
      startDate: startDate,
      endDate: endDate,
    );
    Add2Calendar.addEvent2Cal(event);
  // } else {
  //   // Handle permission denied (show dialog or message)
  //   print("Calendar permission denied");
  // }
}

bool isValidEmail(String email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    debugPrint("VALID:${emailRegex.hasMatch(email)}" );
    return emailRegex.hasMatch(email);
  }
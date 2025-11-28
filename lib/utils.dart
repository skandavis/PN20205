import 'dart:async';
import 'package:NagaratharEvents/customDialogBox.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  void snackBarMessage(BuildContext context, String message,{Color color = const Color.fromARGB(255, 255, 51, 0)})
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content:
            Text(message),
      ),
    );
  }

// Future<bool> requestCalendarPermission(BuildContext context) async {
//   final status = await Permission.calendarWriteOnly.status;

//   if (status.isGranted) return true;

//   final newStatus = await Permission.calendarWriteOnly.request();

//   if (newStatus.isGranted) return true;

//   // ask user to open settings
//   if (newStatus.isDenied || newStatus.isPermanentlyDenied) {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Permission Required"),
//         content: Text("Enable calendar access in Settings to add events."),
//         actions: [
//           TextButton(
//             child: Text("Cancel"),
//             onPressed: () => Navigator.pop(context),
//           ),
//           TextButton(
//             child: Text("Open Settings"),
//             onPressed: () {
//               Navigator.pop(context);
//               openAppSettings();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   return false;
// }
Future<bool> requestCalendarPermission() async {
  // Ask for permissions
  var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
  if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
    permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
    if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
      return permissionsGranted.data!; // User denied permissions
    }
  }
  return true;
}

Future<void> addEventToCalendar(String name, String desc, String eventLocation, DateTime start, DateTime end, BuildContext context) async {
  final hasPermission = await requestCalendarPermission();
  if (!hasPermission) {
    print("Calendar permission not granted!");
    return;
  }

  final currentLocation = tz.local;
  final startLoc = tz.TZDateTime.from(start, currentLocation);
  final endLoc = tz.TZDateTime.from(end.add(Duration(hours: 1)), currentLocation);

  // Get user calendars
  final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
  final calendars = calendarsResult.data;

  if (calendars == null || calendars.isEmpty) {
    print("No calendars available");
    return;
  }

  // Let user pick a calendar
  final selectedCalendar = await showDialog<Calendar>(
    context: context,
    builder: (BuildContext context) {
      return customDialogBox(
        title: "Select Calendar", 
        body: SingleChildScrollView(
          child: Column(
            children: calendars.map((calendar) {
              final isReadOnly = calendar.isReadOnly ?? false;
              return ListTile(
                title: Text(calendar.name ?? "Unnamed Calendar", style: TextStyle(fontWeight: FontWeight.bold, color: globals.backgroundColor)),
                subtitle: isReadOnly ? Text("Read-only", style: TextStyle(color: Colors.red)) : null,
                trailing: isReadOnly ? Icon(Icons.lock, color: Colors.red) : null,
                onTap: () {
                  Navigator.of(context).pop(calendar);
                },
              );
            }).toList(),
          ),
        ),
      );
    },
  );

  if (selectedCalendar == null) {
    print("No calendar selected");
    return;
  }

  // Check if calendar is read-only
  if (selectedCalendar.isReadOnly ?? false) {
    snackBarMessage(context, "Calendar is read-only");
    return;
  }

  // Create event
  Event event = Event(
    selectedCalendar.id,
    title: name,
    description: desc,
    location: eventLocation,
    start: startLoc,
    end: endLoc,
  );

  // Save event
  final createResult = await _deviceCalendarPlugin.createOrUpdateEvent(event);

  if (createResult!.isSuccess) {
    snackBarMessage(context, "Event added successfully!", color: Colors.green);
    print("Event added successfully!");
  } else {
    print("Failed to add event");
  }
}

bool isValidEmail(String email) {
  final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  ("VALID:${emailRegex.hasMatch(email)}" );
  return emailRegex.hasMatch(email);
}
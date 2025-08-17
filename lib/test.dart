import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class CalendarManager extends StatefulWidget {
  const CalendarManager({super.key});

  @override
  _CalendarManagerState createState() => _CalendarManagerState();
}

class _CalendarManagerState extends State<CalendarManager> {
  String _statusMessage = 'Ready to request calendar permission';

  Future<void> _requestCalendarPermission() async {
    setState(() {
      _statusMessage = 'Requesting calendar permission...';
    });

    try {
      // Try both calendar permissions for better iOS compatibility
      PermissionStatus writeStatus = await Permission.calendarFullAccess.request();
      PermissionStatus fullStatus = await Permission.calendarFullAccess.request();
      
      // Use whichever permission was granted
      PermissionStatus status = writeStatus == PermissionStatus.granted 
          ? writeStatus 
          : fullStatus;
      
      if (status == PermissionStatus.granted) {
        setState(() {
          _statusMessage = 'Calendar permission granted!';
        });
      } else if (status == PermissionStatus.denied) {
        setState(() {
          _statusMessage = 'Calendar permission denied. Try requesting again.';
        });
      } else if (status == PermissionStatus.permanentlyDenied) {
        setState(() {
          _statusMessage = 'Calendar permission permanently denied. Please enable in Settings.';
        });
        
        // Show dialog with instructions
        _showSettingsDialog();
      } else {
        setState(() {
          _statusMessage = 'Permission status: $status. Try requesting again.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error requesting permission: $e';
      });
    }
  }

  Future<void> _showSettingsDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Calendar Access Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To add events to your calendar, please:'),
              SizedBox(height: 12),
              Text('1. Go to iOS Settings'),
              Text('2. Find this app in the list'),
              Text('3. Enable Calendar access'),
              SizedBox(height: 12),
              Text('Note: Calendar option may not appear until permission is first requested through the app.',
                   style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkCalendarPermission() async {
    // Check both permission types
    PermissionStatus writeStatus = await Permission.calendarFullAccess.status;
    PermissionStatus fullStatus = await Permission.calendarFullAccess.status;
    
    setState(() {
      _statusMessage = 'Write-only: ${writeStatus.toString()}\nFull access: ${fullStatus.toString()}';
    });
  }

  Future<void> _addEventToCalendar() async {
    // Check both permission types
    PermissionStatus writeStatus = await Permission.calendarFullAccess.status;
    PermissionStatus fullStatus = await Permission.calendarFullAccess.status;
    
    if (writeStatus != PermissionStatus.granted && fullStatus != PermissionStatus.granted) {
      setState(() {
        _statusMessage = 'Calendar permission not granted. Please request permission first.';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Adding event to calendar...';
    });

    try {
      // Create the event
      final Event event = Event(
        title: 'Flutter Meeting',
        description: 'Discuss Flutter calendar integration',
        location: 'Conference Room A',
        startDate: DateTime.now().add(Duration(hours: 1)),
        endDate: DateTime.now().add(Duration(hours: 2)),
        iosParams: IOSParams(
          reminder: Duration(minutes: 15), // 15 minutes before
          url: 'https://flutter.dev',
        ),
        androidParams: AndroidParams(
          emailInvites: ['example@email.com'],
        ),
      );

      // Add the event to calendar
      bool result = await Add2Calendar.addEvent2Cal(event);
      
      if (result) {
        setState(() {
          _statusMessage = 'Event successfully added to calendar!';
        });
      } else {
        setState(() {
          _statusMessage = 'Failed to add event to calendar';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error adding event: $e';
      });
    }
  }

  Future<void> _addRecurringEvent() async {
    // Check both permission types
    PermissionStatus writeStatus = await Permission.calendarFullAccess.status;
    PermissionStatus fullStatus = await Permission.calendarFullAccess.status;
    
    if (writeStatus != PermissionStatus.granted && fullStatus != PermissionStatus.granted) {
      setState(() {
        _statusMessage = 'Calendar permission not granted. Please request permission first.';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Adding recurring event to calendar...';
    });

    try {
      final Event recurringEvent = Event(
        title: 'Weekly Flutter Standup',
        description: 'Weekly team standup meeting',
        location: 'Virtual Meeting Room',
        startDate: DateTime.now().add(Duration(days: 1)),
        endDate: DateTime.now().add(Duration(days: 1, hours: 1)),
        allDay: false,
        iosParams: IOSParams(
          reminder: Duration(minutes: 10),
          url: 'https://meet.google.com/flutter-standup',
        ),
        recurrence: Recurrence(
          frequency: Frequency.weekly,
          interval: 1,
          endDate: DateTime.now().add(Duration(days: 90)), // End after 3 months
        ),
      );

      bool result = await Add2Calendar.addEvent2Cal(recurringEvent);
      
      if (result) {
        setState(() {
          _statusMessage = 'Recurring event successfully added to calendar!';
        });
      } else {
        setState(() {
          _statusMessage = 'Failed to add recurring event to calendar';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error adding recurring event: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iOS Calendar Integration'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 48,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Calendar Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkCalendarPermission,
              icon: Icon(Icons.info),
              label: Text('Check Calendar Permission'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _requestCalendarPermission,
              icon: Icon(Icons.pedal_bike),
              label: Text('Request Calendar Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addEventToCalendar,
              icon: Icon(Icons.event_note),
              label: Text('Add Single Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addRecurringEvent,
              icon: Icon(Icons.repeat),
              label: Text('Add Recurring Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 24),
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. Check current permission status'),
                    Text('2. Request calendar permission'),
                    Text('3. Add events to calendar once permission is granted'),
                    Text('4. Check your iOS Calendar app to see the events'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Main app wrapper
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Calendar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalendarManager(),
    );
  }
}

void main() {
  runApp(MyApp());
}
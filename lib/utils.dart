import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:PN2025/globals.dart' as globals;
import 'dart:convert'; // For JSON encoding
import 'package:add_2_calendar/add_2_calendar.dart';

int timeoutSecs = 30;
Future<Map<String, dynamic>> getSingleRoute(String route) async {
  try {
    final response = await http
        .get(
          Uri.parse('${globals.url}$route'),
          headers: {
            "Content-Type": "application/json",
            "Cookie": globals.sessionToken,
          },
        )
        .timeout(Duration(seconds: timeoutSecs)); // Add timeout here
    return json.decode(response.body);
  } on TimeoutException {
    print("GET request to $route timed out");
    return {}; // Return an empty map on timeout
  } catch (e) {
    print("Failed to load $route: $e");
    return {}; // Return an empty map on other failures
  }
}
Future<List<dynamic>> getMultipleRoute(String route) async {
  try {
    final response = await http
        .get(
          Uri.parse('${globals.url}$route'),
          headers: {
            "Content-Type": "application/json",
            "Cookie": globals.sessionToken,
          },
        )
        .timeout(Duration(seconds: timeoutSecs)); // Add timeout here
    return json.decode(response.body);
  } on TimeoutException {
    print("GET request to $route timed out");
    return []; // Return an empty map on timeout
  } catch (e) {
    print("Failed to load $route: $e");
    return []; // Return an empty map on other failures
  }
}
Future<int> updateNoData(String route) async {
  final url = Uri.parse('${globals.url}$route');
  try {
    final response = await http.patch(url).timeout(Duration(seconds: timeoutSecs));
    print("Updated Succesfully!");
    return response.statusCode;
  }  on TimeoutException catch (e) {
    print('Request timed out: $e');
    return 408; // custom code for timeout
  } catch (e) {
    print('Unexpected error: $e');
    return 500; // generic error code
  }
}


Future<int> postRoute(Map<String, dynamic> data, String route) async {
  final url = Uri.parse('${globals.url}$route');

  try {
    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Cookie": globals.sessionToken,
          },
          body: json.encode(data),
        )
        .timeout( Duration(seconds: timeoutSecs)); // Add timeout here

    if (response.statusCode == 200) {
      print('Sent successfully!');
    } else {
      print('Failed to send message. Status code: ${response.statusCode}');
    }

    return response.statusCode;
  } on TimeoutException {
    print('Request timed out.');
    return 408; // HTTP 408 Request Timeout
  } catch (e) {
    print('An error occurred: $e');
    return 500; // Generic server error
  }
}


Future<int> putRoute(Map<String, dynamic> data, String route) async {
  final url = Uri.parse('${globals.url}$route');
  try {
    final response = await http
        .put(
          url,
          headers: {
            "Content-Type": "application/json",
            "Cookie": globals.sessionToken,
          },
          body: json.encode(data),
        )
        .timeout( Duration(seconds: timeoutSecs)); // timeoutSecs-second timeout

    if (response.statusCode == 200) {
      print('Updated successfully!');
    } else {
      print('Failed to update. Status code: ${response.statusCode}');
    }

    return response.statusCode;
  } on TimeoutException {
    print('PUT request to $route timed out.');
    return 408;
  } catch (e) {
    print('An error occurred while updating: $e');
    return 500;
  }
}


Future<int> patchRoute(Map<String, dynamic> data, String route) async {
  final url = Uri.parse('${globals.url}$route');

  try {
    final response = await http
        .patch(
          url,
          headers: {
            "Content-Type": "application/json",
            "Cookie": globals.sessionToken,
          },
          body: json.encode(data),
        )
        .timeout( Duration(seconds: timeoutSecs)); // timeoutSecs-second timeout

    if (response.statusCode == 200) {
      print('Patched successfully!');
    } else {
      print('Failed to patch. Status code: ${response.statusCode}');
    }

    return response.statusCode;
  } on TimeoutException {
    print('PATCH request to $route timed out.');
    return 408;
  } catch (e) {
    print('An error occurred while patching: $e');
    return 500;
  }
}


void deleteRoute(String route) async {
  final url = Uri.parse('${globals.url}$route');
  try {
    final response = await http
        .delete(
          url,
          headers: {
            "Content-Type": "application/json",
            "Cookie": globals.sessionToken,
          },
        )
        .timeout( Duration(seconds: timeoutSecs)); // Apply timeoutSecs-second timeout

    if (response.statusCode == 200) {
      print('Deleted successfully!');
    } else {
      print('Failed to delete data. Status code: ${response.statusCode}');
    }
  } on TimeoutException {
    print('Delete request timed out.');
  } catch (e) {
    print('An error occurred while deleting: $e');
  }
}


Future<Uint8List> getImage(String route) async {
  final url = Uri.parse('${globals.baseUrl}$route');

  try {
    final imageResponse = await http
        .get(
          url,
          headers: {
            "Content-Type": "application/json",
            "Cookie": globals.sessionToken,
          },
        )
        .timeout( Duration(seconds: timeoutSecs)); // timeoutSecs-second timeout

    if (imageResponse.statusCode == 200) {
      print("got great image");
      return imageResponse.bodyBytes;
    } else {
      print('Failed to fetch image. Status code: ${imageResponse.statusCode}');
      return Uint8List(0);
    }
  } on TimeoutException {
    print('Image request to $route timed out.');
    return Uint8List(0);
  } catch (e) {
    print('An error occurred while fetching image: $e');
    return Uint8List(0);
  }
}

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
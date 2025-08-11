import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/globals.dart' as globals;
import 'dart:convert'; // For JSON encoding

Future<Map<String, dynamic>> getRoute(String route) async {
  try {
    http.Response response =
        await http.get(Uri.parse('${globals.url}$route'), headers: {
      "Content-Type": "application/json",
      "Cookie": globals.token,
    });

    return json.decode(response.body) as Map<String, dynamic>;
  } catch (e) {
    print("Failed to load $route");
    return {}; // Return an empty JSON object on failure
  }
}

void postRoute(Map<String, dynamic> data, String route) async {
  final url = Uri.parse('${globals.url}$route');
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Cookie": globals.token,
    },
    body: json.encode(
      data,
    ),
  );
  if (response.statusCode == 200) {
    // Handle success
    print('Sent successfully!');
  } else {
    // Handle error
    print('Failed to send message. Status code: ${response.statusCode}');
  }
}

void putRoute(String route) async {
  final url = Uri.parse('${globals.url}$route');
  final response = await http.put(
    url,
    headers: {
      "Content-Type": "application/json",
      "Cookie": globals.token,
    },
  );
  if (response.statusCode == 200) {
    // Handle success
    print('Updated successfully!');
  } else {
    // Handle error
    print('Failed to update. Status code: ${response.statusCode}');
  }
}

void patchRoute(Map<String, dynamic> data, String route) async {
  final url = Uri.parse('${globals.url}$route');
  final response = await http.patch(
    url,
    headers: {
      "Content-Type": "application/json",
      "Cookie": globals.token,
    },
    body: json.encode(
      data,
    ),
  );
  if (response.statusCode == 200) {
    // Handle success
    print('Patched successfully!');
  } else {
    // Handle error
    print('Failed to patch data. Status code: ${response.statusCode}');
  }
}

void deleteRoute(String route) async {
  final url = Uri.parse('${globals.url}$route');
  final response = await http.delete(
    url,
    headers: {
      "Content-Type": "application/json",
      "Cookie": globals.token,
    },
  );
  if (response.statusCode == 200) {
    // Handle success
    print('Deleted successfully!');
  } else {
    // Handle error
    print('Failed to delete data. Status code: ${response.statusCode}');
  }
}

Future<Uint8List> getImage(String route) async {
  final url = Uri.parse('${globals.url}$route');
  var imageResponse = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Cookie": globals.token,
    },
  );
  if (imageResponse.statusCode == 200) {
    return imageResponse.bodyBytes;
  } else {
    return Uint8List(0);
  }
}
  void snackBarMessage(BuildContext context, String message)
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content:
            Text(message),
      ),
    );
  }
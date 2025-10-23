library;
import 'package:PN2025/activity.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

String url = "http://192.168.86.38:81/api/v1/";
String baseUrl = "http://192.168.86.38:81/";

String loginToken = '';
String sessionToken = '';
bool isPush = false;

Color backgroundColor = const Color.fromARGB(255, 5, 3, 30);
Color secondaryColor = Color.fromARGB(255, 255, 183, 13);
Color secondaryTransitionColor = Color.fromARGB(255, 241, 119, 19);
Color accentColor = Color.fromARGB(255, 62, 54, 217);
Color highlightColor = Color.fromARGB(255, 183, 48, 232);
Color iceBlue = Color.fromARGB(255, 13, 182, 255);

List<String> mainPageImages = []; 
List<Activity> totalActivities = [];

PermissionStatus calenderPermission = PermissionStatus.denied;

library;
import 'package:NagaratharEvents/activity.dart';
import 'package:NagaratharEvents/category.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//frontend server
// String baseUrl = "http://192.168.86.38:81/";
// manickam server
// String baseUrl = "http://192.168.86.38:8081/";
String baseUrl = "https://nagaratharEvents.skandasoft.com/";
// String baseUrl = "https://nagaratharEvents-sbx/";
// String baseUrl = "http://nagaratharEvents.skandasoft.com:81/";

String url = "${baseUrl}api/v1/";

Color backgroundColor = const Color.fromARGB(255, 5, 3, 30);
Color secondaryColor = Color.fromARGB(255, 255, 183, 13);
Color secondaryTransitionColor = Color.fromARGB(255, 241, 119, 19);
Color accentColor = Color.fromARGB(255, 62, 54, 217);
Color highlightColor = Color.fromARGB(255, 183, 48, 232);
Color iceBlue = Color.fromARGB(255, 13, 182, 255);
Color darkAccent = Color.fromARGB(255, 24, 19, 118);

String? titleFont = GoogleFonts.arvo().fontFamily;
double smallFontSize = 12;
double paraFontSize = 14;
double bodyFontSize = 16;
double subTitleFontSize = 24;
double titleFontSize = 36;

bool refreshActivities = false;
List<Activity>? totalActivities;
List<ActivityCategory>? allCategories;
String ApnsToken = "";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


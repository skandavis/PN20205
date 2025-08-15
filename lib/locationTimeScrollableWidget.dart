import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:PN2025/utils.dart' as utils;
import 'package:intl/intl.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

class Locationtimescrollablewidget extends StatefulWidget {
  DateTime startTime;
  DateTime endTime;
  String location;
  LatLng geolocation;
  String description;
  Locationtimescrollablewidget({super.key,required this.startTime,required this.endTime,required this.location,required this.geolocation, required this.description});

  @override
  State<Locationtimescrollablewidget> createState() => _LocationtimescrollablewidgetState();
}

class _LocationtimescrollablewidgetState extends State<Locationtimescrollablewidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
       scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              utils.addEventWithPermission("Nagarathar Pillayar Nombu", "Description TBD", widget.location, widget.startTime, widget.endTime);
              // final event = Event(
              //   title: "Nagarathar Pillayar Nombu",
              //   description: "Description TBD",
              //   location: widget.location,
              //   startDate: widget.startTime,
              //   endDate: widget.endTime,
              //   allDay: false,
              // );
              // Add2Calendar.addEvent2Cal(event);
            },
            child: const Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 48,
            ),
          ),
          Column(
            children: [
              Text(
                DateFormat('MMMM d, y h:mm a').format(widget.startTime),
                style:  TextStyle(
                  color: Colors.white,
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                DateFormat('MMMM d, y h:mm a').format(widget.endTime),
                style:  TextStyle(
                  color: Colors.white,
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    widget.location,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              
            ],
          ),
          GestureDetector(
            onTap: () async{
              final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query="+widget.geolocation.latitude.toString()+','+widget.geolocation.longitude.toString());
              final Uri appleMapsUrl = Uri.parse("http://maps.apple.com/?ll="+widget.geolocation.latitude.toString()+','+widget.geolocation.longitude.toString());
      
              if (await canLaunchUrl(googleMapsUrl)) {
                await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
              } else if (await canLaunchUrl(appleMapsUrl)) {
                await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
              } else {
                throw 'Could not launch map';
              }
            },
            child: Icon(
              Icons.pin_drop_outlined,
              size: 48,
              color: globals.highlightColor,
            ),
          ),
        ],
      ),
    );
  }
}
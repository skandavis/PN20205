import 'dart:typed_data';
import 'package:PN2025/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:PN2025/expandedEventPage.dart';
import 'package:PN2025/favorite.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/imageCarousel.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class eventCard extends StatefulWidget {
  dynamic event;
  List<Uint8List> images;
  eventCard({
    super.key,
    required this.event,
    required this.images,
  });

  @override
  State<eventCard> createState() => _eventCardState();
}

@override
class _eventCardState extends State<eventCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime startTime = DateTime.parse(widget.event["startTime"]).toLocal();
    List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => expandedEventPage(
              event: widget.event,
              images: widget.images,
            ),
          ),
        ).then((_){
          setState(() {
          });
        });
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width*.9,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                if (widget.images.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
                    clipBehavior: Clip.hardEdge,
                    height: MediaQuery.sizeOf(context).height*.3,
                    child: ImageCarousel(images: widget.images),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // GestureDetector(
                    //   onTap: () {
                    //     final event = Event(
                    //       title: widget.event["name"],
                    //       description: widget.event["description"],
                    //       location: widget.event["location"],
                    //       startDate: DateTime.parse(widget.event["date"]),
                    //       endDate: DateTime.parse(widget.event["date"]).add(Duration(minutes: widget.event["duration"])),
                    //       allDay: false,
                    //     );
                    //     Add2Calendar.addEvent2Cal(event);
                    //   },
                    //   child: Container(
                    //     height: MediaQuery.sizeOf(context).height*.075,
                    //     width: MediaQuery.sizeOf(context).height*.075,
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(15),
                    //     ),
                    //     child: const Icon(Icons.event)
                    //   ),
                    // ),
                    Container(
                      height: MediaQuery.sizeOf(context).height*.075,
                      width: MediaQuery.sizeOf(context).height*.075,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            monthNames[startTime.month - 1].substring(0, 3),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                            ),
                          ),
                          Text(
                            startTime.day.toString(),
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.event["name"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.titleLarge?.fontSize
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          utils.addEventWithPermission(widget.event["name"], widget.event["description"], widget.event["location"], startTime, startTime.add(Duration(minutes: widget.event["duration"])));
                        },
                        child: Icon(Icons.event,color: globals.accentColor,)
                      ),
                      FavoriteIcon(
                        event: widget.event,
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width*.4,
                    child: Text(
                      widget.event["description"],
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: globals.backgroundColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          "${widget.event["duration"]} min",
                          style:  TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.pin_drop,
                    ),
                    Text(
                      widget.event["location"],
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: globals.backgroundColor,
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    "${startTime.hour > 12 ? startTime.hour - 12 : startTime.hour}:${startTime.minute} ${startTime.hour > 12 ? "PM" : "AM"}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height*.025,
            ),
            Container(
              height: MediaQuery.sizeOf(context).height*.075,
              width: MediaQuery.sizeOf(context).width*.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    globals.secondaryColor,
                    globals.secondaryTransitionColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  "Read more",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

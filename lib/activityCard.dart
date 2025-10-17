import 'dart:typed_data';
import 'package:PN2025/activity.dart';
import 'package:PN2025/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:PN2025/expandedActivityPage.dart';
import 'package:PN2025/favorite.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/imageCarousel.dart';

class activityCard extends StatefulWidget {
  Activity activity;
  List<Uint8List> images;
  activityCard({
    super.key,
    required this.activity,
    required this.images,
  });

  @override
  State<activityCard> createState() => _activityCardState();
}

@override
class _activityCardState extends State<activityCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime startTime = widget.activity.startTime;
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
            builder: (context) => expandedActivityPage(
              activity: widget.activity,
              images: widget.images,
            ),
          ),
        ).then((_){
          setState(() {
          });
        });
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width*.85,
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
                    widget.activity.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.titleLarge?.fontSize
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          utils.addEventWithPermission(widget.activity.name, widget.activity.description, widget.activity.location, startTime, startTime.add(Duration(minutes: widget.activity.duration)));
                        },
                        child: Icon(Icons.event,color: globals.accentColor,)
                      ),
                      // FavoriteIcon(
                      //   event: widget.activity,
                      // )
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
                      widget.activity.description,
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
                          "${widget.activity.duration} min",
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
                      widget.activity.location,
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

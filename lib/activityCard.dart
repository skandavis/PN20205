import 'package:NagaratharEvents/activity.dart';
import 'package:NagaratharEvents/sendMessageDialog.dart';
import 'package:NagaratharEvents/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/expandedActivityPage.dart';
import 'package:NagaratharEvents/favorite.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/imageCarousel.dart';
import 'package:intl/intl.dart';

class activityCard extends StatefulWidget {
  Activity activity;
  activityCard({
    super.key,
    required this.activity,
  });

  @override
  State<activityCard> createState() => _activityCardState();
}

class _activityCardState extends State<activityCard> {
  @override
  Widget build(BuildContext context) {
    DateTime startTime = widget.activity.startTime;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => expandedActivityPage(
              activity: widget.activity,
            ),
          ),
        ).then((value){
          setState(() {});
        });
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topLeft,
              children: [
                if (widget.activity.images.isNotEmpty)
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                  clipBehavior: Clip.hardEdge,
                  height: MediaQuery.sizeOf(context).height*.3,
                  child: imageCarousel(
                    imageUrls: widget.activity.images,
                  ),
                ),
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
                        DateFormat('MMM').format(startTime),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: globals.bodyFontSize,
                        ),
                      ),
                      Text(
                        startTime.day.toString(),
                        style: TextStyle(
                          fontSize: globals.paraFontSize
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .5,
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      widget.activity.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: globals.subTitleFontSize
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          utils.addEventToCalendar(widget.activity.name, widget.activity.description, widget.activity.location, startTime, startTime.add(Duration(minutes: widget.activity.duration)),context);
                        },
                        child: Icon(
                          Icons.event,
                          color: globals.accentColor,
                        ),
                      ),
                      favoriteIcon(
                        activity: widget.activity,
                      ),
                      if(widget.activity.isActivityAdmin)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return sendMessageDialog(route: 'activities/${widget.activity.id}/notification');
                            },
                          );
                        },
                        child: Icon(
                          Icons.add,
                          color: globals.accentColor,
                        ),
                      ),
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
                        fontSize: globals.paraFontSize
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                        decoration: BoxDecoration(
                            color: globals.backgroundColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          "${widget.activity.duration} min",
                          style:  TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: globals.paraFontSize
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
                    SizedBox(
                    width: MediaQuery.sizeOf(context).width*.4,
                      child: Text(
                        widget.activity.location,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: globals.paraFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                  decoration: BoxDecoration(
                      color: globals.backgroundColor,
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    DateFormat('h:mm a').format(startTime),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: globals.paraFontSize
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
                borderRadius: BorderRadius.circular(25),
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
                    fontSize: globals.subTitleFontSize,
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

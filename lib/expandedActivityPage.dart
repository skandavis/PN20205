import 'package:NagaratharEvents/activity.dart';
import 'package:NagaratharEvents/createNotificationButton.dart';
import 'package:NagaratharEvents/expandableHighlightext.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/participantRow.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/attribute.dart';
import 'package:NagaratharEvents/favorite.dart';
import 'package:NagaratharEvents/imageCarousel.dart';
import 'package:NagaratharEvents/thumbsUpIcon.dart';
import 'package:NagaratharEvents/verticalDivider.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class expandedActivityPage extends StatefulWidget {
  Activity activity;
  expandedActivityPage({super.key, required this.activity});

  @override
  State<expandedActivityPage> createState() => _expandedActivityPageState();
}

class _expandedActivityPageState extends State<expandedActivityPage> {
  bool ellipsis = true;
  Future<int> updateActivity(String? location, DateTime? startTime) async{
    if(location != null)
    {
      final response = await NetworkService().patchRoute({"location": location}, "activities/${widget.activity.id}", showAboveSnackBar: true);
      if(response.statusCode == 200)
      {
        globals.totalActivities![globals.totalActivities!.indexOf(widget.activity)].location = location;
      }
      return response.statusCode!;
    }
    if(startTime != null)
    {
      final response = await NetworkService().patchRoute({"startTime": startTime.toUtc().toIso8601String()}, "activities/${widget.activity.id}", showAboveSnackBar: true);
      if(response.statusCode == 200)
      {
        globals.totalActivities![globals.totalActivities!.indexOf(widget.activity)].startTime = startTime;
      }
      return response.statusCode!;
    }
    return 500;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: favoriteIcon(activity: widget.activity,),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: globals.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.transparent],
                      stops: [
                        0.75,
                        1.0
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: widget.activity.isActivityAdmin ? ImageCarousel(
                    imageUrls: widget.activity.images,
                    uploadPath: 'activities/${widget.activity.id}/photo',
                    fileName: "${widget.activity.name}ActivityImage.jpg",
                  ): ImageCarousel(
                    imageUrls: widget.activity.images,
                  ),
                ),
              ],
            ),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .5,
                  padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*.03),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.activity.name,
                              style: TextStyle(
                                fontSize: globals.subTitleFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.activity.sub,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: globals.bodyFontSize  
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 149, 235, 252),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                              child: Center(
                                child: Text(
                                  widget.activity.main,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: globals.paraFontSize
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            attribute(
                              isEditable: widget.activity.isActivityAdmin,
                              onValueChange: updateActivity,
                              attributeTitle: "Date",
                              attributeValue: widget.activity.startTime,
                            ),
                            const myVerticaldivider(),
                            attribute(
                              isEditable: widget.activity.isActivityAdmin,
                              onValueChange: updateActivity,
                              attributeTitle: "Location",
                              attributeValue: widget.activity.location,
                            ),
                            const myVerticaldivider(),
                            attribute(
                              isEditable: false,
                              attributeTitle: "Duration",
                              attributeValue: "${widget.activity.duration} minutes",
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        thumbsUpIcon(
                          activity: widget.activity,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              expandableHighlightText(
                                text: widget.activity.description,
                                editable: widget.activity.isActivityAdmin,
                                onTextChanged: (description) {
                                  NetworkService().patchRoute({
                                    "description": description
                                  }, "activities/${widget.activity.id}");
                                },
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Column(
                                children: List.generate(widget.activity.participants.length, (index) {
                                  return Column(
                                    children: [
                                      participantRow(participantIndex: index, activity: widget.activity,),
                                      SizedBox(height: 25,)
                                    ],
                                  );
                                },),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if(widget.activity.isActivityAdmin)
                Positioned(
                  bottom: 25,
                  right:25,
                  child: createNotificationButton(route: 'activities/${widget.activity.id}/notification',)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:NagaratharEvents/activity.dart';
import 'package:NagaratharEvents/createNotificationButton.dart';
import 'package:NagaratharEvents/expandableHighlightext.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/participantRow.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/attribute.dart';
import 'package:NagaratharEvents/categoryLabel.dart';
import 'package:NagaratharEvents/favorite.dart';
import 'package:NagaratharEvents/imageCarousel.dart';
import 'package:NagaratharEvents/thumbsUpIcon.dart';
import 'package:NagaratharEvents/verticalDivider.dart';
import 'package:NagaratharEvents/globals.dart' as globals;




class expandedActivityPage extends StatefulWidget {
  void updateActivity(String? location, DateTime? startTime) {
     if(location != null)
    {
      NetworkService().patchRoute({"location": location}, "activities/${activity.id}");
      globals.totalActivities![globals.totalActivities!.indexOf(activity)].location = location;
    }
    if(startTime != null)
    {
      NetworkService().patchRoute({"startTime": startTime}, "activities/${activity.id}");
      globals.totalActivities![globals.totalActivities!.indexOf(activity)].startTime = startTime;
    }
  }
  Activity activity;
  late Widget attrs = Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      attribute(
        isDate: true,
        onValueChange: updateActivity,
        isEditable: false,
        attributeTitle: "Date",
        attributeValue:
            "June ${activity.startTime.day}, ${activity.startTime.hour > 12 ? activity.startTime.hour - 12 : activity.startTime.hour}:${activity.startTime.minute} ${activity.startTime.hour > 12 ? "PM" : "AM"}",
      ),
      const myVerticaldivider(),
      attribute(
        isEditable: true,
        attributeTitle: "Location",
        attributeValue: activity.location,
      ),
      const myVerticaldivider(),
      attribute(
        isEditable: false,
        attributeTitle: "Duration",
        attributeValue: "${activity.duration} minutes",
      )
    ],
  );
  expandedActivityPage({super.key, required this.activity});

  @override
  State<expandedActivityPage> createState() => _expandedActivityPageState();
}

class _expandedActivityPageState extends State<expandedActivityPage> {
  bool ellipsis = true;
@override
  void initState() {
    super.initState();
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
                  child: ImageCarousel(
                    imageUrls: widget.activity.images,
                    uploadPath: 'activities/${widget.activity.id}/photo',
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        globals.backgroundColor,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.activity.name,
                        style: TextStyle(
                            fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            categoryLabel(
                              activity: widget.activity,
                            ),
                          ],
                        ),
                        widget.attrs,
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
                                text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. Why do we use it? It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).",
                              ),
                              // expandableHighlightText(text: widget.activity.description),
                              SizedBox(
                                height: 25,
                              ),
                              Column(
                                children: List.generate(widget.activity.participants.length, (index) {
                                  return Column(
                                    children: [
                                      participantRow(participant: widget.activity.participants[index], activity: widget.activity,),
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
                if(User.instance.isAdmin())
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

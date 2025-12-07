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
      final response = await NetworkService().patchRoute({"location": location}, "activities/${widget.activity.id}");
      if(response.statusCode == 200)
      {
        globals.totalActivities![globals.totalActivities!.indexOf(widget.activity)].location = location;
      }
      return response.statusCode!;
    }
    if(startTime != null)
    {
      final response = await NetworkService().patchRoute({"startTime": startTime.toIso8601String()}, "activities/${widget.activity.id}");
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
                  child: ImageCarousel(
                    imageUrls: widget.activity.images,
                    uploadPath: 'activities/${widget.activity.id}/photo',
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
                                  fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.activity.sub,style: TextStyle(color: Colors.white),),
                            categoryLabel(
                              activity: widget.activity,
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
                              onValueChange: updateActivity,
                              isEditable: true,
                              attributeTitle: "Date",
                              attributeValue: widget.activity.startTime,
                            ),
                            const myVerticaldivider(),
                            attribute(
                              isEditable: true,
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
                              // expandableHighlightText(
                              //   text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. Why do we use it? It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).",
                              // ),
                              expandableHighlightText(text: widget.activity.description),
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

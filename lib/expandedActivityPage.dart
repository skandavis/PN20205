import 'package:PN2025/activity.dart';
import 'package:PN2025/createNotificationButton.dart';
import 'package:PN2025/expandableHighlightext.dart';
import 'package:PN2025/participant.dart';
import 'package:PN2025/participantRow.dart';
import 'package:PN2025/user.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/attribute.dart';
import 'package:PN2025/categoryLabel.dart';
import 'package:PN2025/favorite.dart';
import 'package:PN2025/imageCarousel.dart';
import 'package:PN2025/thumbsUpIcon.dart';
import 'package:PN2025/verticalDivider.dart';
import 'package:PN2025/globals.dart' as globals;

class expandedActivityPage extends StatefulWidget {
  Activity activity;
  expandedActivityPage({super.key, required this.activity});

  @override
  State<expandedActivityPage> createState() => _expandedActivityPageState();
}

class _expandedActivityPageState extends State<expandedActivityPage> {
  bool ellipsis = true;

  @override
  Widget build(BuildContext context) {
    DateTime startTime = widget.activity.startTime;
    for(Participant guy in widget.activity.participants)
    {
      debugPrint(guy.name);
    }
    debugPrint('');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FavoriteIcon(
              activity: widget.activity,
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: globals.backgroundColor,
      body: Column(
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
                    ], // Controls where the fade begins and ends
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ImageCarousel(imageUrls: widget.activity.images),
              ),
              Text(
                widget.activity.name,
                style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          attribute(
                            attributeTitle: "Date",
                            attributeValue:
                                "June ${startTime.day}, ${startTime.hour > 12 ? startTime.hour - 12 : startTime.hour}:${startTime.minute} ${startTime.hour > 12 ? "PM" : "AM"}",
                          ),
                          const myVerticaldivider(),
                          attribute(
                            attributeTitle: "Location",
                            attributeValue: widget.activity.location,
                          ),
                          const myVerticaldivider(),
                          attribute(
                            attributeTitle: "Duration",
                            attributeValue: "${widget.activity.duration} min",
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
                              text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. Why do we use it? It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).",
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Column(
                              children: List.generate(widget.activity.participants.length, (index) {
                                return participantRow(activity: widget.activity, index: index);
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
    );
  }
}

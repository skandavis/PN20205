import 'package:PN2025/activity.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/attribute.dart';
import 'package:PN2025/categoryLabel.dart';
import 'package:PN2025/description.dart';
import 'package:PN2025/favorite.dart';
import 'package:PN2025/imageCarousel.dart';
import 'package:PN2025/thumbsUpIcon.dart';
import 'package:PN2025/verticalDivider.dart';
import 'dart:typed_data';
import 'package:PN2025/globals.dart' as globals;

class expandedActivityPage extends StatefulWidget {
  Activity activity;
  List<Uint8List> images;
  expandedActivityPage({super.key, required this.images, required this.activity});

  @override
  State<expandedActivityPage> createState() => _expandedActivityPageState();
}

class _expandedActivityPageState extends State<expandedActivityPage> {
  bool ellipsis = true;

  @override
  Widget build(BuildContext context) {
    DateTime startTime = widget.activity.startTime;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        foregroundColor: Colors.white,
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
                      ], // Controls where the fade begins and ends
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  // child: Image.network(
                  // "https://img.freepik.com/free-photo/group-active-kids-cheerful-girls-dancing-isolated-green-background-neon-light_155003-46334.jpg"),
                  child: ImageCarousel(images: widget.images),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.activity.name,
                        style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                        categoryLabel(
                          activity: widget.activity,
                        )
                    ],
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // FavoriteIcon(
                //   activity: widget.activity,
                // ),
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
                  attributeValue: "${widget.activity.location} min",
                )
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            // thumbsUpIcon(
            //   event: widget.activity,
            // ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  const Text(
                    "About Event",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  descriptionBox(
                    ellipsis: ellipsis,
                    description: widget.activity.description,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

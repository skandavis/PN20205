import 'dart:io';
import 'package:NagaratharEvents/activity.dart';
import 'package:NagaratharEvents/imageLoader.dart';
import 'package:NagaratharEvents/participant.dart';
import 'package:NagaratharEvents/participantDetailDialog.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class participantRow extends StatefulWidget {
  int participantIndex;
  Activity activity;
  participantRow({super.key, required this.participantIndex, required this.activity});

  @override
  State<participantRow> createState() => _participantRowState();
}

class _participantRowState extends State<participantRow> {
  late int activityIndex = globals.totalActivities!.indexOf(widget.activity);
  late Participant participant = widget.activity.participants[widget.participantIndex];
  void onImageUpdated(File image) {
    setState(() {
      globals.totalActivities![activityIndex].participants[widget.participantIndex].image = image.path;
      participant.image = image.path;
      debugPrint("image.path: ${image.path}");
    });
  }

  void displayParticipantDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ParticipantDetailDialog(
          participant: participant,
          onImageUpdated: onImageUpdated,
          onDataChanged: (data){
            setState(() {
              participant.updateInfo(data);
              globals.totalActivities![activityIndex].participants[widget.participantIndex].updateInfo(data);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: displayParticipantDetails,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            imageLoader(
              onUpload: onImageUpdated,
              imageRoute: participant.image,
              circle: true,
              key: ValueKey(participant.image),
              size: 75,
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    participant.name,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .6,
                    child: Text(
                      participant.description,
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                     ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
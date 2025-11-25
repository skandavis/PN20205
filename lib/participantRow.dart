import 'dart:io';
import 'package:NagaratharEvents/activity.dart';
import 'package:NagaratharEvents/participant.dart';
import 'package:NagaratharEvents/participantDetailDialog.dart';
import 'package:NagaratharEvents/profileImageCircle.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class participantRow extends StatefulWidget {
  Participant participant;
  Activity activity;
  participantRow({super.key, required this.participant, required this.activity});

  @override
  State<participantRow> createState() => _participantRowState();
}

class _participantRowState extends State<participantRow> {
  void onImageUpdated(File image) {
    setState(() {
      int index = globals.totalActivities![globals.totalActivities!.indexOf(widget.activity)].participants.indexOf(widget.participant);
      globals.totalActivities![globals.totalActivities!.indexOf(widget.activity)].participants[index].image = image.path;
      widget.participant.image = image.path;
      debugPrint("image.path");
      // widget.profileCircle = profileImageCircle(imageUrl: image.path, size: 75,expandable: false,);
    });
  }

  void displayParticipantDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ParticipantDetailDialog(
          participant: widget.participant,
          onImageUpdated: onImageUpdated,
          onDataChanged: () => setState(() {}),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: displayParticipantDetails,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          profileImageCircle(
            imageUrl: widget.participant.image,
            size: 75,
            expandable: false,
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  widget.participant.name,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .6,
                  child: Text(
                    widget.participant.description,
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                   ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


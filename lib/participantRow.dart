import 'dart:io';
import 'package:PN2025/participant.dart';
import 'package:PN2025/participantDetailDialog.dart';
import 'package:PN2025/profileImageCircle.dart';
import 'package:flutter/material.dart';

class participantRow extends StatefulWidget {
  Participant participant;
  late Widget profileCircle = profileImageCircle(
                imageUrl: participant.image,
                size: 75,
                expandable: false,
              );
  participantRow({super.key, required this.participant});

  @override
  State<participantRow> createState() => _participantRowState();
}

class _participantRowState extends State<participantRow> {
  void onImageUpdated(File image) {
    setState(() {
      widget.profileCircle = profileImageCircle(imageFile: image, size: 75,expandable: false,);
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
          widget.profileCircle,
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


import 'package:NagaratharEvents/activity.dart';
import 'package:NagaratharEvents/imageInfo.dart';
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
  void onImageUpdated(String? imageUrl) {
    setState(() {
      if(imageUrl == null)
      {
        globals.totalActivities![activityIndex].participants[widget.participantIndex].image = null;
        participant.image = null;
        return;
      }
      globals.totalActivities![activityIndex].participants[widget.participantIndex].image = imageInfo(id: 'local', url: imageUrl);
      participant.image = imageInfo(id: 'local', url: imageUrl);
    });
  }

  void displayParticipantDetails() async{
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ParticipantDetailDialog(
          participant: participant,
          onImageUpdated: onImageUpdated,
          onDataChanged: (data) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          imageLoader(
            buttonSize: 5,
            givenImage: participant.image,
            circle: true,
            key: ValueKey(participant.image),
            size: 75,
            shouldExpand: false,
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .6,
                  child: Text(
                    participant.name,
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: globals.bodyFontSize,
                      fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .6,
                  child: Text(
                    participant.description,
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: globals.smallFontSize,
                      fontWeight: FontWeight.bold
                    ),
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
import 'package:PN2025/activitiesPage.dart';
import 'package:PN2025/activity.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/globals.dart' as globals;
import 'utils.dart' as utils;

class thumbsUpIcon extends StatefulWidget {
  Activity activity;
  thumbsUpIcon({super.key, required this.activity});

  @override
  State<thumbsUpIcon> createState() => _thumbsUpIconState();
}

class _thumbsUpIconState extends State<thumbsUpIcon> {
  @override
  Widget build(BuildContext context) {
    int count = widget.activity.likes;
    bool liked = widget.activity.liked;
    return GestureDetector(
      onTap: () {
        setState(() {
          liked = !liked;
          count += liked ? 1 : -1;
          // activitiesPage.totalEvents[widget.event["id"]-1]["liked"] = liked;
          // activitiesPage.totalEvents[widget.event["id"]-1]["_count"]["likedUserDevice"] =
              // count;
        });
        if (liked) {
          // utils.updateNoData('events/$id/like');
        } else {
          // utils.updateNoData('events/$id/unlike');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.thumb_up_sharp,
              color: liked ? globals.secondaryColor : Colors.white,
              size: 28,
            ),
            Text(
              count.toString(),
              style: TextStyle(
                  color:
                      liked ? globals.secondaryColor : Colors.white,
                  fontSize: 28),
            )
          ],
        ),
      ),
    );
  }
}

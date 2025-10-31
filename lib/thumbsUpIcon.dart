import 'package:PN2025/activity.dart';
import 'package:PN2025/networkService.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/globals.dart' as globals;

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
          globals.totalActivities![globals.totalActivities!.indexOf(widget.activity)].toogleLike();
          liked = !liked;
          count += liked ? 1 : -1;
        });
        if (liked) {
          NetworkService().patchNoData('activities/${widget.activity.id}/likes');
        } else {
          NetworkService().patchNoData('activities/${widget.activity.id}/unlikes');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromARGB(255, 149, 235, 252),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.thumb_up_rounded,
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

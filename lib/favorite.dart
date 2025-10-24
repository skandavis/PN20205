import 'package:PN2025/activity.dart';
import 'package:PN2025/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:PN2025/globals.dart' as globals;

class favoriteIcon extends StatefulWidget {
  Activity activity;
  favoriteIcon({super.key, required this.activity});

  @override
  State<favoriteIcon> createState() => _favoriteIconState();
}

class _favoriteIconState extends State<favoriteIcon> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint(activitiesPage.totalEvents.toString());
    bool favorite = widget.activity.favoritized;
    return IconButton(
      onPressed: () {
        setState(() {
          globals.totalActivities[globals.totalActivities.indexOf(widget.activity)].toogleFavorite();
        });
        if (favorite) {
          utils.updateNoData('events/${widget.activity.id}/favoritize');
        } else {
          utils.updateNoData('events/${widget.activity.id}/unfavoritize');
        }
      },
      icon: Icon(
        size: 28,
        favorite ? Icons.favorite : Icons.favorite_border,
        color: favorite ? Colors.pink : globals.secondaryColor,
      ),
    );
  }
}

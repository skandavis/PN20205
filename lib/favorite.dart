import 'package:PN2025/activity.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/globals.dart' as globals;
import 'utils.dart' as utils;

class FavoriteIcon extends StatefulWidget {
  Activity activity;
  FavoriteIcon({super.key, required this.activity});

  @override
  State<FavoriteIcon> createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<FavoriteIcon> {
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
          favorite = !favorite;
          // activitiesPage.totalEvents[widget.event["id"]-1]["favorite"] = favorite;
          // debugPrint(activitiesPage.totalEvents.toString());
        });
        if (favorite) {
          // utils.updateNoData('events/$id/favoritize');
        } else {
          // utils.updateNoData('events/$id/unfavoritize');
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

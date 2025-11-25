import 'package:NagaratharEvents/activity.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

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
    (widget.activity.favoritized.toString());
    bool favorite = widget.activity.favoritized;
    return IconButton(
      onPressed: () {
        setState(() {
          globals.totalActivities![globals.totalActivities!.indexOf(widget.activity)].toogleFavorite();
          favorite = !favorite;
        });
        if (favorite) {
          NetworkService().patchNoData('activities/${widget.activity.id}/favoritize');
        } else {
          NetworkService().patchNoData('activities/${widget.activity.id}/unfavoritize');
        }
      },
      icon: Icon(
        favorite ? Icons.favorite : Icons.favorite_border,
        color: favorite ? Colors.pink : globals.secondaryColor,
      ),
    );
  }
}

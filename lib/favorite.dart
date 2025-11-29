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
  Widget build(BuildContext context) {
    bool favorite = widget.activity.favoritized;
    return IconButton(
      onPressed: () async {
        if (favorite) {
          final response = await NetworkService().patchNoData('activities/${widget.activity.id}/favoritize');
          if(response.statusCode != 200) return;
        } else {
          final response = await NetworkService().patchNoData('activities/${widget.activity.id}/unfavoritize');
          if(response.statusCode != 200) return;
        }
        setState(() {
          globals.totalActivities![globals.totalActivities!.indexOf(widget.activity)].toogleFavorite();
          favorite = !favorite;
        });
      },
      icon: Icon(
        favorite ? Icons.favorite : Icons.favorite_border,
        color: favorite ? Colors.pink : globals.secondaryColor,
      ),
    );
  }
}

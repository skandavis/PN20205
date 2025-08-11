import 'package:flutter/material.dart';
import 'package:flutter_application_2/globals.dart' as globals;
import 'utils.dart' as utils;

class FavoriteIcon extends StatefulWidget {
  dynamic event;
  FavoriteIcon({super.key, required this.event});

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
    bool favorite = widget.event["favorite"];
    int id = widget.event["id"];
    return IconButton(
      onPressed: () {
        setState(() {
          favorite = !favorite;
          globals.totalEvents[widget.event["id"]-1]["favorite"] = favorite;
        });
        if (favorite) {
          utils.putRoute('events/$id/favoritize');
        } else {
          utils.putRoute('events/$id/unfavoritize');
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

import 'package:flutter/material.dart';
class favoritesearchlabel extends StatefulWidget {
  bool selected = true;
  favoritesearchlabel({super.key});

  @override
  State<favoritesearchlabel> createState() => _favoritesearchlabelState();
}

class _favoritesearchlabelState extends State<favoritesearchlabel> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: const Icon(
          Icons.favorite,
          color: Colors.red,
          size: 36,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:PN2025/globals.dart' as globals;

class selectableCategoryLabel extends StatefulWidget {
  String label;
  bool chosen;
  Function(bool, String) chooseCategory;
  selectableCategoryLabel(
      {super.key,
      required this.label,
      required this.chooseCategory,
      required this.chosen});

  @override
  State<selectableCategoryLabel> createState() =>
      _selectableCategoryLabelState();
}

class _selectableCategoryLabelState extends State<selectableCategoryLabel> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.chosen = !widget.chosen;
          widget.chooseCategory(widget.chosen, widget.label);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal:10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(15),
            color: widget.chosen
                ? globals.secondaryColor
                : Colors.white),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class categoryLabel extends StatefulWidget {
  Map<String, dynamic> event;
  categoryLabel({super.key,required this.event});

  @override
  State<categoryLabel> createState() => _categoryLabelState();
}

class _categoryLabelState extends State<categoryLabel> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        1,
        (index) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.all(3),
            child: Text(
              widget.event["category"]["category"],
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

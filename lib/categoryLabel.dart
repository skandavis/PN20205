import 'package:NagaratharEvents/activity.dart';
import 'package:flutter/material.dart';

class categoryLabel extends StatefulWidget {
  Activity activity;
  categoryLabel({super.key,required this.activity});

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
                color: Color.fromARGB(255, 149, 235, 252),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: Center(
              child: Text(
                widget.activity.main,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Check extends StatefulWidget {
  bool isChecked = false;
  final String name;
  Function() onChange;
  Color color;
  Check(
      {super.key,
      required this.name,
      required this.onChange,
      required this.color});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Checkbox(
              value: widget.isChecked,
              onChanged: (value) {
                setState(() {
                  widget.isChecked = !widget.isChecked;
                });
                widget.onChange();
              },
            ),
            Text(
              widget.name,
              style: TextStyle(
                color: widget.color,
              ),
            )
          ],
        ),
      ],
    );
  }
}

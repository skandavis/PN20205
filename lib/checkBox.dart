import 'package:flutter/material.dart';

class Check extends StatefulWidget {
  bool isChecked = false;
  final String name;
  final Function() onChange;
  final Color color;

  Check({
    super.key,
    required this.name,
    required this.onChange,
    required this.color,
  });

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Transform.scale(
          scale: 1.25, // 🔧 Increase this value to make checkbox bigger
          child: Checkbox(
            autofocus: true,
            activeColor: widget.color,
            side: BorderSide(color: widget.color),
            value: widget.isChecked,
            onChanged: (value) {
              setState(() {
                widget.isChecked = !widget.isChecked;
              });
              widget.onChange();
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        SizedBox(width: 8),
        Text(
          widget.name,
          style: TextStyle(
            color: widget.color,
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, // 🔧 Increase font size as needed
          ),
        ),
      ],
    );
  }
}

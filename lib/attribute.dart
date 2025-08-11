import 'package:flutter/material.dart';

class attribute extends StatefulWidget {
  String attributeTitle;
  String attributeValue;
  attribute(
      {super.key, required this.attributeTitle, required this.attributeValue});

  @override
  State<attribute> createState() => _attributeState();
}

class _attributeState extends State<attribute> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              widget.attributeTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16),
            ),
            Text(
              widget.attributeValue,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}

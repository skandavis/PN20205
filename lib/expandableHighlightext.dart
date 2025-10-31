import 'package:flutter/material.dart';

class expandableHighlightText extends StatefulWidget {
  final String text;

  const expandableHighlightText({super.key, required this.text});

  @override
  _expandableHighlightTextState createState() => _expandableHighlightTextState();
}

class _expandableHighlightTextState extends State<expandableHighlightText>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
          ],
          border: Border.all(
            color: const Color.fromARGB(255, 149, 235, 252),
          ),
        ),
        child: AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Text(
            widget.text,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
class backgoundDynamicIcon extends StatefulWidget {
  IconData icon;
  bool active;
  Function(bool) onTap;
  Color foregroundColor;
  Color backgroundColor;
  backgoundDynamicIcon({super.key, 
    required this.icon, 
    required this.active,
    required this.onTap,
    required this.foregroundColor,
    required this.backgroundColor
  });

  @override
  State<backgoundDynamicIcon> createState() => _backgoundDynamicIconState();
}

class _backgoundDynamicIconState extends State<backgoundDynamicIcon> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          widget.active = !widget.active;
        });
        widget.onTap(widget.active);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.active ? widget.foregroundColor : widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          widget.icon,
          color: widget.active ? widget.backgroundColor : widget.foregroundColor,
        ),
      ),
    );
  }
}

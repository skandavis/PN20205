import 'package:flutter/material.dart';

class actionButton extends StatefulWidget {
  VoidCallback onTap;
  Color color;
  IconData icon;
  Color iconColor;
  double? buttonSize;
  actionButton({
    super.key,
    this.buttonSize,
    required this.onTap,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<actionButton> createState() => _actionButtonState();
}

class _actionButtonState extends State<actionButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: widget.buttonSize ?? 25,
        width: widget.buttonSize ?? 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
        child: Icon(widget.icon, color: widget.iconColor, size: 24),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class customDialogBox extends StatefulWidget {
  final String title;
  final Widget body;
  final int height;

  const customDialogBox({
    super.key,
    required this.title,
    required this.body,
    this.height = 450,
  });

  @override
  State<customDialogBox> createState() => _customDialogBoxState();
}

class _customDialogBoxState extends State<customDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 300,
          maxHeight: widget.height.toDouble(),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 75,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 31, 53, 76),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: Center(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        Theme.of(context).textTheme.titleMedium?.fontSize,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: SizedBox(
                    height: widget.height.toDouble() - 115,
                    child: widget.body,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

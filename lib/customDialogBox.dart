import 'package:flutter/material.dart';

class customDialogBox extends StatefulWidget {
  String title;
  Widget body;
  customDialogBox({super.key, required this.title, required this.body});

  @override
  State<customDialogBox> createState() => _customDialogBoxState();
}

class _customDialogBoxState extends State<customDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(
        maxWidth: 300,
        maxHeight: 400
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Colors.white
        ),
        child: Column(
          children: [
            Container(
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                color: Color.fromARGB(255,31,53,76)
              ),
              child: Center(
                child: Text(
                  widget.title, 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: Theme.of(context).textTheme.titleMedium?.fontSize
                  ),
                ),
              ),
            ),
            Container(
              height: 325,
              padding: EdgeInsets.all(20),
              child: widget.body
            ),
          ],
        ),
      ),
    );
  }
}
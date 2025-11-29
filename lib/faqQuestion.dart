import 'package:flutter/material.dart';

class faqQuestion extends StatefulWidget {
  String question;
  String answer;
  bool isExpanded = false;
  faqQuestion({super.key, required this.question, required this.answer});

  @override
  State<faqQuestion> createState() => _faqQuestionState();
}

class _faqQuestionState extends State<faqQuestion> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.isExpanded = !widget.isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        width: MediaQuery.of(context).size.width * .9,
        // height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width * .8)-20,
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .1,
                  child: Icon(widget.isExpanded
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded),
                )
              ],
            ),
            if (widget.isExpanded)
              Row(
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width * .8)-20,
                    child: Text(
                      widget.answer,
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                      ),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

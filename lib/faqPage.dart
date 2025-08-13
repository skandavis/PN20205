import 'package:flutter/material.dart';
import 'package:PN2025/faqQuestion.dart';
import 'utils.dart' as utils;

class faqPage extends StatefulWidget {
  const faqPage({super.key});

  @override
  State<faqPage> createState() => _faqPageState();
}


class _faqPageState extends State<faqPage> {
static List<dynamic> questions = [];
  @override
  void initState() {
    if(questions.isEmpty)
    {
      utils.getRoute('faqs').then((onValue) {
        setState(() {
          questions = onValue["faqs"];
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: questions.isNotEmpty?Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(questions.length, (index) {
            return Column(
              children: [
                const SizedBox(
                  height: 35,
                ),
                faqQuestion(
                  question: questions[index]["question"],
                  answer: questions[index]["answer"],
                )
              ],
            );
          })
        ):Column(
          children: [
            Icon(
              Icons.search_off,
              size: 128,
              color: Colors.white,
            ),
            Text(
              "No Notifications Found",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 44
              ),
            )
          ],
        ),
      ),
    );
  }
}

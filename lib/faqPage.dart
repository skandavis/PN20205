import 'package:flutter/material.dart';
import 'package:flutter_application_2/faqQuestion.dart';
import 'utils.dart' as utils;

class faqPage extends StatefulWidget {
  const faqPage({super.key});

  @override
  State<faqPage> createState() => _faqPageState();
}

List<dynamic> questions = [];

class _faqPageState extends State<faqPage> {
  @override
  void initState() {
    utils.getRoute('faqs').then((onValue) {
      setState(() {
        questions = onValue["faqs"];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
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
                }))
          ],
        ),
      ],
    );
  }
}

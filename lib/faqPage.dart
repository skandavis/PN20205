import 'package:flutter/material.dart';
import 'package:pn2025/faqQuestion.dart';
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
        if(questions.isNotEmpty) {
          return Center(
            child: Column(
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
            ),
          );
        } else {
          return const Column(
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
        );
        }
  }
}

import 'package:PN2025/loadingScreen.dart';
import 'package:PN2025/networkService.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/faqQuestion.dart';

class faqPage extends StatefulWidget {
  const faqPage({super.key});

  @override
  State<faqPage> createState() => _faqPageState();
}


class _faqPageState extends State<faqPage> {
static List<dynamic>? questions;
  @override
  void initState() {
    super.initState();
    if (questions != null) return;
    NetworkService().getMultipleRoute('faqs', context, forceRefresh: true).then((faqs) {
      setState(() {
        questions = faqs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return questions!=null?SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(questions!.length, (index) {
            return Column(
              children: [
                const SizedBox(
                  height: 35,
                ),
                faqQuestion(
                  question: questions![index]["question"],
                  answer: questions![index]["answer"],
                )
              ],
            );
          })
        ),
      ),
    ):loadingScreen();
  }
}

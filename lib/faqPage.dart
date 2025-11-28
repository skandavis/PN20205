import 'package:NagaratharEvents/loadingScreen.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/faqQuestion.dart';

class faqPage extends StatefulWidget {
  final ValueNotifier<bool> isVisible;
  const faqPage({super.key, required this.isVisible});

  @override
  State<faqPage> createState() => _faqPageState();
}


class _faqPageState extends State<faqPage> {
static List<dynamic>? questions;
  @override
  void initState() {
    super.initState();
    widget.isVisible.addListener(_onVisibilityChanged);
  }

  @override
  void dispose() {
    widget.isVisible.removeListener(_onVisibilityChanged);
    super.dispose();
  }

  void _onVisibilityChanged() {
    if (widget.isVisible.value) {
      loadFaqs();
    } else {
      // is not visible
    }
  }

  void loadFaqs() {
    if (questions != null) return;
    NetworkService().getMultipleRoute('faqs', forceRefresh: true).then((faqs) {
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
          children: List.generate(questions!.length, (index) {
            return Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                faqQuestion(
                  question: questions![index]["question"],
                  answer: questions![index]["answer"],
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            );
          })
        ),
      ),
    ):loadingScreen();
  }
}

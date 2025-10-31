import 'package:PN2025/globals.dart' as globals;
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
      NetworkService().getMultipleRoute('faqs').then((faqs) {
        setState(() {
          questions = faqs;
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*.05,
        title: Text(
          'Faqs',
          style: TextStyle(
            fontSize:Theme.of(context).textTheme.displaySmall?.fontSize
          ),
        ),
        backgroundColor: globals.backgroundColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      body: questions!=null?SingleChildScrollView(
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
      ):loadingScreen(),
    );
  }
}

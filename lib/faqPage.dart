import 'package:NagaratharEvents/loadingScreen.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/faqQuestion.dart';

class faqPage extends StatefulWidget {
  final ValueNotifier<int> isVisible;
  const faqPage({super.key, required this.isVisible});

  @override
  State<faqPage> createState() => _faqPageState();
}

class _faqPageState extends State<faqPage> {
static List<dynamic>? questions;
bool isLoading = false;
bool isConnected = false;
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
    if (widget.isVisible.value == 1) {
      loadFaqs();
    } else if(widget.isVisible.value == 0) {
      clearFaqs();
    }
  }

  void clearFaqs() {
    questions = null;
  }

  void loadFaqs() {
    if(questions != null)
    {
      setState(() {
        isConnected = true;
      });
      return;
    } 
    setState(() {
      isLoading = true;
    });
    NetworkService().getMultipleRoute('faqs').then((faqs) {
      if(faqs == null)
      {
        setState(() {
          isConnected = false;
        });
      }else{
        setState(() {
          questions = faqs;
          isConnected = true;
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if(isConnected && !isLoading)
        SingleChildScrollView(
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
        ),
        if(!isConnected)
        Center(child: const Text("No Internet Connection!", style: TextStyle(color: Colors.white, fontSize: 20),)),
        if(isLoading)
        loadingScreen(),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class submitButton extends StatelessWidget {
  Function() onSubmit;
  String text;
  submitButton({super.key,required this.text, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSubmit,
      child: Container(
        alignment: Alignment.center,
        width: 250,
        height: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 24, 19, 118),
                Colors.black,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize:Theme.of(context).textTheme.headlineSmall?.fontSize),
        ),
      ),
    );
  }
}
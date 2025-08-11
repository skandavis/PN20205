import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/globals.dart' as globals;

class formInput extends StatefulWidget {
  int? lines;
  String label;
  TextEditingController controller;
  FocusNode focusNode;
  List<TextInputFormatter>? formatters;
  formInput({super.key, required this.label, required this.controller, required this.focusNode, this.lines, this.formatters});

  @override
  State<formInput> createState() => _formInputState();
}
class _formInputState extends State<formInput> {
  @override
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
        if(widget.focusNode.hasFocus) {
          setState(() {
            
          });
        }
        if (!widget.focusNode.hasFocus) {
          setState(() {
            
          });
        }
    });
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      inputFormatters: widget.formatters,
      maxLines: widget.lines,
      focusNode: widget.focusNode,
      controller: widget.controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 13, 182, 255),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.controller.text.isEmpty? Colors.red: globals.secondaryColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        hintText: widget.label,
        label: Text(
          widget.label,
          style: TextStyle(
            color: widget.focusNode.hasFocus? const Color.fromARGB(255, 13, 182, 255):widget.controller.text.isEmpty? Colors.red:  globals.secondaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold),
        ),
        fillColor: const Color.fromARGB(255, 10, 5, 70),
      ),
    );
  }
}

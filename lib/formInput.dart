import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class formInput extends StatefulWidget {
  int? lines;
  String label;
  TextEditingController controller;
  FocusNode focusNode;
  List<TextInputFormatter>? formatters;
  TextInputType? inputType;
  formInput({super.key, required this.label, required this.controller, required this.focusNode, this.lines, this.formatters, this.inputType});

  @override
  State<formInput> createState() => _formInputState();
}
class _formInputState extends State<formInput> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.inputType ?? TextInputType.text,
      onChanged: (value) {
        setState(() {
          
        });
      },
      inputFormatters: widget.formatters,
      maxLines: widget.lines,
      focusNode: widget.focusNode,
      controller: widget.controller,
      style: TextStyle(color: Colors.white,fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize),
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: globals.iceBlue,
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
            color: widget.focusNode.hasFocus? globals.iceBlue:widget.controller.text.isEmpty? Colors.red:  globals.secondaryColor,
            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
            fontWeight: FontWeight.bold),
        ),
        fillColor: const Color.fromARGB(255, 10, 5, 70),
      ),
    );
  }
}

import 'package:NagaratharEvents/customDialogBox.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/gradientTextField.dart';
import 'package:NagaratharEvents/utils.dart' as utils;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class attribute extends StatefulWidget {
  bool isEditable;
  final String attributeTitle;
  dynamic attributeValue;
  Future<int> Function(String?, DateTime?)? onValueChange;
  attribute({
    super.key,
    required this.isEditable,
    required this.attributeTitle,
    required this.attributeValue,
    this.onValueChange,
  });

  @override
  State<attribute> createState() => _attributeState();
}

class _attributeState extends State<attribute> {
  late final controller = TextEditingController(text: widget.attributeValue);
  
  void _editValue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return customDialogBox(
          height: 300,
          title: "Location", 
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              gradientTextField(
                controller: controller,
                hint: "Enter ${widget.attributeTitle}",
                label: widget.attributeTitle, 
                icon: Icons.pin_drop,
              ),
              GestureDetector(
                onTap: () async{
                  FocusManager.instance.primaryFocus?.unfocus();
                  if(controller.text.isEmpty)
                  {
                    utils.snackBarAboveMessage('Please enter ${widget.attributeTitle}');
                    return;
                  }
                  if(widget.onValueChange != null) {
                    final statusCode = await widget.onValueChange!(controller.text, null);
                    if(statusCode != 200) return;      
                    utils.snackBarMessage("${widget.attributeTitle} updated!", color: Colors.green);
                  }
                  setState((){
                    widget.attributeValue = controller.text;
                  });
                  Navigator.pop(context, controller.text);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: globals.secondaryColor,
                  ),
                  width: 130,
                  height: 50,
                  child: Center(
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: globals.subTitleFontSize
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
    controller.clear();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime selectedDateTime = widget.attributeValue;
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: globals.backgroundColor,
          child: Column(
            children: [
              Container(
                height: 50,
                color: globals.secondaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: globals.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: globals.bodyFontSize
                        ),
                      ),
                      onTap: () async {
                        Navigator.of(context).pop();
                        if(widget.onValueChange != null) {
                          setState(() {
                          });
                          final statusCode = await widget.onValueChange!(null, selectedDateTime);
                          if(statusCode != 200) return;      
                          utils.snackBarMessage("${widget.attributeTitle} updated!", color: Colors.green);
                        }
                        setState(() {
                          widget.attributeValue = selectedDateTime;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Date-time picker
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: globals.bodyFontSize,
                      ),
                    ),
                    brightness: Brightness.dark,
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: widget.attributeValue,
                    minimumDate: widget.attributeValue,
                    maximumDate: widget.attributeValue.add(Duration(days: 2)),
                    onDateTimeChanged: (DateTime newDateTime) {
                      selectedDateTime = newDateTime;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onDoubleTap: (){
          if(!widget.isEditable) return;
          if(widget.attributeValue is DateTime) {
            _selectDateTime(context);
          } else {
            _editValue();
          } 
        },
        onTap: (){
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return customDialogBox(
                height: 175,
                title: widget.attributeTitle, 
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.attributeValue is DateTime ? DateFormat('MMM dd, h:mm a').format(widget.attributeValue) : widget.attributeValue,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: globals.bodyFontSize,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Text(
              widget.attributeTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: globals.smallFontSize
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                widget.attributeValue is DateTime ? DateFormat('MMM dd, h:mm a').format(widget.attributeValue) : widget.attributeValue,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: globals.smallFontSize
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:NagaratharEvents/customDialogBox.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/gradientTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class attribute extends StatefulWidget {
  bool isEditable;
  final String attributeTitle;
  String attributeValue;
  bool isDate;
  void Function(String?, DateTime?)? onValueChange;
  attribute({
    super.key,
    required this.isEditable,
    required this.attributeTitle,
    required this.attributeValue,
    this.onValueChange,
    this.isDate = false,
  });

  @override
  State<attribute> createState() => _attributeState();
}

class _attributeState extends State<attribute> {
  late final controller = TextEditingController(text: widget.attributeValue);
  
  void _editValue() {
    if(!widget.isEditable) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return customDialogBox(
          height: 250,
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
                onTap: () {
                  setState(() {
                    widget.attributeValue = controller.text;
                  });
                  if(widget.onValueChange != null) {
                    widget.onValueChange!(controller.text, null);
                  }
                  Navigator.pop(context, controller.text);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: globals.secondaryColor,
                  ),
                  width: 100,
                  height: 40,
                  child: Center(
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize
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
    debugPrint("Selecting date and time");
    
    DateTime selectedDateTime = DateTime.now();
    
    // Show Cupertino date-time picker
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
                    CupertinoButton(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: globals.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
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
                        fontSize: 20,
                      ),
                    ),
                    brightness: Brightness.dark,
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: DateTime.now(),
                    minimumDate: DateTime.now().subtract(Duration(days: 3)),
                    maximumDate: DateTime.now().add(Duration(days: 3)),
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

    // Format as "MMMM DD, HH:mm"
    final String formattedDate = DateFormat('MMM dd, h:mm a').format(selectedDateTime);
    
    print("Selected date and time: $selectedDateTime");
    setState(() {
      widget.attributeValue = formattedDate;
    });
    
    if(widget.onValueChange != null) {
      widget.onValueChange!(null, selectedDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: (){
          if(widget.isDate) {
            _selectDateTime(context);
          } else {
            _editValue();
          } 
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                widget.attributeTitle,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                widget.attributeValue,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
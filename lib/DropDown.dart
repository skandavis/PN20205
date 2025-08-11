import 'package:flutter/material.dart';
import 'package:flutter_application_2/globals.dart' as globals;

class DropDown extends StatefulWidget {
  final List<String> options;
  final String label;
  final String initialValue;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const DropDown({
    super.key,
    required this.options,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    required this.focusNode,
  });

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.initialValue;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
            color: globals.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          focusNode: widget.focusNode,
          initialValue: dropdownValue,
          dropdownColor: globals.backgroundColor,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: globals.secondaryColor, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: globals.iceBlue, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          iconEnabledColor: Colors.white,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => dropdownValue = newValue);
              widget.onChanged(newValue);
            }
          },
          items: widget.options.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;

            return DropdownMenuItem<String>(
              value: value,
              child: Container(
                width: MediaQuery.sizeOf(context).width * .7,
                height: 50,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: index < widget.options.length - 1
                        ? BorderSide(color: globals.iceBlue, width: 2)
                        : BorderSide.none,
                  ),
                ),
                child: Center(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),


        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:PN2025/globals.dart' as globals;

class dropDown extends StatefulWidget {
  final List<dynamic> options;
  final String label;
  final String initialValue;
  final FocusNode focusNode;
  final Function(int) onChanged;

  const dropDown({
    super.key,
    required this.options,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    required this.focusNode,
  });

  @override
  State<dropDown> createState() => _dropDownState();
}

class _dropDownState extends State<dropDown> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(6);

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

        /// Add shadow using a Container
        Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            focusNode: widget.focusNode,
            initialValue: dropdownValue,
            dropdownColor: globals.backgroundColor,
            decoration: InputDecoration(
              fillColor: globals.backgroundColor,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: globals.secondaryColor, width: 2),
                borderRadius: borderRadius,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: globals.iceBlue, width: 2),
                borderRadius: borderRadius,
              ),
            ),
            iconEnabledColor: Colors.white,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => dropdownValue = newValue);
                widget.onChanged(widget.options.indexOf(newValue));
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
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

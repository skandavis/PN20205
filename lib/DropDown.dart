import 'package:flutter/material.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class dropDown extends StatefulWidget {
  final List<String> options;
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
    final radius = BorderRadius.circular(10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: globals.bodyFontSize,
            color: globals.secondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            focusNode: widget.focusNode,
            initialValue: dropdownValue,
            dropdownColor: globals.backgroundColor,
            borderRadius: radius,
            elevation: 8,
            style: TextStyle(
              color: Colors.white,
              fontSize: globals.paraFontSize,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: globals.backgroundColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: globals.secondaryColor, width: 2),
                borderRadius: radius,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: globals.iceBlue, width: 2),
                borderRadius: radius,
              ),
            ),
            icon: const Icon(Icons.expand_more_rounded, color: Colors.white),
            selectedItemBuilder: (_) {
              return widget.options.map((value) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: globals.paraFontSize,
                    ),
                  ),
                );
              }).toList();
            },
            onChanged: (value) {
              if (value == null) return;
              setState(() => dropdownValue = value);
              widget.onChanged(widget.options.indexOf(value));
            },
            items: widget.options.map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(value),
                ),
              );
            }).toList(),
          )
        ),
      ],
    );
  }
}

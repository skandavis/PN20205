import 'package:flutter/material.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class expandableHighlightText extends StatefulWidget {
  final String text;
  final bool editable;
  final Function(String)? onTextChanged;
  
  expandableHighlightText({
    super.key, 
    required this.text, 
    this.editable = false,
    this.onTextChanged,
  });

  @override
  _expandableHighlightTextState createState() => _expandableHighlightTextState();
}

class _expandableHighlightTextState extends State<expandableHighlightText>{
  bool isExpanded = false;
  bool isEditing = false;
  late String currentText;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    currentText = widget.text;
    _controller = TextEditingController(text: currentText);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveChanges() {
    setState(() {
      isEditing = false;
      currentText = _controller.text;
    });
    widget.onTextChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditing ? null : () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      onLongPress: widget.editable ? () {
        setState(() {
          isExpanded = true;
          isEditing = true;
        });
        _focusNode.requestFocus();
      } : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromARGB(255, 149, 235, 252),
          ),
        ),
        child: AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isEditing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: globals.paraFontSize,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _controller.text = currentText;
                              isEditing = false;
                            });
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 149, 235, 252),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 149, 235, 252),
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text('Done'),
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  currentText.trim(),
                  maxLines: isExpanded ? null : 2,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: globals.paraFontSize,
                  ),
                ),
        ),
      ),
    );
  }
}
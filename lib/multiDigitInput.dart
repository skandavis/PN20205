import 'package:flutter/material.dart';

class multiDigitInput extends StatefulWidget {
  final int digits;
  final void Function(String)? onChanged;
  final void Function()? onSubmitted;
  
  const multiDigitInput({
    super.key,
    this.onChanged,
    this.onSubmitted,
    required this.digits,
  });
  
  @override
  State<multiDigitInput> createState() => _multiDigitInputState();
}

class _multiDigitInputState extends State<multiDigitInput> {
  late TextEditingController controller;
  late FocusNode focusNode;
  
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    
    // Auto-focus when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }
  
  List<String> get digitsList {
    final text = controller.text.padRight(widget.digits, ' ');
    return text.substring(0, widget.digits).split('');
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: Stack(
        children: [
          // Invisible TextField
          Opacity(
            opacity: 0.0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLength: widget.digits,
                onChanged: (value) {
                  setState(() {});
                  widget.onChanged?.call(value);
                },
                onSubmitted: (_) {
                  widget.onSubmitted?.call();
                },
              ),
            ),
          ),
          // Visual digit boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.digits, (index) {
              final digits = digitsList;
              final hasDigit = index < controller.text.length;
              final digit = hasDigit ? digits[index] : '';
              
              return Row(
                children: [
                  if (index != 0) const SizedBox(width: 5),
                  Container(
                    width: 45,
                    height: 55,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: focusNode.hasFocus && index == controller.text.length
                            ? Colors.blue
                            : Colors.grey,
                        width: focusNode.hasFocus && index == controller.text.length
                            ? 2
                            : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      digit.trim(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
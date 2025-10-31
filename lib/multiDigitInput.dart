import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class multiDigitInput extends StatefulWidget {
  int digits;
  final void Function(String)? onChanged;
  final void Function()? onSubmitted;
  multiDigitInput({super.key, this.onChanged, this.onSubmitted, required this.digits});
  
  @override
  State<multiDigitInput> createState() => _multiDigitInputState();
}

class _multiDigitInputState extends State<multiDigitInput> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  
  @override
  void initState() {
    super.initState();
    controllers = List.generate(widget.digits, (_) => TextEditingController());
    focusNodes = List.generate(widget.digits, (_) => FocusNode());
    focusNodes[0].requestFocus();
  }
  
  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
  
  void onChanged() {
    final code = controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
  }
  
  void handlePaste(String pastedText, int startIndex) {
    // Extract only digits from pasted text
    final digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Fill the boxes starting from the current index
    for (int i = 0; i < digits.length && (startIndex + i) < widget.digits; i++) {
      controllers[startIndex + i].text = digits[i];
    }
    
    // Move focus to the next empty box or the last box
    final nextIndex = (startIndex + digits.length).clamp(0, widget.digits - 1);
    FocusScope.of(context).requestFocus(focusNodes[nextIndex]);
    
    onChanged();
  }
  
  void handleKeyPress(int index, RawKeyEvent event) {
    if(event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter){
      FocusScope.of(context).unfocus();
      widget.onSubmitted?.call();
    }
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (controllers[index].text.isEmpty && index > 0) {
        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
        controllers[index - 1].clear();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.digits, (index) {
        return Row(
          children: [
            if (index != 0) const SizedBox(width: 5),
            SizedBox(
              width: 50,
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (event) => handleKeyPress(index, event),
                child: TextField(
                  key: ValueKey(index),
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    // Custom formatter to handle paste
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      // If more than one character is being added, it's likely a paste
                      if (newValue.text.length > 1) {
                        // Schedule paste handling after the current frame
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          handlePaste(newValue.text, index);
                        });
                        // Return just the first character for this field
                        return TextEditingValue(
                          text: newValue.text.isNotEmpty ? newValue.text[0] : '',
                          selection: TextSelection.collapsed(offset: 1),
                        );
                      }
                      return newValue;
                    }),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    isDense: true, // reduces overall height
                    contentPadding: EdgeInsets.symmetric(vertical: 10), // removes inner padding
                    // border: InputBorder.none, // removes the outline border
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < widget.digits - 1) {
                      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                    }
                    onChanged();
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
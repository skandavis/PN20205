import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SixDigitInput extends StatefulWidget {
  final void Function(String)? onChanged;
  final void Function()? onSubmitted;

  const SixDigitInput({super.key, this.onChanged, this.onSubmitted});

  @override
  State<SixDigitInput> createState() => _SixDigitInputState();
}

class _SixDigitInputState extends State<SixDigitInput> {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
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
        // onChanged();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Row(
          children: [
            if (index != 0) const SizedBox(width: 5),
            SizedBox(
              width: 50,
              child: RawKeyboardListener(
                focusNode: FocusNode(), // for listening to backspaces
                onKey: (event) => handleKeyPress(index, event),
                child: TextField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    // fillColor: Colors.yellow,
                    // filled: true,
                    isDense: true,
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
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

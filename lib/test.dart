import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';

class SimpleWheelPicker extends StatefulWidget {
  final List<String> options;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const SimpleWheelPicker({
    super.key,
    required this.options,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<SimpleWheelPicker> createState() => _SimpleWheelPickerState();
}

class _SimpleWheelPickerState extends State<SimpleWheelPicker> {
  late final WheelPickerController _controller;

  @override
  void initState() {
    super.initState();

    final initialIndex = widget.options.indexOf(widget.initialValue);
    _controller = WheelPickerController(
      itemCount: widget.options.length,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );

    _controller.

    _controller.addListener(() {
      final value = widget.options[_controller.currentIndex];
      widget.onChanged(value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 22);

    return WheelPicker(
      controller: _controller,
      style: const WheelPickerStyle(
        itemExtent: 28,
        magnification: 1.1,
        squeeze: 1.2,
        diameterRatio: 0.9,
      ),
      builder: (context, index) {
        return Text(widget.options[index], style: textStyle);
      },
      looping: false,
    );
  }
}

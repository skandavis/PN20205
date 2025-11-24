import 'package:flutter/material.dart';

class attribute extends StatefulWidget {
  final String attributeTitle;
  String attributeValue;
  bool isEditable;
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
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          // borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit ${widget.attributeTitle}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  keyboardType: TextInputType.datetime,
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF2C2C2C),
                    border: InputBorder.none,
                    hintText: "Enter new value",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.attributeValue = controller.text;
                        });
                        widget.onValueChange!(controller.text,null);
                        Navigator.pop(context, controller.text);
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    print("Selected date: $picked");
    widget.onValueChange!(null,picked);
  }
}

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap:  () => widget.isDate ? _selectDate : _editValue,
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

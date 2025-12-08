import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:flutter/material.dart';

class gradientTextField extends StatefulWidget {
  IconData icon;
  String label;
  String hint;
  TextEditingController controller = TextEditingController();
  int? maxLines = 1;
  TextInputType? keyboardType;
  gradientTextField({super.key,required this.icon,required this.label,required this.hint,required this.controller,this.maxLines,this.keyboardType});
  @override
  State<gradientTextField> createState() =>_gradientTextFieldState();
}

class _gradientTextFieldState extends State<gradientTextField> {
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {}); // rebuild on focus change
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          focusNode.requestFocus();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: focusNode.hasFocus
                ? LinearGradient(colors: [globals.accentColor, globals.highlightColor])
                : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade400]),
          ),
          padding: EdgeInsets.all(2),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: focusNode.hasFocus ? 0.0 : 1.0,
                    end: focusNode.hasFocus ? 1.0 : 0.0,
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    final Color startColor = Color.lerp(Colors.grey.shade400, globals.accentColor, value)!;
                    final Color endColor = Color.lerp(Colors.grey.shade400, globals.highlightColor, value)!;
        
                    return ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [startColor, endColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds);
                      },
                      child: Icon(
                        widget.icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextField(
                        keyboardType: widget.keyboardType ?? TextInputType.text,
                        maxLines: widget.maxLines ?? 1,
                        controller: widget.controller,
                        cursorHeight: globals.paraFontSize,
                        focusNode: focusNode,
                        decoration: InputDecoration.collapsed(
                          hintText: widget.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

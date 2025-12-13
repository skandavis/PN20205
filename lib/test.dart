import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: SnackOverDialog(),
    );
  }
}

class SnackOverDialog extends StatefulWidget {
  SnackOverDialog({Key? key}) : super(key: key);

  @override
  _SnackOverDialogState createState() => _SnackOverDialogState();
}

class _SnackOverDialogState extends State<SnackOverDialog> {
  
  ///* show snack
  void _snackbar(BuildContext context) {
      Flushbar(
        backgroundColor: Colors.red,
        message: 'S.of(context).choose_date',
        duration: Duration(seconds: 12),
      ).show(context);
  }

  ///* dialog
  void _dialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Dialog'),
        content: GestureDetector(
          onTap: () {
            _snackbar(context); // Use the parent context for SnackBar
          },
          child: const Center(
            child: Text('Show SnackBar!'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SnackBar Over Dialog"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Press the button to show dialog',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialog(context),
        tooltip: 'Show Dialog',
        child: const Icon(Icons.add),
      ),
    );
  }
}
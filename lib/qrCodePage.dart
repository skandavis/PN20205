import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/messageReciever.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

User user = User.instance;

class qrCodePage extends StatefulWidget {
  const qrCodePage({super.key});

  @override
  State<qrCodePage> createState() => _qrCodePageState();
}

class _qrCodePageState extends State<qrCodePage> {
  @override
  Widget build(BuildContext context) {
    return messageReciever(
      body: Scaffold(
        backgroundColor: globals.backgroundColor,
        appBar: AppBar(
          foregroundColor: Colors.white,
          toolbarHeight: MediaQuery.of(context).size.height*.075,
          title: Text(
            "Check In",
            style: TextStyle(
              fontFamily: globals.titleFont,
              fontSize: globals.titleFontSize,
              color: Colors.white
            ),
          ),
          backgroundColor: globals.backgroundColor,
        ),
        body: Center(
          child: QrImageView(
            data: User.instance.phone.replaceAll('-', ''),
            version: QrVersions.auto,
            size: 250.0,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/messageReciever.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

User user = User.instance;

class qrCodePage extends StatefulWidget {
  const qrCodePage({super.key});

  @override
  State<qrCodePage> createState() => _qrCodePageState();
}

class _qrCodePageState extends State<qrCodePage> {
  Map<String, dynamic> qrData = {};

  @override
  void initState() {
    super.initState();
    getQrCode();
  }
  void getQrCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Uint8List? pin = utf8.encode(prefs.getInt("PIN").toString());
    var hmacSha256 = Hmac(sha256, pin); 
    final digest = hmacSha256.convert(utf8.encode(user.email));
    final Map<String, dynamic> data = {
      "Email": user.email,
      "Signature": digest.toString()
    };
    qrData = data;
  }

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
            data: jsonEncode(qrData),
            version: QrVersions.auto,
            size: 250.0,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
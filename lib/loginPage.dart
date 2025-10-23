import 'package:PN2025/getPinUI.dart';
import 'package:PN2025/enterPinUI.dart';
import 'package:flutter/material.dart';
import 'package:app_set_id/app_set_id.dart';
import 'package:PN2025/messageReciever.dart';

String deviceId = "";
String ApnsToken = "";
class loginPage extends StatefulWidget {
  bool sentPassword = false;
  String email = "";
  loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

Future<String?> getDeviceId() async {
    deviceId = (await AppSetId().getIdentifier())!;
    return await AppSetId().getIdentifier();
}
class _loginPageState extends State<loginPage> {
  @override
  Widget build(BuildContext context) {
    getDeviceId();
    getApnsToken();
    return messageReciever(
      body: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color.fromARGB(255, 24, 19, 118),
              Colors.black,
            ], begin: Alignment.centerLeft, end: Alignment.centerRight),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width*.1),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: Theme.of(context).textTheme.displayMedium?.fontSize, 
                        height: 1
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(MediaQuery.sizeOf(context).width*.1),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: widget.sentPassword? loginUI():
                getPinUI(
                  onPinSent: (email) {
                    setState(() {
                      widget.email = email;
                      widget.sentPassword = true;
                    });
                  },
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:NagaratharEvents/getPinUI.dart';
import 'package:NagaratharEvents/enterPinUI.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:app_set_id/app_set_id.dart';
import 'package:NagaratharEvents/messageReciever.dart';

String deviceID = "";

Future<String?> getDeviceID() async {
    deviceID = (await AppSetId().getIdentifier())!;
    return await AppSetId().getIdentifier();
}
class loginPage extends StatefulWidget {
  bool sentPassword;
  String email = "";
  loginPage({super.key, required this.sentPassword});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getDeviceID().then((onValue){
      deviceID = onValue!;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return messageReciever(
      body: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    globals.darkAccent,
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
                              fontFamily: globals.titleFont,
                              fontSize: globals.titleFontSize, 
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
                      child: widget.sentPassword? 
                      enterPinUI(
                        deviceID: deviceID,
                        updateLoading: () {
                          setState(() {
                            isLoading = !isLoading;
                          });
                        },
                      ):
                      getPinUI(
                        updateLoading: () {
                          setState(() {
                            isLoading = !isLoading;
                          });
                        },
                        deviceID: deviceID,
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
              if(isLoading)
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white,),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}